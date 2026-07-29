import 'dart:async';

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

typedef AcceptedCallHandler = Future<void> Function({
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

  late final void Function(Map<String, dynamic>) _incomingCallListener;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _incomingCallListener = _handleIncomingCall;
    _callSocketService.addIncomingCallListener(_incomingCallListener);
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
      await Get.delete<MessageIncomingCallController>(
        force: true,
      );
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

  Future<void> _restoreNativeIncomingCallAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await restoreNativeIncomingCall();
  }

  void _handleIncomingCall(Map<String, dynamic> payload) {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    unawaited(_openIncomingCall(payload, showNativeRingtone: true));
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

      await openNativeIncomingCall(
        callId: incomingCall.id,
        callData: _toMap(incomingCall.extra),
      );
    } catch (_) {
      // The native call may disappear while Android is resuming the activity.
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
        await _callSocketService.acknowledgeIncomingCall(
          callId: callId,
        );
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
    final bool shouldCloseRoute = _incomingRouteVisible &&
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
    if (normalizedCallId.isEmpty || _isOpeningAcceptedCall) {
      return;
    }

    _isOpeningAcceptedCall = true;
    isCallTransitioning.value = true;
    bool wasAnswered = answerResponse.isNotEmpty;

    try {
      await _waitForForeground();

      final MessageCallType callType = MessageCallType.fromValue(
        callData['callType']?.toString(),
      );
      await Get.find<CallAgoraService>().ensurePermissionsForCall(
        isVideoCall: callType.isVideo,
      );

      final Map<String, dynamic> resolvedAnswer = answerResponse.isNotEmpty
          ? answerResponse
          : await _callSocketService.answerCallOverHttp(
              callId: normalizedCallId,
            );
      wasAnswered = true;

      await CallkitPendingActionStore.clear();
      await CallkitIncomingService.markCallConnected(normalizedCallId);
      final bool replaceCurrentRoute = _incomingRouteVisible;
      await _detachIncomingForAccepted(normalizedCallId);
      await CallkitIncomingService.endNativeSubsystemOnly(normalizedCallId);

      await _acceptedCallHandler(
        callId: normalizedCallId,
        callData: <String, dynamic>{
          ...callData,
          '_replaceCurrentCallRoute': replaceCurrentRoute,
        },
        answerResponse: resolvedAnswer,
      );
    } catch (error) {
      await _handleNativeAcceptFailure(
        callId: normalizedCallId,
        wasAnswered: wasAnswered,
        message: error.toString(),
      );
    } finally {
      await CallkitPendingActionStore.clear();
      _isOpeningAcceptedCall = false;
      isCallTransitioning.value = false;
    }
  }

  Future<void> _handleNativeAcceptFailure({
    required String callId,
    required bool wasAnswered,
    required String message,
  }) async {
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
        final PendingAcceptedCall? pending =
            await CallkitPendingActionStore.takeAcceptedCall();

        if (pending != null) {
          await acceptNativeCall(
            callId: pending.callId,
            callData: pending.callData,
            answerResponse: pending.answerResponse,
          );
          return true;
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

  Future<void> _waitForForeground() async {
    for (int attempt = 0; attempt < 300; attempt++) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          Get.key.currentState != null) {
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
      'callerId': caller['id']?.toString() ?? call['callerId']?.toString() ?? '',
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
    super.onClose();
  }
}
