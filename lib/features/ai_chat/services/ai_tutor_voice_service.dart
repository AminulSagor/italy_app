import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

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

  final Rx<AiTutorVoiceConnectionState> connectionState =
      AiTutorVoiceConnectionState.idle.obs;
  final RxString status = 'Ready to connect'.obs;
  final RxBool isMuted = false.obs;
  final RxBool userSpeaking = false.obs;
  final RxBool assistantSpeaking = false.obs;
  final RxList<AiTutorMessageModel> messages = <AiTutorMessageModel>[].obs;

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _roomListener;
  String? _identity;
  String? _sessionId;
  bool _isDisconnecting = false;

  bool get isConnected =>
      connectionState.value == AiTutorVoiceConnectionState.connected;

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
    messages.clear();

    try {
      status.value = 'Connecting to your AI tutor...';
      final lk.Room room = lk.Room(
        roomOptions: const lk.RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      _room = room;
      _registerRoomCallbacks(room);

      await room.connect(session.url, session.token);
      await room.localParticipant?.setMicrophoneEnabled(true);

      isMuted.value = false;
      connectionState.value = AiTutorVoiceConnectionState.connected;
      status.value = 'Listening';
    } catch (error, stackTrace) {
      connectionState.value = AiTutorVoiceConnectionState.error;
      status.value = 'Unable to connect';
      _log('Voice connection failed', error, stackTrace);
      await disconnect(preserveErrorState: true);
      rethrow;
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
    status.value = isMuted.value ? 'Microphone muted' : 'Listening';
  }

  Future<void> disconnect({bool preserveErrorState = false}) async {
    if (_isDisconnecting) {
      return;
    }
    _isDisconnecting = true;

    try {
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
      _identity = null;
      _sessionId = null;
      isMuted.value = false;
      userSpeaking.value = false;
      assistantSpeaking.value = false;

      if (!preserveErrorState) {
        connectionState.value = AiTutorVoiceConnectionState.disconnected;
        status.value = 'Session ended';
      }
    } finally {
      _isDisconnecting = false;
    }
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
        connectionState.value = AiTutorVoiceConnectionState.disconnected;
        status.value = 'Session disconnected';
        userSpeaking.value = false;
        assistantSpeaking.value = false;
      })
      ..on<lk.RoomReconnectingEvent>((_) {
        status.value = 'Reconnecting...';
      })
      ..on<lk.RoomReconnectedEvent>((_) {
        status.value = isMuted.value ? 'Microphone muted' : 'Listening';
      })
      ..on<lk.TrackSubscribedEvent>((lk.TrackSubscribedEvent event) {
        final String kind = event.track.kind.toString().toLowerCase();
        if (kind.contains('audio')) {
          status.value = 'AI tutor connected';
        }
      })
      ..on<lk.ActiveSpeakersChangedEvent>(
        (lk.ActiveSpeakersChangedEvent event) {
          final String? localIdentity = _identity;
          if (localIdentity == null) {
            return;
          }

          userSpeaking.value = event.speakers.any(
            (lk.Participant participant) =>
                participant.identity == localIdentity,
          );
          assistantSpeaking.value = event.speakers.any(
            (lk.Participant participant) =>
                participant.identity != localIdentity,
          );

          if (assistantSpeaking.value) {
            status.value = 'AI tutor is speaking';
          } else if (userSpeaking.value) {
            status.value = 'Listening to you';
          } else if (isConnected) {
            status.value = isMuted.value ? 'Microphone muted' : 'Listening';
          }
        },
      )
      ..on<lk.DataReceivedEvent>(_handleTranscriptData);
  }

  void _handleTranscriptData(lk.DataReceivedEvent event) {
    if (event.topic != _transcriptTopic) {
      return;
    }

    try {
      final dynamic decoded = jsonDecode(utf8.decode(event.data));
      if (decoded is! Map) {
        return;
      }
      final Map<String, dynamic> payload = Map<String, dynamic>.from(decoded);
      if (payload['type'] != 'transcript' || payload['version'] != 1) {
        return;
      }
      if (payload['sessionId']?.toString() != _sessionId) {
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
