import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/message_call_models.dart';
import '../service/call_agora_service.dart';
import '../service/call_socket_service.dart';
import '../service/incoming_call_coordinator.dart';
import '../views/message_call_view.dart';
import 'message_call_duration_tracker.dart';

part 'message_call_controller_media.dart';
part 'message_call_controller_presentation.dart';

class MessageCallController extends GetxController {
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
  final MessageCallSessionModel? _initialSession;
  final MessageCallDurationTracker _durationTracker =
      MessageCallDurationTracker();
  final String _presentationId = 'message-call-${const Uuid().v4()}';

  late final IncomingCallCoordinator _callCoordinator;
  late final Worker _statusWorker;

  final RxBool isLoading = false.obs;
  final RxBool isEnding = false.obs;
  final RxBool isActive = false.obs;
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxBool isCameraOff = true.obs;
  final RxBool isFrontCamera = true.obs;
  final RxString durationLabel = 'Connecting...'.obs;
  final Rxn<MessageCallSessionModel> callSession =
      Rxn<MessageCallSessionModel>();

  late final Future<void> _startCallFuture;
  late final CallSocketListener _answeredCallListener;
  late final CallSocketListener _rejectedCallListener;
  late final CallSocketListener _endedCallListener;

  String? _callId;
  Timer? _statusPollTimer;
  Timer? _ringingTimeoutTimer;
  Future<void>? _terminalCloseFuture;
  bool _statusPollInProgress = false;
  bool _mediaJoinInProgress = false;
  bool _endRequested = false;
  bool _terminationSent = false;
  bool _remoteTerminal = false;
  bool _routeClosed = false;

  CallAgoraService get agora => _callAgoraService;
  RtcEngine? get agoraEngine => _callAgoraService.engine;
  String? get agoraChannelName => _callAgoraService.channelName;

  @override
  void onInit() {
    super.onInit();

    _answeredCallListener = _handleCallAnswered;
    _rejectedCallListener = _handleCallRejected;
    _endedCallListener = _handleCallEnded;

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

    final MessageCallSessionModel? session = _initialSession;
    _startCallFuture = session == null
        ? startCall()
        : _startAcceptedCall(session);
  }

  Future<void> startCall() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    durationLabel.value = 'Connecting...';

    try {
      await _callAgoraService.ensurePermissionsForCall(
        isVideoCall: callType.isVideo,
      );

      final Map<String, dynamic> response =
          await _callSocketService.initiateCall(
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
        throw const CallSocketException(
          code: 'CALL_ID_MISSING',
          message: 'The server did not return a call ID.',
        );
      }

      _callId = session.id;
      callSession.value = session;

      if (_endRequested || _routeClosed) {
        await _terminateCall(showError: false);
        return;
      }

      if (_terminalStatuses.contains(session.status)) {
        _terminationSent = true;
        _remoteTerminal = true;
        await _showTerminalState(_labelForStatus(session.status));
        return;
      }

      durationLabel.value = 'Ringing...';
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
    durationLabel.value = 'Connecting...';
    _callId = session.id;
    callSession.value = session;
    _startCallStatusPolling();

    try {
      await _joinMedia(session);
      if (_routeClosed || _remoteTerminal || _endRequested) {
        return;
      }

      _stopCallStatusPolling();
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
        _callAgoraService.isJoined.value) {
      return;
    }

    _stopRingingTimeout();
    isActive.value = true;
    isLoading.value = true;
    durationLabel.value = 'Connecting...';

    try {
      await _joinMedia(session);
      if (_routeClosed || _remoteTerminal || _endRequested) {
        return;
      }

      _stopCallStatusPolling();
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

  Future<void> _joinMedia(MessageCallSessionModel session) async {
    _mediaJoinInProgress = true;
    try {
      await _callAgoraService.joinCall(
        media: session.media,
        isVideoCall: callType.isVideo,
      );
      _syncMediaControls();
    } finally {
      _mediaJoinInProgress = false;
    }
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
      'Call failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
    await _showTerminalState('Call failed');
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
      'Call failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
    await _showTerminalState('Call failed');
  }

  void _handleCallRejected(Map<String, dynamic> payload) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    _terminationSent = true;
    _remoteTerminal = true;
    isActive.value = false;
    unawaited(_showTerminalState('Call rejected'));
  }

  void _handleCallEnded(Map<String, dynamic> payload) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    _terminationSent = true;
    _remoteTerminal = true;
    isActive.value = false;

    final Map<String, dynamic> call = _toMap(payload['call']);
    final bool timedOut = payload['reason']?.toString() == 'timeout' ||
        call['status']?.toString() == 'missed';
    unawaited(_showTerminalState(timedOut ? 'No answer' : 'Call ended'));
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
      final Map<String, dynamic> response =
          await _callSocketService.fetchCall(callId: callId);
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
    if (_routeClosed ||
        isActive.value ||
        callId == null ||
        callId.isEmpty) {
      return;
    }

    try {
      final Map<String, dynamic> response =
          await _callSocketService.timeoutCall(callId: callId);
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
    await _showTerminalState('No answer');
  }

  void _startDurationTimer() {
    _durationTracker.start((String value) => durationLabel.value = value);
  }

  Future<void> endCall() async {
    if (isEnding.value || _routeClosed || _remoteTerminal) {
      return;
    }

    isEnding.value = true;
    _endRequested = true;
    durationLabel.value = 'Ending...';

    try {
      try {
        await _startCallFuture.timeout(const Duration(seconds: 1));
      } on TimeoutException {
        // Close the screen even if call creation or media setup is delayed.
      }

      await _terminateCall(showError: true).timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
    } finally {
      _stopAllTimers();
      await _leaveMediaSafely();
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
          'Unable to end call',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<bool> _isCallTerminal(String callId) async {
    try {
      final Map<String, dynamic> response =
          await _callSocketService.fetchCall(callId: callId);
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
    try {
      await _callAgoraService.leaveCall().timeout(const Duration(seconds: 2));
    } catch (_) {
      // Route cleanup must never be blocked by a native media shutdown.
    }
  }

  void _stopAllTimers() {
    _durationTracker.stop();
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
    _statusPollInProgress = false;
    _stopRingingTimeout();
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
      'rejected' => 'Call rejected',
      'missed' => 'No answer',
      'failed' => 'Call failed',
      _ => 'Call ended',
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
    _statusWorker.dispose();
    _callCoordinator.clearPresentedCall(_presentationId);
    _callSocketService.removeAnsweredCallListener(_answeredCallListener);
    _callSocketService.removeRejectedCallListener(_rejectedCallListener);
    _callSocketService.removeEndedCallListener(_endedCallListener);
    _stopAllTimers();

    if (!_terminationSent && _callId?.isNotEmpty == true) {
      unawaited(_terminateCall(showError: false));
    }
    unawaited(_callAgoraService.leaveCall());
    super.onClose();
  }
}
