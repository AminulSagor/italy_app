import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/services/callkit_incoming_service.dart';
import '../models/message_call_models.dart';
import '../service/call_agora_service.dart';
import '../service/call_proximity_service.dart';
import '../service/call_ringback_service.dart';
import '../service/call_socket_service.dart';
import '../service/full_screen_call_permission_service.dart';
import '../service/incoming_call_coordinator.dart';
import '../views/message_call_view.dart';
import 'message_call_duration_tracker.dart';

part 'message_call_controller_media.dart';
part 'message_call_controller_presentation.dart';

class MessageCallController extends GetxController with WidgetsBindingObserver {
  MessageCallController({
    required this.conversationId,
    required this.callType,
    required this.participant,
    required CallSocketService callSocketService,
    required CallAgoraService callAgoraService,
    MessageCallSessionModel? initialSession,
  }) : _callSocketService = callSocketService,
       _callAgoraService = callAgoraService,
       _initialSession = initialSession;

  static const Duration _terminalStateDelay = Duration(seconds: 2);
  static const Duration _heartbeatInterval = Duration(seconds: 20);
  static const Duration _remoteDisconnectGrace = Duration(seconds: 20);
  static const Set<String> _terminalStatuses = <String>{
    'rejected',
    'cancelled',
    'ended',
    'missed',
    'failed',
  };

  final String conversationId;
  final MessageCallType callType;
  final MessageCallParticipantModel participant;
  final CallSocketService _callSocketService;
  final CallAgoraService _callAgoraService;
  final CallRingbackService _ringbackService = CallRingbackService();
  final MessageCallSessionModel? _initialSession;
  final MessageCallDurationTracker _durationTracker =
      MessageCallDurationTracker();
  final String _presentationId = 'message-call-${const Uuid().v4()}';
  final CallProximityService _proximityService = CallProximityService();

  late final IncomingCallCoordinator _callCoordinator;
  late final Worker _statusWorker;
  late final Worker _remoteUidWorker;
  late final Worker _cameraWorker;

  final RxBool isLoading = false.obs;
  final RxBool isEnding = false.obs;
  final RxBool isActive = false.obs;
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxBool isCameraOff = true.obs;
  final RxBool isFrontCamera = true.obs;
  final RxString durationLabel = 'loading'.tr.obs;
  final Rxn<MessageCallSessionModel> callSession =
      Rxn<MessageCallSessionModel>();

  late final Future<void> _startCallFuture;
  late final CallSocketListener _ringingCallListener;
  late final CallSocketListener _answeredCallListener;
  late final CallSocketListener _rejectedCallListener;
  late final CallSocketListener _endedCallListener;

  String? _callId;
  Timer? _statusPollTimer;
  Timer? _ringingTimeoutTimer;
  Timer? _heartbeatTimer;
  Timer? _remoteDisconnectTimer;
  Future<void>? _terminalCloseFuture;
  Future<void>? _localPreviewFuture;
  bool _statusPollInProgress = false;
  bool _heartbeatInProgress = false;
  bool _hasRemoteParticipantJoined = false;
  bool _mediaJoinInProgress = false;
  bool _endRequested = false;
  bool _terminationSent = false;
  bool _remoteTerminal = false;
  bool _routeClosed = false;
  bool _nativeCallEndedLocally = false;
  bool _resumeVideoActivationInProgress = false;

  CallAgoraService get agora => _callAgoraService;
  RtcEngine? get agoraEngine => _callAgoraService.engine;
  String? get agoraChannelName => _callAgoraService.channelName;

  final FullScreenCallPermissionService _fullScreenCallPermissionService =
      FullScreenCallPermissionService();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _ringingCallListener = _handleCallRinging;
    _answeredCallListener = _handleCallAnswered;
    _rejectedCallListener = _handleCallRejected;
    _endedCallListener = _handleCallEnded;

    _callSocketService.addRingingCallListener(_ringingCallListener);
    _callSocketService.addAnsweredCallListener(_answeredCallListener);
    _callSocketService.addRejectedCallListener(_rejectedCallListener);
    _callSocketService.addEndedCallListener(_endedCallListener);

    _callCoordinator = Get.find<IncomingCallCoordinator>();
    _callCoordinator.presentCall(
      ownerId: _presentationId,
      participantName: participant.name,
      isVideo: callType.isVideo,
      status: durationLabel.value,
      onResume: openCallScreen,
    );
    _statusWorker = ever<String>(durationLabel, (String status) {
      _callCoordinator.updatePresentedCallStatus(
        ownerId: _presentationId,
        status: status,
      );
    });
    _remoteUidWorker = ever<int?>(
      _callAgoraService.remoteUid,
      _handleRemoteUidChanged,
    );
    _cameraWorker = ever<bool>(_callAgoraService.isCameraEnabled, (
      bool enabled,
    ) {
      if (callType.isVideo) {
        isCameraOff.value = !enabled;
      }
    });

    final MessageCallSessionModel? session = _initialSession;
    _startCallFuture = session == null
        ? startCall()
        : _startAcceptedCall(session);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        !callType.isVideo ||
        !isActive.value ||
        !_callAgoraService.videoPublishDesired ||
        isEnding.value ||
        _routeClosed ||
        _resumeVideoActivationInProgress) {
      return;
    }

    _resumeVideoActivationInProgress = true;
    unawaited(
      _activateVideoAfterResume().whenComplete(() {
        _resumeVideoActivationInProgress = false;
      }),
    );
  }

  Future<void> _activateVideoAfterResume() async {
    try {
      await _startCallFuture.timeout(const Duration(seconds: 20));
    } on TimeoutException {
      return;
    } catch (_) {
      return;
    }

    if (!isActive.value ||
        !_callAgoraService.videoPublishDesired ||
        isEnding.value ||
        _routeClosed ||
        _remoteTerminal) {
      return;
    }

    await _activateVideoIfNeeded();
  }

  Future<void> startCall() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    durationLabel.value = 'loading'.tr;

    try {
      // Ask for full-screen incoming-call permission only when
      // the user starts their first outgoing call.
      await _fullScreenCallPermissionService.requestWhenStartingFirstCall();

      if (_endRequested || _routeClosed || _remoteTerminal) {
        return;
      }

      // Request microphone permission for audio calls.
      // Request microphone and camera permissions for video calls.
      await _callAgoraService.ensurePermissionsForCall(
        isVideoCall: callType.isVideo,
      );

      if (_endRequested || _routeClosed || _remoteTerminal) {
        return;
      }

      // The request is now being sent to the server.
      durationLabel.value = 'calling'.tr;
      await _ringbackService.startCalling(forceRestart: true);

      final Map<String, dynamic> response = await _callSocketService
          .initiateCall(
            conversationId: conversationId,
            callType: callType.value,
            clientCallId: const Uuid().v4(),
          );

      final MessageCallSessionModel session =
          MessageCallSessionModel.fromInitiateResponse(
            response: response,
            participant: participant,
          );

      if (session.id.isEmpty) {
        throw CallSocketException(
          code: 'call_id_missing'.tr,
          message: 'the_server_did_not_return_a_call_id'.tr,
        );
      }

      _callId = session.id;
      callSession.value = session;

      final bool receiverIsRinging = response['foregroundAcknowledged'] == true;

      if (_endRequested || _routeClosed || _remoteTerminal) {
        await _terminateCall(showError: false);
        return;
      }

      if (_terminalStatuses.contains(session.status)) {
        _terminationSent = true;
        _remoteTerminal = true;

        await _showTerminalState(_labelForStatus(session.status));

        return;
      }

      if (callType.isVideo) {
        final Future<void> previewFuture = _prepareOutgoingVideoPreview(
          session,
        );

        _localPreviewFuture = previewFuture;

        unawaited(previewFuture);
      }

      if (receiverIsRinging) {
        await _enterRingingState();
      }

      _startCallStatusPolling();
      _startRingingTimeout();
    } on CallSocketException catch (error) {
      await _handleStartFailure(error.message);
    } catch (error) {
      await _handleStartFailure(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _startAcceptedCall(MessageCallSessionModel session) async {
    isLoading.value = true;
    isActive.value = true;
    durationLabel.value = 'loading'.tr;
    _callId = session.id;
    callSession.value = session;
    _startHeartbeat();
    _startCallStatusPolling();

    try {
      await _joinMedia(session);
      if (_routeClosed || _remoteTerminal || _endRequested) {
        return;
      }

      await CallkitIncomingService.markCallConnected(session.id);
      // Keep the iOS reconciliation poll alive during an active call. A
      // lock-screened app can miss the receiver's socket `call:ended` event;
      // this closes the caller's Agora session on the next authoritative
      // status response instead of leaving the first call running.
      if (!Platform.isIOS) {
        _stopCallStatusPolling();
      }
      _startDurationTimer();
      await _activateVideoIfNeeded();
    } on CallAgoraException catch (error) {
      await _handleMediaFailure(error.message);
    } catch (error) {
      await _handleMediaFailure(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _handleCallRinging(Map<String, dynamic> payload) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    unawaited(_enterRingingState());
  }

  Future<void> _enterRingingState() async {
    if (_routeClosed ||
        _remoteTerminal ||
        _endRequested ||
        isEnding.value ||
        isActive.value) {
      return;
    }

    durationLabel.value = 'ringing'.tr;

    // Agora may currently be taking control of the audio session.
    // The correct sound will be restarted after joining finishes.
    if (_mediaJoinInProgress) {
      return;
    }

    await _ringbackService.startRinging(forceRestart: true);
  }

  void _handleCallAnswered(Map<String, dynamic> payload) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    unawaited(_connectAnsweredOutgoingCall());
  }

  Future<void> _connectAnsweredOutgoingCall() async {
    final MessageCallSessionModel? session = callSession.value;

    if (session == null ||
        _mediaJoinInProgress ||
        _routeClosed ||
        _remoteTerminal ||
        _endRequested ||
        isActive.value) {
      return;
    }

    // Prevent duplicate socket and polling events from
    // starting Agora more than once.
    isActive.value = true;
    isLoading.value = true;
    durationLabel.value = 'loading'.tr;
    _startHeartbeat();

    _stopRingingTimeout();

    // Completely stop the MP3 before enabling Agora audio.
    await _ringbackService.stop();

    try {
      final Future<void>? previewFuture = _localPreviewFuture;

      if (previewFuture != null) {
        await previewFuture;
      }

      if (_routeClosed || _remoteTerminal || _endRequested) {
        return;
      }

      if (!_callAgoraService.isJoined.value) {
        await _joinMedia(session);
      } else {
        _syncMediaControls();
      }

      if (_routeClosed || _remoteTerminal || _endRequested) {
        return;
      }

      // See _startAcceptedCall: iOS needs this fallback while backgrounded.
      if (!Platform.isIOS) {
        _stopCallStatusPolling();
      }
      _startDurationTimer();

      await _activateVideoIfNeeded();
    } on CallAgoraException catch (error) {
      await _handleMediaFailure(error.message);
    } catch (error) {
      await _handleMediaFailure(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Called for a local CallKit hang-up. The native action has already been
  /// accepted by CallKit, so only tear down this controller's media/UI; the
  /// normal event handler synchronizes the backend independently.
  void closeFromNativeEnd(String callId) {
    if (callId.trim().isEmpty || callId.trim() != _callId || _routeClosed) {
      return;
    }

    _terminationSent = true;
    _remoteTerminal = true;
    _nativeCallEndedLocally = true;
    isActive.value = false;
    unawaited(_showTerminalState('call_ended'.tr));
  }

  Future<void> _joinMedia(MessageCallSessionModel session) async {
    _mediaJoinInProgress = true;
    try {
      await _callAgoraService.joinCall(
        media: session.media,
        isVideoCall: callType.isVideo,
        isCallKitAudioSessionManaged: Platform.isIOS && _initialSession != null,
        tokenProvider: () => _renewAgoraMediaToken(session.id),
      );
      _syncMediaControls();
      await _syncProximityLock();
    } finally {
      _mediaJoinInProgress = false;
    }
  }

  Future<MessageCallMediaModel> _renewAgoraMediaToken(String callId) async {
    final Map<String, dynamic> response = await _callSocketService
        .renewMediaToken(callId: callId);
    final MessageCallMediaModel renewed = MessageCallMediaModel.fromJson(
      _toMap(response['media']),
    );

    if (renewed.token.trim().isEmpty) {
      throw const CallSocketException(
        code: 'INVALID_MEDIA_TOKEN',
        message: 'The server returned an invalid media token.',
      );
    }

    return renewed;
  }

  Future<void> _handleStartFailure(String message) async {
    await _cancelAfterStartFailure().timeout(
      const Duration(seconds: 2),
      onTimeout: () {},
    );
    if (_endRequested || _routeClosed || _remoteTerminal) {
      return;
    }

    Get.snackbar(
      'call_failed'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
    await _showTerminalState('call_failed'.tr);
  }

  Future<void> _handleMediaFailure(String message) async {
    if (_routeClosed || _remoteTerminal || _endRequested) {
      return;
    }

    await _endAfterMediaFailure().timeout(
      const Duration(seconds: 2),
      onTimeout: () {},
    );
    Get.snackbar(
      'call_failed'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
    await _showTerminalState('call_failed'.tr);
  }

  void _handleCallRejected(Map<String, dynamic> payload) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    _terminationSent = true;
    _remoteTerminal = true;
    isActive.value = false;
    unawaited(_showTerminalState('call_declined'.tr));
  }

  void _handleCallEnded(Map<String, dynamic> payload) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    _terminationSent = true;
    _remoteTerminal = true;
    isActive.value = false;

    final Map<String, dynamic> call = _toMap(payload['call']);
    final bool timedOut =
        payload['reason']?.toString() == 'timeout' ||
        call['status']?.toString() == 'missed';
    unawaited(
      _showTerminalState(timedOut ? 'missed_call'.tr : 'call_ended'.tr),
    );
  }

  bool _matchesCurrentCall(Map<String, dynamic> payload) {
    final Map<String, dynamic> call = _toMap(payload['call']);
    final String eventCallId =
        call['id']?.toString() ?? payload['callId']?.toString() ?? '';
    return eventCallId.isNotEmpty && eventCallId == _callId;
  }

  Future<void> _showTerminalState(String message) {
    if (_routeClosed) {
      return Future<void>.value();
    }

    final Future<void>? existing = _terminalCloseFuture;
    if (existing != null) {
      return existing;
    }

    final Future<void> closeFuture = _performTerminalClose(message);
    _terminalCloseFuture = closeFuture;
    return closeFuture;
  }

  Future<void> _performTerminalClose(String message) async {
    durationLabel.value = message;
    isLoading.value = false;
    isEnding.value = true;
    _stopAllTimers();
    await _leaveMediaSafely();
    await _endNativeCallSafely();
    await Future<void>.delayed(_terminalStateDelay);
    _closeRoute();
  }

  void _startCallStatusPolling() {
    if (_statusPollTimer != null) {
      return;
    }

    unawaited(_pollCallStatus());
    _statusPollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_pollCallStatus()),
    );
  }

  Future<void> _pollCallStatus() async {
    final String? callId = _callId;
    if (_statusPollInProgress ||
        callId == null ||
        callId.isEmpty ||
        _routeClosed) {
      return;
    }

    _statusPollInProgress = true;
    try {
      final Map<String, dynamic> response = await _callSocketService.fetchCall(
        callId: callId,
      );
      final Map<String, dynamic> call = _toMap(response['call']);
      final String status = call['status']?.toString() ?? '';

      if (status == 'active') {
        _stopRingingTimeout();
        if (!isActive.value) {
          unawaited(_connectAnsweredOutgoingCall());
        }
        return;
      }

      if (!_terminalStatuses.contains(status)) {
        return;
      }

      _terminationSent = true;
      _remoteTerminal = true;
      isActive.value = false;
      await _showTerminalState(_labelForStatus(status));
    } catch (_) {
      // Socket events remain the primary path. Polling recovers missed events.
    } finally {
      _statusPollInProgress = false;
    }
  }

  void _startRingingTimeout() {
    if (_ringingTimeoutTimer != null || isActive.value) {
      return;
    }

    _ringingTimeoutTimer = Timer(
      const Duration(minutes: 1),
      () => unawaited(_handleRingingTimeout()),
    );
  }

  Future<void> _handleRingingTimeout() async {
    final String? callId = _callId;
    if (_routeClosed || isActive.value || callId == null || callId.isEmpty) {
      return;
    }

    try {
      final Map<String, dynamic> response = await _callSocketService
          .timeoutCall(callId: callId);
      final Map<String, dynamic> call = _toMap(response['call']);
      if (call['status']?.toString() == 'active') {
        unawaited(_connectAnsweredOutgoingCall());
        return;
      }
    } catch (_) {
      // The server owns the same timeout; polling reconciles races.
    }

    if (_routeClosed || isActive.value) {
      return;
    }

    _terminationSent = true;
    _remoteTerminal = true;
    await _showTerminalState('missed_call'.tr);
  }

  void _startDurationTimer() {
    _durationTracker.start((String value) => durationLabel.value = value);
    _startHeartbeat();
  }

  void _startHeartbeat() {
    if (_heartbeatTimer != null) {
      return;
    }

    unawaited(_sendHeartbeat());
    _heartbeatTimer = Timer.periodic(
      _heartbeatInterval,
      (_) => unawaited(_sendHeartbeat()),
    );
  }

  Future<void> _sendHeartbeat() async {
    final String? callId = _callId;
    if (_heartbeatInProgress ||
        callId == null ||
        callId.isEmpty ||
        !isActive.value ||
        _routeClosed ||
        _remoteTerminal) {
      return;
    }

    _heartbeatInProgress = true;
    try {
      final Map<String, dynamic> response = await _callSocketService
          .heartbeatCall(callId: callId);
      final Map<String, dynamic> call = _toMap(response['call']);
      final String status = call['status']?.toString() ?? '';
      if (!_terminalStatuses.contains(status)) {
        return;
      }

      _terminationSent = true;
      _remoteTerminal = true;
      isActive.value = false;
      await _showTerminalState(_labelForStatus(status));
    } catch (_) {
      // A temporary network failure must not interrupt a working RTC call.
      // The backend lease tolerates several missed heartbeats.
    } finally {
      _heartbeatInProgress = false;
    }
  }

  void _handleRemoteUidChanged(int? remoteUid) {
    if (remoteUid != null) {
      _hasRemoteParticipantJoined = true;
      _remoteDisconnectTimer?.cancel();
      _remoteDisconnectTimer = null;
      return;
    }

    if (!_hasRemoteParticipantJoined ||
        !isActive.value ||
        isEnding.value ||
        _routeClosed ||
        _remoteTerminal) {
      return;
    }

    _remoteDisconnectTimer?.cancel();
    _remoteDisconnectTimer = Timer(
      _remoteDisconnectGrace,
      () => unawaited(_handleRemoteParticipantLost()),
    );
  }

  Future<void> _handleRemoteParticipantLost() async {
    _remoteDisconnectTimer = null;
    if (_callAgoraService.remoteUid.value != null ||
        !isActive.value ||
        isEnding.value ||
        _routeClosed ||
        _remoteTerminal) {
      return;
    }

    await _terminateCall(
      showError: false,
    ).timeout(const Duration(seconds: 2), onTimeout: () {});
    if (_routeClosed || _remoteTerminal) {
      return;
    }

    _remoteTerminal = true;
    isActive.value = false;
    await _showTerminalState('call_ended'.tr);
  }

  Future<void> endCall() async {
    if (isEnding.value || _routeClosed || _remoteTerminal) {
      return;
    }

    isEnding.value = true;
    _endRequested = true;
    durationLabel.value = 'loading'.tr;

    try {
      try {
        await _startCallFuture.timeout(const Duration(seconds: 1));
      } on TimeoutException {
        // Close the screen even if call creation or media setup is delayed.
      }

      await _terminateCall(
        showError: true,
      ).timeout(const Duration(seconds: 2), onTimeout: () {});
    } finally {
      _stopAllTimers();
      await _leaveMediaSafely();
      await _endNativeCallSafely();
      isEnding.value = false;
      _closeRoute();
    }
  }

  Future<void> _terminateCall({required bool showError}) async {
    final String? callId = _callId;
    if (callId == null || callId.isEmpty || _terminationSent) {
      return;
    }

    try {
      if (isActive.value) {
        await _callSocketService.endCall(callId: callId);
      } else {
        await _callSocketService.cancelCall(callId: callId);
      }
      _terminationSent = true;
    } on CallSocketException catch (error) {
      if (await _isCallTerminal(callId)) {
        _terminationSent = true;
        return;
      }

      if (showError && !_routeClosed) {
        Get.snackbar(
          'unable_to_end_call'.tr,
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<bool> _isCallTerminal(String callId) async {
    try {
      final Map<String, dynamic> response = await _callSocketService.fetchCall(
        callId: callId,
      );
      final Map<String, dynamic> call = _toMap(response['call']);
      return _terminalStatuses.contains(call['status']?.toString() ?? '');
    } catch (_) {
      return false;
    }
  }

  Future<void> _cancelAfterStartFailure() async {
    final String? callId = _callId;
    if (callId != null && callId.isNotEmpty && !_terminationSent) {
      try {
        await _callSocketService.cancelCall(callId: callId);
        _terminationSent = true;
      } catch (_) {}
    }
    await _leaveMediaSafely();
  }

  Future<void> _endAfterMediaFailure() async {
    final String? callId = _callId;
    if (callId != null && callId.isNotEmpty && !_terminationSent) {
      try {
        await _callSocketService.endCall(callId: callId);
        _terminationSent = true;
      } catch (_) {}
    }
    await _leaveMediaSafely();
  }

  Future<void> _leaveMediaSafely() async {
    await _proximityService.disable();
    try {
      await _callAgoraService.leaveCall().timeout(const Duration(seconds: 2));
    } catch (_) {
      // Route cleanup must never be blocked by a native media shutdown.
    }
  }

  Future<void> _endNativeCallSafely() async {
    if (_nativeCallEndedLocally) {
      return;
    }

    final String callId = _callId?.trim() ?? '';
    if (callId.isEmpty) {
      return;
    }

    try {
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
    } catch (_) {
      // Native CallKit may already have removed a remotely-ended call.
    }
  }

  void _stopAllTimers() {
    _durationTracker.stop();

    _statusPollTimer?.cancel();
    _statusPollTimer = null;
    _statusPollInProgress = false;

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatInProgress = false;

    _remoteDisconnectTimer?.cancel();
    _remoteDisconnectTimer = null;

    _stopRingingTimeout();

    unawaited(_ringbackService.stop());
  }

  void _stopCallStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
    _statusPollInProgress = false;
  }

  void _stopRingingTimeout() {
    _ringingTimeoutTimer?.cancel();
    _ringingTimeoutTimer = null;
  }

  String _labelForStatus(String status) {
    return switch (status) {
      'rejected' => 'call_declined'.tr,
      'missed' => 'missed_call'.tr,
      'failed' => 'call_failed'.tr,
      _ => 'call_ended'.tr,
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
    _statusWorker.dispose();
    _remoteUidWorker.dispose();
    _cameraWorker.dispose();
    _callCoordinator.clearPresentedCall(_presentationId);
    _callSocketService.removeRingingCallListener(_ringingCallListener);
    _callSocketService.removeAnsweredCallListener(_answeredCallListener);
    _callSocketService.removeRejectedCallListener(_rejectedCallListener);
    _callSocketService.removeEndedCallListener(_endedCallListener);
    _stopAllTimers();
    unawaited(_ringbackService.dispose());

    if (!_terminationSent && _callId?.isNotEmpty == true) {
      unawaited(_terminateCall(showError: false));
    }
    unawaited(_callAgoraService.leaveCall());
    unawaited(_endNativeCallSafely());
    unawaited(_proximityService.disable());
    super.onClose();
  }
}
