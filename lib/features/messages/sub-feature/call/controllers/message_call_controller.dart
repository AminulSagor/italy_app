import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/message_call_models.dart';
import '../service/call_agora_service.dart';
import '../service/call_socket_service.dart';

class MessageCallController extends GetxController {
  MessageCallController({
    required this.conversationId,
    required this.callType,
    required this.participant,
    required CallSocketService callSocketService,
    required CallAgoraService callAgoraService,
    MessageCallSessionModel? initialSession,
  })  : _callSocketService = callSocketService,
        _callAgoraService = callAgoraService,
        _initialSession = initialSession;

  final String conversationId;
  final MessageCallType callType;
  final MessageCallParticipantModel participant;

  final CallSocketService _callSocketService;
  final CallAgoraService _callAgoraService;
  final MessageCallSessionModel? _initialSession;

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
  Timer? _durationTimer;
  DateTime? _activeStartedAt;

  bool _endRequested = false;
  bool _terminationSent = false;
  bool _routeClosed = false;

  CallAgoraService get agora => _callAgoraService;

  RtcEngine? get agoraEngine => _callAgoraService.engine;

  String? get agoraChannelName =>
      _callAgoraService.channelName;

  @override
  void onInit() {
    super.onInit();

    _answeredCallListener = _handleCallAnswered;
    _rejectedCallListener = _handleCallRejected;
    _endedCallListener = _handleCallEnded;

    _callSocketService.addAnsweredCallListener(
      _answeredCallListener,
    );

    _callSocketService.addRejectedCallListener(
      _rejectedCallListener,
    );

    _callSocketService.addEndedCallListener(
      _endedCallListener,
    );

    final MessageCallSessionModel? session =
        _initialSession;

    if (session != null) {
      _startCallFuture = _startAcceptedCall(session);
    } else {
      _startCallFuture = startCall();
    }
  }

  Future<void> startCall() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    durationLabel.value = 'Connecting...';

    try {
      final String clientCallId = const Uuid().v4();

      final Map<String, dynamic> response =
      await _callSocketService.initiateCall(
        conversationId: conversationId,
        callType: callType.value,
        clientCallId: clientCallId,
      );

      final MessageCallSessionModel session =
      MessageCallSessionModel.fromInitiateResponse(
        response: response,
        participant: participant,
      );

      if (session.id.isEmpty) {
        throw const CallSocketException(
          code: 'CALL_ID_MISSING',
          message:
          'The server did not return a call ID.',
        );
      }

      _callId = session.id;
      callSession.value = session;

      // Show the normal call screen immediately.
      durationLabel.value = 'Ringing...';

      await _callAgoraService.joinCall(
        media: session.media,
        isVideoCall: callType.isVideo,
      );

      _syncMediaControls();

      if (_endRequested) {
        await _terminateCall(
          showError: false,
        );
      }
    } on CallSocketException catch (error) {
      await _cancelAfterStartFailure();

      durationLabel.value = 'Call failed';

      if (!_endRequested) {
        Get.snackbar(
          'Call failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on CallAgoraException catch (error) {
      await _cancelAfterStartFailure();

      durationLabel.value = 'Call failed';

      if (!_endRequested) {
        Get.snackbar(
          'Call failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error) {
      await _cancelAfterStartFailure();

      durationLabel.value = 'Call failed';

      if (!_endRequested) {
        Get.snackbar(
          'Call failed',
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _startAcceptedCall(
      MessageCallSessionModel session,
      ) async {
    isLoading.value = true;
    isActive.value = true;
    durationLabel.value = 'Connecting...';

    try {
      _callId = session.id;
      callSession.value = session;

      await _callAgoraService.joinCall(
        media: session.media,
        isVideoCall: callType.isVideo,
      );

      _syncMediaControls();
      _startDurationTimer();

      await _activateVideoIfNeeded();
    } on CallAgoraException catch (error) {
      await _endAfterMediaFailure();

      Get.snackbar(
        'Call connection failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );

      _closeRoute();
    } catch (error) {
      await _endAfterMediaFailure();

      Get.snackbar(
        'Call connection failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      _closeRoute();
    } finally {
      isLoading.value = false;
    }
  }

  void _handleCallAnswered(
      Map<String, dynamic> payload,
      ) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    isActive.value = true;
    _startDurationTimer();

    unawaited(
      _activateVideoIfNeeded(),
    );
  }

  Future<void> _activateVideoIfNeeded() async {
    if (!callType.isVideo ||
        !isActive.value ||
        isEnding.value) {
      return;
    }

    try {
      final bool enabled =
      await _callAgoraService.activateVideo();

      isCameraOff.value = !enabled;
    } on CallAgoraException catch (error) {
      // Continue the call as audio if camera permission
      // is denied or the camera fails.
      isCameraOff.value = true;

      Get.snackbar(
        'Video unavailable',
        '${error.message} The call will continue with audio.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      isCameraOff.value = true;

      Get.snackbar(
        'Video unavailable',
        'The call will continue with audio.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleCallRejected(
      Map<String, dynamic> payload,
      ) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    _terminationSent = true;

    unawaited(
      _closeAfterRemoteAction(
        message: 'Call declined',
      ),
    );
  }

  void _handleCallEnded(
      Map<String, dynamic> payload,
      ) {
    if (!_matchesCurrentCall(payload)) {
      return;
    }

    _terminationSent = true;

    unawaited(
      _closeAfterRemoteAction(
        message: 'Call ended',
      ),
    );
  }

  bool _matchesCurrentCall(
      Map<String, dynamic> payload,
      ) {
    final Map<String, dynamic> call =
    _toMap(payload['call']);

    final String eventCallId =
        call['id']?.toString() ??
            payload['callId']?.toString() ??
            '';

    return eventCallId.isNotEmpty &&
        eventCallId == _callId;
  }

  Future<void> _closeAfterRemoteAction({
    required String message,
  }) async {
    durationLabel.value = message;

    await _callAgoraService.leaveCall();

    _stopDurationTimer();
    _closeRoute();
  }

  void _startDurationTimer() {
    if (_durationTimer != null) {
      return;
    }

    _activeStartedAt = DateTime.now();
    durationLabel.value = '00:00';

    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        final DateTime? startedAt =
            _activeStartedAt;

        if (startedAt == null) {
          return;
        }

        final Duration duration =
        DateTime.now().difference(startedAt);

        final String hours =
        duration.inHours.toString().padLeft(2, '0');

        final String minutes =
        duration.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');

        final String seconds =
        duration.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');

        durationLabel.value =
        duration.inHours > 0
            ? '$hours:$minutes:$seconds'
            : '$minutes:$seconds';
      },
    );
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _activeStartedAt = null;
  }

  Future<void> toggleMute() async {
    try {
      final bool enabled =
      await _callAgoraService.toggleMicrophone();

      isMuted.value = !enabled;
    } catch (error) {
      Get.snackbar(
        'Microphone error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleSpeaker() async {
    try {
      isSpeakerOn.value =
      await _callAgoraService.toggleSpeaker();
    } catch (error) {
      Get.snackbar(
        'Speaker error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleCamera() async {
    if (!callType.isVideo ||
        !isActive.value) {
      return;
    }

    try {
      final bool enabled =
      await _callAgoraService.toggleCamera();

      isCameraOff.value = !enabled;
    } on CallAgoraException catch (error) {
      Get.snackbar(
        'Camera error',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Camera error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> switchCamera() async {
    if (!callType.isVideo ||
        !isActive.value ||
        isCameraOff.value) {
      return;
    }

    try {
      await _callAgoraService.switchCamera();
      isFrontCamera.toggle();
    } catch (error) {
      Get.snackbar(
        'Camera error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> endCall() async {
    if (isEnding.value) {
      return;
    }

    isEnding.value = true;
    _endRequested = true;
    durationLabel.value = 'Ending...';

    try {
      await _startCallFuture;

      await _terminateCall(
        showError: true,
      );
    } finally {
      await _callAgoraService.leaveCall();

      _stopDurationTimer();

      isEnding.value = false;
      _closeRoute();
    }
  }

  Future<void> _terminateCall({
    required bool showError,
  }) async {
    final String? callId = _callId;

    if (callId == null ||
        callId.isEmpty ||
        _terminationSent) {
      return;
    }

    try {
      if (isActive.value) {
        await _callSocketService.endCall(
          callId: callId,
        );
      } else {
        await _callSocketService.cancelCall(
          callId: callId,
        );
      }

      _terminationSent = true;
    } on CallSocketException catch (error) {
      if (showError) {
        Get.snackbar(
          'Unable to end call',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _cancelAfterStartFailure() async {
    final String? callId = _callId;

    if (callId != null &&
        callId.isNotEmpty &&
        !_terminationSent) {
      try {
        await _callSocketService.cancelCall(
          callId: callId,
        );

        _terminationSent = true;
      } catch (_) {}
    }

    await _callAgoraService.leaveCall();
  }

  Future<void> _endAfterMediaFailure() async {
    final String? callId = _callId;

    if (callId != null &&
        callId.isNotEmpty &&
        !_terminationSent) {
      try {
        await _callSocketService.endCall(
          callId: callId,
        );

        _terminationSent = true;
      } catch (_) {}
    }

    await _callAgoraService.leaveCall();
  }

  void _syncMediaControls() {
    isMuted.value =
    !_callAgoraService.isMicrophoneEnabled.value;

    isSpeakerOn.value =
        _callAgoraService.isSpeakerEnabled.value;

    isCameraOff.value =
    !_callAgoraService.isCameraEnabled.value;
  }

  void _closeRoute() {
    if (_routeClosed) {
      return;
    }

    _routeClosed = true;

    if (!isClosed) {
      Get.back<void>();
    }
  }

  static Map<String, dynamic> _toMap(
      dynamic value,
      ) {
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
    _callSocketService.removeAnsweredCallListener(
      _answeredCallListener,
    );

    _callSocketService.removeRejectedCallListener(
      _rejectedCallListener,
    );

    _callSocketService.removeEndedCallListener(
      _endedCallListener,
    );

    _stopDurationTimer();

    if (!_terminationSent &&
        _callId != null &&
        _callId!.isNotEmpty) {
      unawaited(
        _terminateCall(
          showError: false,
        ),
      );
    }

    unawaited(
      _callAgoraService.leaveCall(),
    );

    super.onClose();
  }
}