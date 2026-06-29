import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:permission_handler/permission_handler.dart';

import '../models/ai_tutor_models.dart';

enum AiTutorVoiceConnectionState {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}

class AiTutorVoiceService extends GetxService {
  static const String _transcriptTopic = 'transcript.v1';
  static const String _voiceStateTopic = 'voice.state.v1';
  static const int _roomConnectionAttempts = 3;

  final Rx<AiTutorVoiceConnectionState> connectionState =
      AiTutorVoiceConnectionState.idle.obs;
  final RxString status = 'Ready to connect'.obs;
  final RxBool isMuted = false.obs;
  final RxBool userSpeaking = false.obs;
  final RxBool assistantSpeaking = false.obs;
  final RxBool assistantThinking = false.obs;
  final RxBool assistantReady = false.obs;
  final RxDouble userAudioLevel = 0.0.obs;
  final RxDouble assistantAudioLevel = 0.0.obs;
  final RxList<AiTutorMessageModel> messages = <AiTutorMessageModel>[].obs;

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _roomListener;
  Completer<void>? _assistantReadyCompleter;
  String? _identity;
  String? _sessionId;
  bool _isDisconnecting = false;
  Timer? _microphoneHealthTimer;

  bool get isConnected =>
      connectionState.value == AiTutorVoiceConnectionState.connected;

  double get activeAudioLevel {
    if (assistantSpeaking.value) {
      return assistantAudioLevel.value;
    }
    if (userSpeaking.value) {
      return userAudioLevel.value;
    }
    return 0;
  }

  AiTutorMessageModel? get latestAssistantMessage {
    for (final AiTutorMessageModel message in messages.reversed) {
      if (!message.isUser) {
        return message;
      }
    }
    return null;
  }

  AiTutorMessageModel? get latestUserMessage {
    for (final AiTutorMessageModel message in messages.reversed) {
      if (message.isUser) {
        return message;
      }
    }
    return null;
  }

  Future<void> connect(AiTutorVoiceSessionModel session) async {
    if (_room != null) {
      await disconnect();
    }

    connectionState.value = AiTutorVoiceConnectionState.connecting;
    status.value = 'Requesting microphone permission...';
    await _ensureMicrophonePermission();

    _sessionId = session.sessionId;
    _identity = session.identity;
    _assistantReadyCompleter = Completer<void>();
    assistantReady.value = false;
    assistantThinking.value = true;
    assistantSpeaking.value = false;
    userSpeaking.value = false;
    userAudioLevel.value = 0;
    assistantAudioLevel.value = 0;
    messages.clear();
    _stopMicrophoneHealthCheck();

    Object? lastError;
    StackTrace? lastStackTrace;

    for (int attempt = 1; attempt <= _roomConnectionAttempts; attempt++) {
      try {
        status.value = attempt == 1
            ? 'Connecting to your AI tutor...'
            : 'Reconnecting to your AI tutor...';
        await _connectRoom(session);
        return;
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        _log('Voice connection attempt $attempt failed', error, stackTrace);
        await _disposeCurrentRoom();

        if (attempt < _roomConnectionAttempts) {
          await Future<void>.delayed(
            Duration(milliseconds: attempt == 1 ? 350 : 900),
          );
        }
      }
    }

    connectionState.value = AiTutorVoiceConnectionState.error;
    status.value = 'Unable to connect';
    await disconnect(preserveErrorState: true);
    Error.throwWithStackTrace(
      lastError ?? StateError('Unable to connect to the AI tutor'),
      lastStackTrace ?? StackTrace.current,
    );
  }

  Future<void> _connectRoom(AiTutorVoiceSessionModel session) async {
    final lk.Room room = lk.Room(
      roomOptions: const lk.RoomOptions(
        adaptiveStream: true,
        dynacast: true,
      ),
    );
    _room = room;
    _registerRoomCallbacks(room);

    try {
      await room.prepareConnection(session.url, session.token);
    } catch (error, stackTrace) {
      _log('LiveKit connection preparation failed', error, stackTrace);
    }

    await room.connect(session.url, session.token);
    await room.localParticipant?.setMicrophoneEnabled(true);

    isMuted.value = false;
    connectionState.value = AiTutorVoiceConnectionState.connected;
    _startMicrophoneHealthCheck();

    if (room.remoteParticipants.isNotEmpty) {
      _markAssistantReady();
    } else {
      status.value = 'Waiting for AI tutor...';
    }
  }

  Future<bool> waitForAssistantReady({
    Duration timeout = const Duration(seconds: 25),
  }) async {
    if (assistantReady.value) {
      return true;
    }

    final Completer<void>? completer = _assistantReadyCompleter;
    if (completer == null) {
      return false;
    }

    try {
      await completer.future.timeout(timeout);
      return assistantReady.value;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> toggleMute() async {
    final lk.LocalParticipant? participant = _room?.localParticipant;
    if (participant == null || !isConnected) {
      return;
    }

    final bool enableMicrophone = isMuted.value;
    await participant.setMicrophoneEnabled(enableMicrophone);
    isMuted.value = !enableMicrophone;

    if (isMuted.value) {
      userSpeaking.value = false;
      userAudioLevel.value = 0;
      status.value = 'Microphone muted';
      return;
    }

    status.value = assistantSpeaking.value
        ? 'AI tutor is speaking'
        : assistantThinking.value
            ? 'AI tutor is thinking'
            : 'Listening';
    await _ensureMicrophonePublished();
  }

  Future<void> disconnect({bool preserveErrorState = false}) async {
    if (_isDisconnecting) {
      return;
    }
    _isDisconnecting = true;
    _stopMicrophoneHealthCheck();

    try {
      await _disposeCurrentRoom();

      _identity = null;
      _sessionId = null;
      _assistantReadyCompleter = null;
      isMuted.value = false;
      userSpeaking.value = false;
      assistantSpeaking.value = false;
      assistantThinking.value = false;
      assistantReady.value = false;
      userAudioLevel.value = 0;
      assistantAudioLevel.value = 0;

      if (!preserveErrorState) {
        connectionState.value = AiTutorVoiceConnectionState.disconnected;
        status.value = 'Session ended';
      }
    } finally {
      _isDisconnecting = false;
    }
  }

  Future<void> _disposeCurrentRoom() async {
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(false);
    } catch (_) {}

    try {
      await _roomListener?.dispose();
    } catch (_) {}

    try {
      await _room?.disconnect();
    } catch (_) {}

    _roomListener = null;
    _room = null;
  }

  Future<void> _ensureMicrophonePermission() async {
    if (kIsWeb) {
      return;
    }

    final PermissionStatus permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      throw StateError('Microphone permission is required for live voice chat');
    }
  }

  void _registerRoomCallbacks(lk.Room room) {
    final lk.EventsListener<lk.RoomEvent> listener = room.createListener();
    _roomListener = listener;

    listener
      ..on<lk.RoomDisconnectedEvent>((_) {
        _stopMicrophoneHealthCheck();
        connectionState.value = AiTutorVoiceConnectionState.disconnected;
        status.value = 'Session disconnected';
        userSpeaking.value = false;
        assistantSpeaking.value = false;
        assistantThinking.value = false;
        assistantReady.value = false;
        userAudioLevel.value = 0;
        assistantAudioLevel.value = 0;
      })
      ..on<lk.RoomReconnectingEvent>((_) {
        status.value = 'Reconnecting...';
      })
      ..on<lk.RoomReconnectedEvent>((_) {
        status.value = assistantReady.value
            ? (isMuted.value ? 'Microphone muted' : 'Listening')
            : 'Waiting for AI tutor...';
        _startMicrophoneHealthCheck();
        if (!isMuted.value) {
          unawaited(_ensureMicrophonePublished());
        }
      })
      ..on<lk.ParticipantConnectedEvent>((lk.ParticipantConnectedEvent event) {
        if (event.participant.identity != _identity) {
          _markAssistantReady();
        }
      })
      ..on<lk.TrackSubscribedEvent>((lk.TrackSubscribedEvent event) {
        final String kind = event.track.kind.toString().toLowerCase();
        if (kind.contains('audio')) {
          _markAssistantReady();
        }
      })
      ..on<lk.ActiveSpeakersChangedEvent>(
        (lk.ActiveSpeakersChangedEvent event) {
          final String? localIdentity = _identity;
          if (localIdentity == null) {
            return;
          }

          double localAudioLevel = 0;
          double remoteAudioLevel = 0;

          for (final lk.Participant participant in event.speakers) {
            final double level =
                participant.audioLevel.clamp(0.0, 1.0).toDouble();
            if (participant.identity == localIdentity) {
              localAudioLevel = math.max(localAudioLevel, level);
            } else {
              remoteAudioLevel = math.max(remoteAudioLevel, level);
            }
          }

          userAudioLevel.value = localAudioLevel;
          assistantAudioLevel.value = remoteAudioLevel;
        },
      )
      ..on<lk.DataReceivedEvent>(_handleDataReceived);
  }

  void _markAssistantReady() {
    if (assistantReady.value) {
      return;
    }

    assistantReady.value = true;
    status.value = isMuted.value ? 'Microphone muted' : 'AI tutor is preparing';
    final Completer<void>? completer = _assistantReadyCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  void _handleDataReceived(lk.DataReceivedEvent event) {
    if (event.topic == _transcriptTopic) {
      _handleTranscriptData(event);
      return;
    }
    if (event.topic == _voiceStateTopic) {
      _handleVoiceStateData(event);
    }
  }

  void _handleTranscriptData(lk.DataReceivedEvent event) {
    try {
      final Map<String, dynamic>? payload = _decodePayload(event.data);
      if (payload == null ||
          payload['type'] != 'transcript' ||
          payload['version'] != 1 ||
          payload['sessionId']?.toString() != _sessionId) {
        return;
      }

      final AiTutorMessageModel message =
          AiTutorMessageModel.fromTranscript(payload);
      if (message.primary.isEmpty) {
        return;
      }
      _upsertTranscriptMessage(message);
    } catch (error, stackTrace) {
      _log('Unable to read voice transcript', error, stackTrace);
    }
  }

  void _handleVoiceStateData(lk.DataReceivedEvent event) {
    try {
      final Map<String, dynamic>? payload = _decodePayload(event.data);
      if (payload == null ||
          payload['type'] != 'voice_state' ||
          payload['version'] != 1 ||
          payload['sessionId']?.toString() != _sessionId) {
        return;
      }

      _applyVoiceState(payload['state']?.toString() ?? '');
    } catch (error, stackTrace) {
      _log('Unable to read AI voice state', error, stackTrace);
    }
  }

  Map<String, dynamic>? _decodePayload(List<int> data) {
    final dynamic decoded = jsonDecode(utf8.decode(data));
    if (decoded is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(decoded);
  }

  void _applyVoiceState(String state) {
    switch (state) {
      case 'user_speaking':
        userSpeaking.value = true;
        assistantSpeaking.value = false;
        assistantThinking.value = false;
        if (!isMuted.value) {
          status.value = 'Listening to you';
        }
        break;
      case 'thinking':
        userSpeaking.value = false;
        assistantSpeaking.value = false;
        assistantThinking.value = true;
        status.value = 'AI tutor is thinking';
        break;
      case 'speaking':
        userSpeaking.value = false;
        assistantSpeaking.value = true;
        assistantThinking.value = false;
        status.value = 'AI tutor is speaking';
        break;
      case 'listening':
        userSpeaking.value = false;
        assistantSpeaking.value = false;
        assistantThinking.value = false;
        status.value = isMuted.value ? 'Microphone muted' : 'Listening';
        if (!isMuted.value) {
          unawaited(_ensureMicrophonePublished());
        }
        break;
      default:
        return;
    }
  }

  void _startMicrophoneHealthCheck() {
    _stopMicrophoneHealthCheck();
    _microphoneHealthTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_ensureMicrophonePublished()),
    );
  }

  void _stopMicrophoneHealthCheck() {
    _microphoneHealthTimer?.cancel();
    _microphoneHealthTimer = null;
  }

  Future<void> _ensureMicrophonePublished() async {
    final lk.LocalParticipant? participant = _room?.localParticipant;
    if (participant == null ||
        isMuted.value ||
        !isConnected ||
        _isDisconnecting) {
      return;
    }

    try {
      if (!participant.isMicrophoneEnabled()) {
        await participant.setMicrophoneEnabled(true);
      }
    } catch (error, stackTrace) {
      _log('Unable to restore microphone publication', error, stackTrace);
    }
  }

  void _upsertTranscriptMessage(AiTutorMessageModel message) {
    final int existingIndex = messages.indexWhere(
      (AiTutorMessageModel item) => item.id == message.id,
    );
    if (existingIndex == -1) {
      messages.add(message);
      return;
    }

    final AiTutorMessageModel existing = messages[existingIndex];
    if (message.isPartial &&
        existing.isPartial &&
        message.primary.length < existing.primary.length) {
      return;
    }
    messages[existingIndex] = message.copyWith(createdAt: existing.createdAt);
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) {
      return;
    }
    dev.log(
      message,
      name: 'AiTutorVoiceService',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose() {
    unawaited(disconnect());
    super.onClose();
  }
}
