import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:get/get.dart';

import '../../../../../core/services/callkit_incoming_service.dart';
import '../../../../../core/services/callkit_pending_action_store.dart';
import '../controllers/message_incoming_call_controller.dart';
import '../models/message_call_models.dart';
import '../views/message_incoming_call_view.dart';
import 'call_agora_service.dart';
import 'call_socket_service.dart';

typedef AcceptedCallHandler =
    Future<void> Function({
      required String callId,
      required Map<String, dynamic> callData,
      required Map<String, dynamic> answerResponse,
    });

class IncomingCallCoordinator extends GetxService with WidgetsBindingObserver {
  IncomingCallCoordinator({
    required CallSocketService callSocketService,
    required AcceptedCallHandler acceptedCallHandler,
  }) : _callSocketService = callSocketService,
       _acceptedCallHandler = acceptedCallHandler;

  final CallSocketService _callSocketService;
  final AcceptedCallHandler _acceptedCallHandler;

  final RxBool isCallTransitioning = false.obs;
  final RxBool hasPresentedCall = false.obs;
  final RxBool isPresentedCallScreenVisible = false.obs;
  final RxBool presentedCallIsVideo = false.obs;
  final RxString presentedCallStatus = ''.obs;
  final RxString presentedCallParticipantName = ''.obs;

  String? _activeIncomingCallId;
  String? _presentationOwnerId;
  Future<void> Function()? _resumePresentedCall;
  MessageIncomingCallController? _incomingController;
  bool _incomingRouteVisible = false;
  bool _isOpeningAcceptedCall = false;
  bool _restoreInProgress = false;
  final Map<String, Future<void>> _incomingAcknowledgements =
      <String, Future<void>>{};
  final Set<String> _acceptedIncomingCallIds = <String>{};
  final Set<String> _remotelyTerminatedIncomingCallIds = <String>{};
  Future<void>? _nativeAcceptFuture;
  String? _nativeAcceptCallId;

  late final void Function(Map<String, dynamic>) _incomingCallListener;
  late final void Function(Map<String, dynamic>) _cancelledCallListener;
  late final void Function(Map<String, dynamic>) _endedCallListener;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _incomingCallListener = _handleIncomingCall;
    _cancelledCallListener = _handleRemoteIncomingCallClosed;
    _endedCallListener = _handleRemoteIncomingCallClosed;
    _callSocketService.addIncomingCallListener(_incomingCallListener);
    _callSocketService.addCancelledCallListener(_cancelledCallListener);
    _callSocketService.addEndedCallListener(_endedCallListener);
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_connectCallSocket());
      unawaited(_restoreNativeIncomingCallAfterDelay());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    unawaited(
      restorePendingAcceptedCall(
        waitForBackgroundHandler: const Duration(milliseconds: 600),
      ),
    );
    unawaited(restoreNativeIncomingCall());
  }

  void presentCall({
    required String ownerId,
    required String participantName,
    required bool isVideo,
    required String status,
    required Future<void> Function() onResume,
  }) {
    _presentationOwnerId = ownerId;
    _resumePresentedCall = onResume;
    presentedCallParticipantName.value = participantName.trim().isEmpty
        ? 'Call in progress'
        : participantName.trim();
    presentedCallIsVideo.value = isVideo;
    presentedCallStatus.value = status;
    hasPresentedCall.value = true;
  }

  void updatePresentedCallStatus({
    required String ownerId,
    required String status,
  }) {
    if (_presentationOwnerId != ownerId) {
      return;
    }
    presentedCallStatus.value = status;
  }

  void setPresentedCallScreenVisible({
    required String ownerId,
    required bool isVisible,
  }) {
    if (_presentationOwnerId != ownerId) {
      return;
    }
    isPresentedCallScreenVisible.value = isVisible;
  }

  bool isPresentedScreenVisibleFor(String ownerId) {
    return _presentationOwnerId == ownerId &&
        isPresentedCallScreenVisible.value;
  }

  Future<void> resumePresentedCall() async {
    final Future<void> Function()? resumeAction = _resumePresentedCall;
    if (resumeAction == null || isPresentedCallScreenVisible.value) {
      return;
    }
    await resumeAction();
  }

  void clearPresentedCall(String ownerId) {
    if (_presentationOwnerId != ownerId) {
      return;
    }

    _presentationOwnerId = null;
    _resumePresentedCall = null;
    hasPresentedCall.value = false;
    isPresentedCallScreenVisible.value = false;
    presentedCallIsVideo.value = false;
    presentedCallStatus.value = '';
    presentedCallParticipantName.value = '';
  }

  Future<void> resetForLogout() async {
    _activeIncomingCallId = null;
    _presentationOwnerId = null;
    _resumePresentedCall = null;
    _incomingController = null;

    _incomingRouteVisible = false;
    _isOpeningAcceptedCall = false;
    _restoreInProgress = false;
    _incomingAcknowledgements.clear();
    _acceptedIncomingCallIds.clear();
    _remotelyTerminatedIncomingCallIds.clear();
    _nativeAcceptFuture = null;
    _nativeAcceptCallId = null;

    isCallTransitioning.value = false;
    hasPresentedCall.value = false;
    isPresentedCallScreenVisible.value = false;
    presentedCallIsVideo.value = false;
    presentedCallStatus.value = '';
    presentedCallParticipantName.value = '';

    await CallkitPendingActionStore.clear();

    try {
      await CallkitIncomingService.endAllCalls();
    } catch (_) {}

    if (Get.isRegistered<MessageIncomingCallController>()) {
      await Get.delete<MessageIncomingCallController>(force: true);
    }
  }

  Future<void> _connectCallSocket() async {
    try {
      await _callSocketService.connect();
      await restoreNativeIncomingCall();
    } catch (_) {
      // Login/bootstrap reconnects the socket once a valid token is available.
    }
  }

  /// Acknowledge a CallKit/PushKit call as soon as CallKit has displayed it.
  /// This deliberately does not wait for the Flutter incoming route, which is
  /// unavailable while iOS keeps the app locked in the background.
  Future<void> acknowledgeNativeIncomingCall(String callId) {
    final String normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) {
      return Future<void>.value();
    }

    final Future<void>? existing = _incomingAcknowledgements[normalizedCallId];
    if (existing != null) {
      return existing;
    }

    final Future<void> acknowledgement = _callSocketService
        .acknowledgeIncomingCall(callId: normalizedCallId);
    _incomingAcknowledgements[normalizedCallId] = acknowledgement;

    return acknowledgement.whenComplete(() {
      if (identical(
        _incomingAcknowledgements[normalizedCallId],
        acknowledgement,
      )) {
        _incomingAcknowledgements.remove(normalizedCallId);
      }
    });
  }

  Future<void> _restoreNativeIncomingCallAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await restoreNativeIncomingCall();
  }

  void _handleIncomingCall(Map<String, dynamic> payload) {
    final String callId = _eventCallId(payload);
    if (callId.isEmpty || _remotelyTerminatedIncomingCallIds.contains(callId)) {
      return;
    }

    final AppLifecycleState? lifecycleState =
        WidgetsBinding.instance.lifecycleState;
    if (lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    unawaited(_openIncomingCall(payload, showNativeRingtone: true));
  }

  void _handleRemoteIncomingCallClosed(Map<String, dynamic> payload) {
    final String callId = _eventCallId(payload);
    if (callId.isEmpty) {
      return;
    }

    _remotelyTerminatedIncomingCallIds.add(callId);
    unawaited(_closeRemotelyTerminatedIncomingCall(callId));
  }

  Future<void> _closeRemotelyTerminatedIncomingCall(String callId) async {
    dismissIncomingCall(callId);
    try {
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
    } catch (_) {}
  }

  Future<void> openNativeIncomingCall({
    required String callId,
    required Map<String, dynamic> callData,
  }) async {
    final String normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) {
      return;
    }

    await _openIncomingCall(
      _payloadFromNativeData(normalizedCallId, callData),
      showNativeRingtone: false,
    );
  }

  Future<void> restoreNativeIncomingCall() async {
    if (_activeIncomingCallId != null || _isOpeningAcceptedCall) {
      return;
    }

    try {
      final List<CallKitParams> calls =
          await CallkitIncomingService.activeNativeCalls();
      CallKitParams? incomingCall;
      for (final CallKitParams call in calls) {
        if (!call.isAccepted) {
          incomingCall = call;
          break;
        }
      }

      if (incomingCall == null) {
        return;
      }

      final String callId = incomingCall.id.trim();
      if (callId.isEmpty ||
          _remotelyTerminatedIncomingCallIds.contains(callId) ||
          !await _isIncomingCallStillRinging(callId)) {
        return;
      }

      await openNativeIncomingCall(
        callId: callId,
        callData: _toMap(incomingCall.extra),
      );
    } catch (_) {}
  }

  Future<bool> _isIncomingCallStillRinging(String callId) async {
    try {
      final Map<String, dynamic> response = await _callSocketService.fetchCall(
        callId: callId,
      );
      final Map<String, dynamic> call = _toMap(response['call']);
      final String status =
          call['status']?.toString().trim().toLowerCase() ?? '';

      if (status == 'ringing') {
        return true;
      }

      _remotelyTerminatedIncomingCallIds.add(callId);
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
      return false;
    } on CallSocketException catch (error) {
      if (error.code == 'CALL_NOT_FOUND') {
        _remotelyTerminatedIncomingCallIds.add(callId);
        await CallkitIncomingService.endNativeSubsystemOnly(callId);
        return false;
      }

      return true;
    }
  }

  Future<void> _openIncomingCall(
    Map<String, dynamic> payload, {
    required bool showNativeRingtone,
  }) async {
    final Map<String, dynamic> call = _toMap(payload['call']);
    final String callId = call['id']?.toString().trim() ?? '';

    if (callId.isEmpty ||
        _activeIncomingCallId == callId ||
        _activeIncomingCallId != null ||
        _isOpeningAcceptedCall) {
      return;
    }

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    if (Get.key.currentState == null) {
      // CallKit remains the source of truth until GetMaterialApp mounts. The
      // post-frame restoration path will open the Flutter incoming-call page.
      return;
    }

    _activeIncomingCallId = callId;

    try {
      // First show the incoming call and start the receiver ringtone.
      if (showNativeRingtone) {
        try {
          await CallkitIncomingService.showIncomingCallFromSocketPayload(
            payload,
          );
        } catch (_) {}
      }

      // Now tell the backend that the receiver device is actually ringing.
      try {
        await acknowledgeNativeIncomingCall(callId);
      } catch (_) {}

      if (Get.isRegistered<MessageIncomingCallController>()) {
        await Get.delete<MessageIncomingCallController>(force: true);
      }

      final MessageIncomingCallController controller =
          MessageIncomingCallController(
            payload: payload,
            callSocketService: _callSocketService,
            callAgoraService: Get.find<CallAgoraService>(),
            onAccepted: (Map<String, dynamic> answerResponse) async {
              _acceptedIncomingCallIds.add(callId);
              final Map<String, dynamic> callData = <String, dynamic>{
                ..._flattenCallPayload(payload),
                '_replaceCurrentCallRoute': true,
              };
              await _detachIncomingForAccepted(callId);
              await _acceptedCallHandler(
                callId: callId,
                callData: callData,
                answerResponse: answerResponse,
              );
            },
            onFinished: () => _finishIncomingCall(callId),
            onStatusChanged: (String status) {
              updatePresentedCallStatus(
                ownerId: _incomingOwnerId(callId),
                status: status,
              );
            },
          );

      _incomingController = controller;
      Get.put<MessageIncomingCallController>(controller, permanent: true);

      final String ownerId = _incomingOwnerId(callId);
      presentCall(
        ownerId: ownerId,
        participantName: controller.caller.name,
        isVideo: controller.callType.isVideo,
        status: controller.statusLabel.value,
        onResume: () => _showIncomingCallRoute(callId),
      );

      await _showIncomingCallRoute(callId);
    } catch (_) {
      await _finishIncomingCall(callId);
      rethrow;
    }
  }

  Future<void> _showIncomingCallRoute(String callId) async {
    final MessageIncomingCallController? controller = _incomingController;
    if (controller == null ||
        controller.isClosed ||
        _activeIncomingCallId != callId ||
        _incomingRouteVisible) {
      return;
    }

    final String ownerId = _incomingOwnerId(callId);
    _incomingRouteVisible = true;
    setPresentedCallScreenVisible(ownerId: ownerId, isVisible: true);

    try {
      await Get.to<void>(
        () => MessageIncomingCallView(controller: controller),
        transition: Transition.downToUp,
        fullscreenDialog: true,
      );
    } finally {
      _incomingRouteVisible = false;
      setPresentedCallScreenVisible(ownerId: ownerId, isVisible: false);
    }
  }

  Future<void> _finishIncomingCall(String callId) async {
    if (_activeIncomingCallId != callId) {
      return;
    }

    final String ownerId = _incomingOwnerId(callId);
    final bool shouldCloseRoute =
        _incomingRouteVisible &&
        isPresentedScreenVisibleFor(ownerId) &&
        Get.key.currentState?.canPop() == true;

    final MessageIncomingCallController? completedController =
        _incomingController;
    _activeIncomingCallId = null;
    _incomingController = null;
    clearPresentedCall(ownerId);

    if (shouldCloseRoute) {
      Get.back<void>();
    }

    await CallkitIncomingService.endNativeSubsystemOnly(callId);
    _scheduleIncomingControllerDeletion(completedController);
  }

  Future<void> _detachIncomingForAccepted(String callId) async {
    if (_activeIncomingCallId != callId) {
      return;
    }

    final MessageIncomingCallController? completedController =
        _incomingController;
    clearPresentedCall(_incomingOwnerId(callId));
    _activeIncomingCallId = null;
    _incomingController = null;
    _incomingRouteVisible = false;
    _scheduleIncomingControllerDeletion(completedController);
  }

  void _scheduleIncomingControllerDeletion(
    MessageIncomingCallController? completedController,
  ) {
    if (completedController == null) {
      return;
    }

    Future<void>.delayed(const Duration(milliseconds: 400), () async {
      if (Get.isRegistered<MessageIncomingCallController>() &&
          identical(
            Get.find<MessageIncomingCallController>(),
            completedController,
          )) {
        await Get.delete<MessageIncomingCallController>(force: true);
      }
    });
  }

  void dismissIncomingCall(String callId) {
    if (_activeIncomingCallId != callId.trim() ||
        !Get.isRegistered<MessageIncomingCallController>()) {
      return;
    }

    Get.find<MessageIncomingCallController>().closeFromNativeAction();
  }

  Future<void> acceptNativeCall({
    required String callId,
    required Map<String, dynamic> callData,
    Map<String, dynamic> answerResponse = const <String, dynamic>{},
  }) async {
    final String normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) {
      return;
    }

    if (_acceptedIncomingCallIds.contains(normalizedCallId)) {
      // This is the native confirmation generated by setCallConnected after
      // the Flutter incoming screen has already answered the same call.
      await CallkitIncomingService.completeNativeAnswer(normalizedCallId);
      await CallkitPendingActionStore.clearAcceptedCall();
      return;
    }

    final Future<void>? existing = _nativeAcceptFuture;
    if (existing != null) {
      // Native events may be duplicated when CallKit, app resume, and the
      // pending-action store race. Coalesce the same answer instead of
      // issuing a second backend answer or replacing an Agora controller.
      if (_nativeAcceptCallId == normalizedCallId) {
        await existing;
      }
      return;
    }

    _acceptedIncomingCallIds.add(normalizedCallId);
    _nativeAcceptCallId = normalizedCallId;
    final Future<void> acceptFuture = _performNativeAccept(
      callId: normalizedCallId,
      callData: callData,
      answerResponse: answerResponse,
    );
    _nativeAcceptFuture = acceptFuture;

    try {
      await acceptFuture;
    } finally {
      if (identical(_nativeAcceptFuture, acceptFuture)) {
        _nativeAcceptFuture = null;
        _nativeAcceptCallId = null;
      }
    }
  }

  Future<void> _performNativeAccept({
    required String callId,
    required Map<String, dynamic> callData,
    required Map<String, dynamic> answerResponse,
  }) async {
    _isOpeningAcceptedCall = true;
    isCallTransitioning.value = true;
    bool wasAnswered = answerResponse.isNotEmpty;

    try {
      developer.log(
        'accept begin callId=$callId hasAnswer=${answerResponse.isNotEmpty}',
        name: 'CallLifecycle.Accept',
      );
      await _waitForForeground();

      final MessageCallType callType = MessageCallType.fromValue(
        callData['callType']?.toString(),
      );

      // A CallKit answer is already final from the user's point of view.
      // Acknowledge it to the backend before local media setup so a locked
      // device cannot accidentally turn Answer into Decline while waiting on
      // Flutter UI, permissions, or Agora initialization.
      final Map<String, dynamic> resolvedAnswer = answerResponse.isNotEmpty
          ? answerResponse
          : await _callSocketService.answerCallOverHttp(callId: callId);
      wasAnswered = true;
      developer.log(
        'backend answer complete callId=$callId',
        name: 'CallLifecycle.Accept',
      );

      await Get.find<CallAgoraService>().ensurePermissionsForCall(
        isVideoCall: callType.isVideo,
      );
      developer.log(
        'permissions ready callId=$callId video=${callType.isVideo}',
        name: 'CallLifecycle.Accept',
      );

      final MessageCallMediaModel media = MessageCallMediaModel.fromJson(
        _toMap(resolvedAnswer['media']),
      );
      await Get.find<CallAgoraService>().prepareCallKitEngine(
        appId: media.appId,
        isVideoCall: callType.isVideo,
      );

      // Native CallKit has already fulfilled the answer action promptly, as
      // required by iOS. Agora was prepared before this point when the main
      // engine handled the event; cold starts replay activation after attach.
      final bool audioSessionActivated =
          await CallkitIncomingService.waitForIosAudioSessionActivation();
      if (!audioSessionActivated) {
        // Do not terminate an answered call merely because Dart missed or
        // received CallKit's activation event late. Agora can join now and
        // the native activation callback is replayed once media is attached.
        developer.log(
          'audio activation not observed before timeout; continuing callId=$callId',
          name: 'CallLifecycle.Accept',
        );
      } else {
        developer.log(
          'audio session active callId=$callId',
          name: 'CallLifecycle.Accept',
        );
      }

      final bool replaceCurrentRoute = _incomingRouteVisible;
      await _detachIncomingForAccepted(callId);

      // CallKit owns the iOS audio session for the lifetime of an answered
      // call. Ending it here deactivates audio before Agora can connect.
      if (!Platform.isIOS) {
        await CallkitIncomingService.endNativeSubsystemOnly(callId);
      }

      await _acceptedCallHandler(
        callId: callId,
        callData: <String, dynamic>{
          ...callData,
          '_replaceCurrentCallRoute': replaceCurrentRoute,
        },
        answerResponse: resolvedAnswer,
      );
      developer.log(
        'accepted controller started callId=$callId',
        name: 'CallLifecycle.Accept',
      );
      await CallkitPendingActionStore.clearAcceptedCall();
    } on CallSocketException catch (error) {
      await _handleNativeAcceptFailure(
        callId: callId,
        wasAnswered: wasAnswered,
        message: error.toString(),
      );
      await CallkitPendingActionStore.clearAcceptedCall();
    } catch (error) {
      await _handleNativeAcceptFailure(
        callId: callId,
        wasAnswered: wasAnswered,
        message: error.toString(),
      );
      await CallkitPendingActionStore.clearAcceptedCall();
    } finally {
      _isOpeningAcceptedCall = false;
      isCallTransitioning.value = false;
    }
  }

  Future<void> _handleNativeAcceptFailure({
    required String callId,
    required bool wasAnswered,
    required String message,
  }) async {
    developer.log(
      'accept failed callId=$callId wasAnswered=$wasAnswered message=$message',
      name: 'CallLifecycle.Accept',
      level: 1000,
    );
    _acceptedIncomingCallIds.remove(callId);
    await CallkitIncomingService.failNativeAnswer(callId);

    try {
      if (wasAnswered) {
        await _callSocketService.endCallOverHttp(callId: callId);
      } else {
        await _callSocketService.rejectCallOverHttp(callId: callId);
      }
    } catch (_) {}

    await _finishIncomingCall(callId);
    await CallkitIncomingService.endNativeSubsystemOnly(callId);

    if (Get.context != null) {
      Get.snackbar(
        'Unable to answer',
        message.replaceFirst('CallAgoraException: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> restorePendingAcceptedCall({
    Duration waitForBackgroundHandler = Duration.zero,
  }) async {
    if (_restoreInProgress || _isOpeningAcceptedCall) {
      return false;
    }

    _restoreInProgress = true;
    final DateTime deadline = DateTime.now().add(waitForBackgroundHandler);

    try {
      do {
        final bool waitingForBackgroundAnswer =
            Platform.isIOS && DateTime.now().isBefore(deadline);
        final PendingAcceptedCall? pending =
            await CallkitPendingActionStore.takeAcceptedCall(
              requireAnswerResponse: waitingForBackgroundAnswer,
            );

        if (pending != null) {
          if (!await _canRestoreAcceptedCall(pending.callId)) {
            await CallkitIncomingService.endNativeSubsystemOnly(pending.callId);
            return false;
          }
          await acceptNativeCall(
            callId: pending.callId,
            callData: pending.callData,
            answerResponse: pending.answerResponse,
          );
          return true;
        }

        if (waitingForBackgroundAnswer &&
            await CallkitPendingActionStore.hasAcceptedCall()) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          continue;
        }

        List<CallKitParams> acceptedNativeCalls = <CallKitParams>[];
        try {
          acceptedNativeCalls =
              await CallkitIncomingService.acceptedNativeCalls();
        } catch (_) {}

        if (acceptedNativeCalls.isNotEmpty) {
          final CallKitParams nativeCall = acceptedNativeCalls.first;
          final String nativeCallId = nativeCall.id.trim();

          if (nativeCallId.isNotEmpty) {
            if (!await _canRestoreAcceptedCall(nativeCallId)) {
              await CallkitIncomingService.endNativeSubsystemOnly(nativeCallId);
              return false;
            }
            await acceptNativeCall(
              callId: nativeCallId,
              callData: _toMap(nativeCall.extra),
            );
            return true;
          }
        }

        if (!DateTime.now().isBefore(deadline)) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      } while (true);

      return false;
    } finally {
      _restoreInProgress = false;
    }
  }

  Future<bool> _canRestoreAcceptedCall(String callId) async {
    try {
      final Map<String, dynamic> response = await _callSocketService.fetchCall(
        callId: callId,
      );
      final String status =
          _toMap(response['call'])['status']?.toString().toLowerCase() ?? '';
      return status == 'ringing' || status == 'active';
    } on CallSocketException catch (error) {
      return error.code != 'CALL_NOT_FOUND';
    } catch (_) {
      // A temporary network failure must not discard a legitimate lock-screen
      // answer; normal status polling will reconcile it once connected.
      return true;
    }
  }

  Future<void> _waitForForeground() async {
    if (Platform.isIOS) {
      // CallKit intentionally supports answering while the device remains
      // locked and no UIWindow/Navigator is attached. Media setup must be
      // headless; openCallScreen() will present later when iOS resumes.
      return;
    }

    for (int attempt = 0; attempt < 300; attempt++) {
      final bool navigatorReady = Get.key.currentState != null;
      final bool lifecycleReady =
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

      if (navigatorReady && lifecycleReady) {
        // Give Android enough time to attach the resumed Activity before
        // permission_handler opens a runtime permission dialog.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    throw const CallAgoraException(
      'Open the app to allow microphone and camera access before answering.',
    );
  }

  Future<void> reconnectAfterLogin() async {
    await _callSocketService.refreshConnectionAfterLogin();
    await restoreNativeIncomingCall();
  }

  static String _incomingOwnerId(String callId) => 'incoming:$callId';

  static String _eventCallId(Map<String, dynamic> payload) {
    final Map<String, dynamic> call = _toMap(payload['call']);
    return (call['id']?.toString() ?? payload['callId']?.toString() ?? '')
        .trim();
  }

  static Map<String, dynamic> _payloadFromNativeData(
    String callId,
    Map<String, dynamic> data,
  ) {
    return <String, dynamic>{
      'call': <String, dynamic>{
        'id': callId,
        'directConversationId': data['conversationId']?.toString() ?? '',
        'callType': data['callType']?.toString() ?? 'audio',
        'callerId': data['callerId']?.toString() ?? '',
      },
      'caller': <String, dynamic>{
        'id': data['callerId']?.toString() ?? '',
        'fullName': data['callerName']?.toString() ?? 'Caller',
        'avatarUrl': data['callerAvatarUrl']?.toString() ?? '',
      },
    };
  }

  static Map<String, dynamic> _flattenCallPayload(
    Map<String, dynamic> payload,
  ) {
    final Map<String, dynamic> call = _toMap(payload['call']);
    final Map<String, dynamic> caller = _toMap(payload['caller']);

    return <String, dynamic>{
      'callId': call['id']?.toString() ?? '',
      'conversationId': call['directConversationId']?.toString() ?? '',
      'callType': call['callType']?.toString() ?? 'audio',
      'callerId':
          caller['id']?.toString() ?? call['callerId']?.toString() ?? '',
      'callerName': caller['fullName']?.toString() ?? 'Caller',
      'callerAvatarUrl': caller['avatarUrl']?.toString() ?? '',
    };
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _callSocketService.removeIncomingCallListener(_incomingCallListener);
    _callSocketService.removeCancelledCallListener(_cancelledCallListener);
    _callSocketService.removeEndedCallListener(_endedCallListener);
    super.onClose();
  }
}
