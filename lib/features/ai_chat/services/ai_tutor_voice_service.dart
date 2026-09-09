import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/utils/app_logger.dart';
import '../models/ai_tutor_models.dart';
import 'native_ai_voice_audio_service.dart';

enum AiTutorVoiceConnectionState {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}

typedef AiTutorCredentialRefresher =
    Future<AiTutorVoiceSessionModel> Function(String? resumptionHandle);
typedef AiTutorEventReporter =
    Future<void> Function(List<AiTutorLiveEventModel> events);
typedef AiTutorLevelTestCompletionHandler = Future<void> Function();

class AiTutorVoiceService extends GetxService {
  static const int _inputSampleRate = 16000;
  static const int _maxReconnectAttempts = 3;
  static const double _speechThreshold = 0.035;

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

  final NativeAiVoiceAudioService _nativeAudio = NativeAiVoiceAudioService();
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSubscription;
  Completer<void>? _assistantReadyCompleter;
  AiTutorCredentialRefresher? _refreshCredential;
  AiTutorEventReporter? _reportEvents;
  AiTutorLevelTestCompletionHandler? _onLevelTestComplete;
  final List<AiTutorLiveEventModel> _eventBuffer = <AiTutorLiveEventModel>[];
  Timer? _eventFlushTimer;
  Timer? _userSpeechEndTimer;
  Timer? _assistantSpeechEndTimer;
  bool _discardAudioUntilTurnComplete = false;
  String? _sessionId;
  bool _isLevelTestSession = false;
  String? _resumptionHandle;
  String _inputTranscript = '';
  String _outputTranscript = '';
  String? _inputMessageId;
  String? _outputMessageId;
  int _eventSequence = 0;
  int _reconnectAttempt = 0;
  bool _audioOpened = false;
  bool _isDisconnecting = false;
  bool _isReconnecting = false;
  bool _socketReady = false;
  bool _isFlushingEvents = false;
  bool _levelTestCompletionRequested = false;

  bool get isConnected =>
      connectionState.value == AiTutorVoiceConnectionState.connected;

  double get activeAudioLevel => assistantSpeaking.value
      ? assistantAudioLevel.value
      : userSpeaking.value
      ? userAudioLevel.value
      : 0;

  AiTutorMessageModel? get latestAssistantMessage {
    for (final AiTutorMessageModel message in messages.reversed) {
      if (!message.isUser) return message;
    }
    return null;
  }

  AiTutorMessageModel? get latestUserMessage {
    for (final AiTutorMessageModel message in messages.reversed) {
      if (message.isUser) return message;
    }
    return null;
  }

  Future<void> connect(
    AiTutorVoiceSessionModel session, {
    AiTutorCredentialRefresher? refreshCredential,
    AiTutorEventReporter? reportEvents,
    AiTutorLevelTestCompletionHandler? onLevelTestComplete,
  }) async {
    await disconnect();
    connectionState.value = AiTutorVoiceConnectionState.connecting;
    status.value = 'Requesting microphone permission...';
    await _ensureMicrophonePermission();
    _sessionId = session.sessionId;
    _isLevelTestSession = session.isLevelTest;
    _refreshCredential = refreshCredential;
    _reportEvents = reportEvents;
    _onLevelTestComplete = onLevelTestComplete;
    _assistantReadyCompleter = Completer<void>();
    _resetUiForConnection();
    await _openAudio();
    try {
      await _connectSocket(session);
    } catch (error, stackTrace) {
      _log('Gemini Live connection failed', error, stackTrace);
      connectionState.value = AiTutorVoiceConnectionState.error;
      status.value = 'Unable to connect';
      await disconnect(preserveErrorState: true);
      rethrow;
    }
  }

  Future<void> _connectSocket(AiTutorVoiceSessionModel session) async {
    if (session.url.isEmpty || session.token.isEmpty || session.setup.isEmpty) {
      throw const FormatException('Invalid Gemini Live session credential');
    }
    await _closeSocket();
    _socketReady = false;
    status.value = _reconnectAttempt == 0
        ? 'connecting_to_your_ai_tutor'.tr
        : 'reconnecting_to_your_ai_tutor'.tr;
    final Uri uri = Uri.parse(
      session.url,
    ).replace(queryParameters: <String, String>{'access_token': session.token});
    final WebSocketChannel channel = WebSocketChannel.connect(uri);
    _channel = channel;
    await channel.ready.timeout(const Duration(seconds: 15));
    _socketSubscription = channel.stream.listen(
      _handleSocketMessage,
      onError: (Object error, StackTrace stackTrace) {
        _log('Gemini Live socket error', error, stackTrace);
        unawaited(_handleUnexpectedDisconnect());
      },
      onDone: () => unawaited(_handleUnexpectedDisconnect()),
      cancelOnError: false,
    );
    channel.sink.add(jsonEncode(<String, dynamic>{'setup': session.setup}));
  }

  Future<bool> waitForAssistantReady({
    Duration timeout = const Duration(seconds: 25),
  }) async {
    if (assistantReady.value) return true;
    final Completer<void>? completer = _assistantReadyCompleter;
    if (completer == null) return false;
    try {
      await completer.future.timeout(timeout);
      return assistantReady.value;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> toggleMute() async {
    if (!isConnected) return;
    if (isMuted.value) {
      isMuted.value = false;
      await _startMicrophone();
      status.value = 'gen_listening'.tr;
    } else {
      isMuted.value = true;
      await _stopMicrophone(sendStreamEnd: true);
      status.value = 'microphone_muted'.tr;
    }
  }

  Future<void> disconnect({bool preserveErrorState = false}) async {
    if (_isDisconnecting) return;
    _isDisconnecting = true;
    try {
      _eventFlushTimer?.cancel();
      _userSpeechEndTimer?.cancel();
      _assistantSpeechEndTimer?.cancel();
      _finalizeTranscripts();
      await _flushEvents();
      await _stopMicrophone(sendStreamEnd: true);
      await _closeSocket();
      await _closeAudio();
      _sessionId = null;
      _isLevelTestSession = false;
      _refreshCredential = null;
      _reportEvents = null;
      _onLevelTestComplete = null;
      _resumptionHandle = null;
      _assistantReadyCompleter = null;
      _isReconnecting = false;
      _reconnectAttempt = 0;
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

  Future<void> _openAudio() async {
    if (_audioOpened) return;
    await _nativeAudio.start(
      onMicrophoneAudio: _sendMicrophoneChunk,
      onPlaybackStarted: _handleNativePlaybackStarted,
      onPlaybackEnded: _handleNativePlaybackEnded,
      onError: _handleNativeAudioError,
    );
    _audioOpened = true;
  }

  Future<void> _closeAudio() async {
    if (!_audioOpened) return;
    _discardAudioUntilTurnComplete = true;
    await _nativeAudio.stop();
    _audioOpened = false;
  }

  Future<void> _startMicrophone() async {
    if (!_audioOpened || isMuted.value) return;
    await _nativeAudio.setMuted(false);
  }

  void _sendMicrophoneChunk(Uint8List chunk) {
    if (!_socketReady || isMuted.value || chunk.isEmpty) return;
    final double level = _pcmLevel(chunk);
    if (assistantSpeaking.value) {
      userAudioLevel.value = 0;
      _sendMicrophoneAudio(chunk);
      return;
    }
    userAudioLevel.value = level;
    if (level >= _speechThreshold) {
      _userSpeechEndTimer?.cancel();
      if (!userSpeaking.value) {
        userSpeaking.value = true;
        status.value = 'gen_listening'.tr;
      }
      _userSpeechEndTimer = Timer(const Duration(milliseconds: 450), () {
        userSpeaking.value = false;
        userAudioLevel.value = 0;
        if (!assistantSpeaking.value) {
          assistantThinking.value = true;
          status.value = 'ai_tutor_is_thinking'.tr;
        }
      });
    }
    _sendMicrophoneAudio(chunk);
  }

  void _sendMicrophoneAudio(Uint8List chunk) {
    _send(<String, dynamic>{
      'realtimeInput': <String, dynamic>{
        'audio': <String, dynamic>{
          'data': base64Encode(chunk),
          'mimeType': 'audio/pcm;rate=$_inputSampleRate',
        },
      },
    });
  }

  Future<void> _stopMicrophone({required bool sendStreamEnd}) async {
    if (sendStreamEnd && _socketReady) {
      _send(<String, dynamic>{
        'realtimeInput': <String, dynamic>{'audioStreamEnd': true},
      });
    }
    if (_audioOpened) await _nativeAudio.setMuted(true);
    userSpeaking.value = false;
    userAudioLevel.value = 0;
  }

  void _handleNativePlaybackStarted() {
    assistantThinking.value = false;
    assistantSpeaking.value = true;
    assistantAudioLevel.value = 0.75;
    status.value = 'ai_tutor_is_speaking'.tr;
  }

  void _handleNativePlaybackEnded() {
    assistantSpeaking.value = false;
    assistantAudioLevel.value = 0;
    if (isConnected && !isMuted.value) status.value = 'gen_listening'.tr;
  }

  void _handleNativeAudioError(String message) {
    _log(
      'Native AI voice audio error',
      StateError(message),
      StackTrace.current,
    );
    status.value = 'Voice audio unavailable';
  }

  void _handleSocketMessage(dynamic payload) {
    try {
      final String raw = payload is String
          ? payload
          : utf8.decode(List<int>.from(payload as List));
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final Map<String, dynamic> message = Map<String, dynamic>.from(decoded);
      if (message.containsKey('setupComplete')) {
        _socketReady = true;
        _discardAudioUntilTurnComplete = false;
        _reconnectAttempt = 0;
        connectionState.value = AiTutorVoiceConnectionState.connected;
        assistantReady.value = true;
        assistantThinking.value = false;
        status.value = isMuted.value
            ? 'microphone_muted'.tr
            : 'gen_listening'.tr;
        if (!(_assistantReadyCompleter?.isCompleted ?? true)) {
          _assistantReadyCompleter!.complete();
        }
        unawaited(_startMicrophone());
        _send(<String, dynamic>{
          'realtimeInput': <String, dynamic>{
            'text': _isLevelTestSession
                ? 'Begin the spoken Italian level assessment now. Ask the first assessment question and wait for my spoken answer.'
                : 'Begin the spoken lesson with a brief Italian greeting and invite me to answer aloud.',
          },
        });
      }
      final Map<String, dynamic>? content = _map(message['serverContent']);
      if (content != null) _handleServerContent(content);
      final Map<String, dynamic>? resumption = _map(
        message['sessionResumptionUpdate'],
      );
      final String? handle = resumption?['newHandle']?.toString().trim();
      if (resumption?['resumable'] == true && handle?.isNotEmpty == true) {
        _resumptionHandle = handle;
        _queueEvent(type: 'resumption_handle', handle: handle);
      }
      if (message.containsKey('goAway')) {
        unawaited(_handleUnexpectedDisconnect());
      }
      final Map<String, dynamic>? toolCall = _map(message['toolCall']);
      final List<dynamic> functionCalls = toolCall?['functionCalls'] is List
          ? toolCall!['functionCalls'] as List<dynamic>
          : const <dynamic>[];
      for (final dynamic value in functionCalls) {
        final Map<String, dynamic>? functionCall = _map(value);
        if (functionCall?['name']?.toString() ==
            'complete_level_test_speaking') {
          _handleLevelTestCompletionTool(functionCall!);
        }
      }
    } catch (error, stackTrace) {
      _log('Invalid Gemini Live message', error, stackTrace);
    }
  }

  void _handleLevelTestCompletionTool(Map<String, dynamic> functionCall) {
    if (!_isLevelTestSession || _levelTestCompletionRequested) return;
    _levelTestCompletionRequested = true;
    final String id = functionCall['id']?.toString() ?? '';
    _send(<String, dynamic>{
      'toolResponse': <String, dynamic>{
        'functionResponses': <Map<String, dynamic>>[
          <String, dynamic>{
            if (id.isNotEmpty) 'id': id,
            'name': 'complete_level_test_speaking',
            'response': <String, dynamic>{'result': 'moving_to_mcq'},
          },
        ],
      },
    });
    final AiTutorLevelTestCompletionHandler? callback = _onLevelTestComplete;
    if (callback != null) unawaited(callback());
  }

  void _handleServerContent(Map<String, dynamic> content) {
    if (content['interrupted'] == true) {
      _discardAudioUntilTurnComplete = true;
      unawaited(_interruptPlayback());
      _finalizeTranscripts();
    }
    final String input =
        _map(content['inputTranscription'])?['text']?.toString() ?? '';
    if (input.isNotEmpty) {
      _inputTranscript += input;
      _inputMessageId ??= _nextId('user');
      _upsertTranscript(_inputMessageId!, _inputTranscript, true, true);
    }
    final String output =
        _map(content['outputTranscription'])?['text']?.toString() ?? '';
    if (output.isNotEmpty) {
      _outputTranscript += output;
      _outputMessageId ??= _nextId('assistant');
      _upsertTranscript(_outputMessageId!, _outputTranscript, false, true);
    }
    final Map<String, dynamic>? modelTurn = _map(content['modelTurn']);
    final List<dynamic> parts = modelTurn?['parts'] is List
        ? modelTurn!['parts'] as List<dynamic>
        : const <dynamic>[];
    if (!_discardAudioUntilTurnComplete) {
      for (final dynamic value in parts) {
        final Map<String, dynamic>? inlineData = _map(
          _map(value)?['inlineData'],
        );
        final String? encoded = inlineData?['data']?.toString();
        if (encoded?.isNotEmpty == true) {
          _enqueueAudio(base64Decode(encoded!));
        }
      }
    }
    if (content['turnComplete'] == true) {
      final bool wasDiscarding = _discardAudioUntilTurnComplete;
      if (!wasDiscarding) {
        unawaited(
          _nativeAudio.finishPlaybackTurn().catchError((Object error) {
            _log(
              'Native playback completion failed',
              error,
              StackTrace.current,
            );
          }),
        );
      }
      _discardAudioUntilTurnComplete = false;
      _finalizeTranscripts();
      assistantThinking.value = false;
      _assistantSpeechEndTimer?.cancel();
    }
  }

  void _enqueueAudio(Uint8List audio) {
    if (_discardAudioUntilTurnComplete || audio.isEmpty) return;
    assistantThinking.value = false;
    unawaited(
      _nativeAudio.enqueuePlayback(audio).catchError((Object error) {
        _log('Native Gemini playback failed', error, StackTrace.current);
      }),
    );
  }

  Future<void> _interruptPlayback() async {
    assistantSpeaking.value = false;
    assistantAudioLevel.value = 0;
    try {
      await _nativeAudio.interruptPlayback();
    } catch (error, stackTrace) {
      _log('Native Gemini audio interruption failed', error, stackTrace);
    }
  }

  void _finalizeTranscripts() {
    if (_inputTranscript.trim().isNotEmpty && _inputMessageId != null) {
      _upsertTranscript(_inputMessageId!, _inputTranscript, true, false);
      _queueEvent(
        type: 'user_transcript',
        text: _inputTranscript,
        eventId: _inputMessageId,
      );
    }
    if (_outputTranscript.trim().isNotEmpty && _outputMessageId != null) {
      _upsertTranscript(_outputMessageId!, _outputTranscript, false, false);
      _queueEvent(
        type: 'assistant_transcript',
        text: _outputTranscript,
        eventId: _outputMessageId,
      );
    }
    _inputTranscript = '';
    _outputTranscript = '';
    _inputMessageId = null;
    _outputMessageId = null;
  }

  void _upsertTranscript(String id, String text, bool isUser, bool partial) {
    final AiTutorMessageModel message =
        AiTutorMessageModel.fromTranscript(<String, dynamic>{
          'messageId': id,
          'role': isUser ? 'user' : 'assistant',
          'text': text.trim(),
          'final': !partial,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        });
    final int index = messages.indexWhere((item) => item.id == id);
    if (index >= 0) {
      messages[index] = message;
      messages.refresh();
    } else {
      messages.add(message);
      if (messages.length > 100) messages.removeAt(0);
    }
  }

  void _queueEvent({
    required String type,
    String? text,
    String? handle,
    String? eventId,
  }) {
    _eventBuffer.add(
      AiTutorLiveEventModel(
        eventId: eventId ?? _nextId(type),
        type: type,
        text: text,
        handle: handle,
        occurredAt: DateTime.now(),
      ),
    );
    if (_eventBuffer.length >= 10) {
      unawaited(_flushEvents());
    } else {
      _eventFlushTimer?.cancel();
      _eventFlushTimer = Timer(
        const Duration(seconds: 2),
        () => unawaited(_flushEvents()),
      );
    }
  }

  Future<void> _flushEvents() async {
    final AiTutorEventReporter? reporter = _reportEvents;
    if (reporter == null || _eventBuffer.isEmpty || _isFlushingEvents) return;
    _isFlushingEvents = true;
    final List<AiTutorLiveEventModel> batch = List.of(_eventBuffer);
    _eventBuffer.clear();
    try {
      await reporter(batch);
    } catch (error, stackTrace) {
      _log('AI tutor event sync failed', error, stackTrace);
      _eventBuffer.insertAll(0, batch);
      if (_eventBuffer.length > 40) {
        _eventBuffer.removeRange(0, _eventBuffer.length - 40);
      }
    } finally {
      _isFlushingEvents = false;
      if (_eventBuffer.isNotEmpty && !_isDisconnecting) {
        _eventFlushTimer?.cancel();
        _eventFlushTimer = Timer(
          const Duration(seconds: 2),
          () => unawaited(_flushEvents()),
        );
      }
    }
  }

  Future<void> _handleUnexpectedDisconnect() async {
    if (_isDisconnecting || _isReconnecting || _sessionId == null) return;
    final AiTutorCredentialRefresher? refresher = _refreshCredential;
    if (refresher == null || _reconnectAttempt >= _maxReconnectAttempts) {
      connectionState.value = AiTutorVoiceConnectionState.error;
      status.value = 'Voice connection lost';
      return;
    }
    _isReconnecting = true;
    _socketReady = false;
    connectionState.value = AiTutorVoiceConnectionState.connecting;
    await _stopMicrophone(sendStreamEnd: false);
    await _interruptPlayback();
    try {
      while (!_isDisconnecting && _reconnectAttempt < _maxReconnectAttempts) {
        _reconnectAttempt++;
        try {
          await Future<void>.delayed(
            Duration(milliseconds: 500 * _reconnectAttempt),
          );
          final AiTutorVoiceSessionModel credential = await refresher(
            _resumptionHandle,
          );
          await _connectSocket(credential);
          return;
        } catch (error, stackTrace) {
          _log('Gemini Live reconnect attempt failed', error, stackTrace);
        }
      }
      connectionState.value = AiTutorVoiceConnectionState.error;
      status.value = 'Unable to reconnect';
    } finally {
      _isReconnecting = false;
    }
  }

  Future<void> _closeSocket() async {
    _socketReady = false;
    final StreamSubscription<dynamic>? subscription = _socketSubscription;
    _socketSubscription = null;
    await subscription?.cancel();
    final WebSocketChannel? channel = _channel;
    _channel = null;
    try {
      await channel?.sink.close();
    } catch (_) {}
  }

  void _send(Map<String, dynamic> message) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode(message));
  }

  void _resetUiForConnection() {
    assistantReady.value = false;
    assistantThinking.value = true;
    assistantSpeaking.value = false;
    userSpeaking.value = false;
    userAudioLevel.value = 0;
    assistantAudioLevel.value = 0;
    messages.clear();
    _inputTranscript = '';
    _outputTranscript = '';
    _inputMessageId = null;
    _outputMessageId = null;
    _reconnectAttempt = 0;
    _discardAudioUntilTurnComplete = false;
    _levelTestCompletionRequested = false;
  }

  Future<void> _ensureMicrophonePermission() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Gemini Live voice is supported on Android and iOS',
      );
    }
    final PermissionStatus permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      throw StateError('Microphone permission is required for live voice chat');
    }
  }

  double _pcmLevel(Uint8List bytes) {
    if (bytes.length < 2) return 0;
    double sum = 0;
    int count = 0;
    for (int index = 0; index + 1 < bytes.length; index += 2) {
      int sample = bytes[index] | (bytes[index + 1] << 8);
      if (sample >= 32768) sample -= 65536;
      final double normalized = sample / 32768.0;
      sum += normalized * normalized;
      count++;
    }
    return count == 0 ? 0 : math.sqrt(sum / count).clamp(0.0, 1.0);
  }

  Map<String, dynamic>? _map(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  String _nextId(String prefix) {
    _eventSequence++;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_eventSequence';
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    AppLogger.log(
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
