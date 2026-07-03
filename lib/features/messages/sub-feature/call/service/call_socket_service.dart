import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../../core/services/token_service.dart';

typedef CallSocketListener = void Function(Map<String, dynamic> payload);

class CallSocketException implements Exception {
  final String code;
  final String message;

  const CallSocketException({required this.code, required this.message});

  factory CallSocketException.fromResponse(Map<String, dynamic> response) {
    final dynamic rawError = response['error'];

    if (rawError is Map) {
      final Map<String, dynamic> error = Map<String, dynamic>.from(rawError);

      return CallSocketException(
        code: error['code']?.toString() ?? 'CALL_ERROR',
        message:
            error['message']?.toString() ??
            'Unable to complete the call request.',
      );
    }

    return const CallSocketException(
      code: 'CALL_ERROR',
      message: 'Unable to complete the call request.',
    );
  }

  @override
  String toString() => '$code: $message';
}

class CallSocketService extends GetxService {
  CallSocketService({required TokenService tokenService})
    : _tokenService = tokenService;

  final TokenService _tokenService;

  io.Socket? _socket;
  Completer<void>? _connectingCompleter;

  final List<CallSocketListener> _connectedListeners = <CallSocketListener>[];

  final List<CallSocketListener> _incomingCallListeners =
      <CallSocketListener>[];

  final List<CallSocketListener> _answeredCallListeners =
      <CallSocketListener>[];

  final List<CallSocketListener> _rejectedCallListeners =
      <CallSocketListener>[];

  final List<CallSocketListener> _cancelledCallListeners =
      <CallSocketListener>[];

  final List<CallSocketListener> _endedCallListeners = <CallSocketListener>[];

  bool get isConnected => _socket?.connected ?? false;

  String? get socketId => _socket?.id;

  Future<void> connect() async {
    if (isConnected) {
      return;
    }

    final Completer<void>? existingCompleter = _connectingCompleter;

    if (existingCompleter != null) {
      return existingCompleter.future;
    }

    final String? token = await _tokenService.getAccessToken();

    if (token == null || token.trim().isEmpty) {
      throw const CallSocketException(
        code: 'TOKEN_MISSING',
        message: 'Login token was not found.',
      );
    }

    await _disposeSocket();

    final Completer<void> completer = Completer<void>();

    _connectingCompleter = completer;

    final io.OptionBuilder options = io.OptionBuilder()
        .setTransports(<String>['websocket'])
        .setAuth(<String, dynamic>{'token': token.trim()})
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .disableAutoConnect();

    final io.Socket socket = io.io(_socketUrl, options.build());

    _socket = socket;

    socket.onConnect((dynamic _) {
      debugPrint('[CallSocket] Connected: ${socket.id}');

      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    socket.onDisconnect((dynamic reason) {
      debugPrint('[CallSocket] Disconnected: $reason');
    });

    socket.onConnectError((dynamic error) {
      debugPrint('[CallSocket] Connection error: $error');

      if (!completer.isCompleted) {
        completer.completeError(
          CallSocketException(
            code: 'CALL_SOCKET_CONNECTION_FAILED',
            message:
                error?.toString() ?? 'Unable to connect to the call server.',
          ),
        );
      }
    });

    socket.onError((dynamic error) {
      debugPrint('[CallSocket] Socket error: $error');
    });

    socket.on('call:connected', (dynamic data) {
      _handleSocketEvent(
        event: 'call:connected',
        data: data,
        listeners: _connectedListeners,
        listenerName: 'Connected',
      );
    });

    socket.on('call:incoming', (dynamic data) {
      _handleSocketEvent(
        event: 'call:incoming',
        data: data,
        listeners: _incomingCallListeners,
        listenerName: 'Incoming call',
      );
    });

    socket.on('call:answered', (dynamic data) {
      _handleSocketEvent(
        event: 'call:answered',
        data: data,
        listeners: _answeredCallListeners,
        listenerName: 'Answered call',
      );
    });

    socket.on('call:rejected', (dynamic data) {
      _handleSocketEvent(
        event: 'call:rejected',
        data: data,
        listeners: _rejectedCallListeners,
        listenerName: 'Rejected call',
      );
    });

    socket.on('call:cancelled', (dynamic data) {
      _handleSocketEvent(
        event: 'call:cancelled',
        data: data,
        listeners: _cancelledCallListeners,
        listenerName: 'Cancelled call',
      );
    });

    socket.on('call:ended', (dynamic data) {
      _handleSocketEvent(
        event: 'call:ended',
        data: data,
        listeners: _endedCallListeners,
        listenerName: 'Ended call',
      );
    });

    socket.connect();

    try {
      await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw const CallSocketException(
            code: 'CALL_SOCKET_TIMEOUT',
            message: 'The call server connection timed out.',
          );
        },
      );
    } finally {
      if (identical(_connectingCompleter, completer)) {
        _connectingCompleter = null;
      }
    }
  }

  Future<Map<String, dynamic>> initiateCall({
    required String conversationId,
    required String callType,
    required String clientCallId,
  }) {
    return _emitCallAction(
      event: 'call:initiate',
      payload: <String, dynamic>{
        'directConversationId': conversationId,
        'callType': callType,
        'clientCallId': clientCallId,
      },
      timeoutCode: 'CALL_INITIATE_TIMEOUT',
      timeoutMessage: 'The server did not respond to the call request.',
    );
  }

  Future<Map<String, dynamic>> answerCall({required String callId}) {
    return _runSocketActionWithHttpFallback(
      socketAction: () => _emitCallAction(
        event: 'call:answer',
        payload: <String, dynamic>{'callId': callId},
        timeoutCode: 'CALL_ANSWER_TIMEOUT',
        timeoutMessage: 'The server did not respond to the answer request.',
      ),
      httpAction: () => answerCallOverHttp(callId: callId),
    );
  }

  Future<Map<String, dynamic>> rejectCall({required String callId}) {
    return _runSocketActionWithHttpFallback(
      socketAction: () => _emitCallAction(
        event: 'call:reject',
        payload: <String, dynamic>{'callId': callId},
        timeoutCode: 'CALL_REJECT_TIMEOUT',
        timeoutMessage: 'The server did not respond to the rejection request.',
      ),
      httpAction: () => rejectCallOverHttp(callId: callId),
    );
  }

  Future<Map<String, dynamic>> cancelCall({required String callId}) {
    return _runSocketActionWithHttpFallback(
      socketAction: () => _emitCallAction(
        event: 'call:cancel',
        payload: <String, dynamic>{'callId': callId},
        timeoutCode: 'CALL_CANCEL_TIMEOUT',
        timeoutMessage:
            'The server did not respond to the cancellation request.',
      ),
      httpAction: () => cancelCallOverHttp(callId: callId),
    );
  }

  Future<Map<String, dynamic>> endCall({required String callId}) {
    return _runSocketActionWithHttpFallback(
      socketAction: () => _emitCallAction(
        event: 'call:end',
        payload: <String, dynamic>{'callId': callId},
        timeoutCode: 'CALL_END_TIMEOUT',
        timeoutMessage: 'The server did not respond to the end call request.',
      ),
      httpAction: () => endCallOverHttp(callId: callId),
    );
  }

  Future<Map<String, dynamic>> timeoutCall({required String callId}) {
    return _runSocketActionWithHttpFallback(
      socketAction: () => _emitCallAction(
        event: 'call:timeout',
        payload: <String, dynamic>{'callId': callId},
        timeoutCode: 'CALL_TIMEOUT_TIMEOUT',
        timeoutMessage: 'The server did not respond to the timeout request.',
      ),
      httpAction: () => timeoutCallOverHttp(callId: callId),
    );
  }

  Future<Map<String, dynamic>> answerCallOverHttp({required String callId}) {
    return _sendHttpCallAction(
      method: 'POST',
      path: '/calls/${callId.trim()}/answer',
    );
  }

  Future<Map<String, dynamic>> rejectCallOverHttp({required String callId}) {
    return _sendHttpCallAction(
      method: 'POST',
      path: '/calls/${callId.trim()}/reject',
    );
  }

  Future<Map<String, dynamic>> cancelCallOverHttp({required String callId}) {
    return _sendHttpCallAction(
      method: 'POST',
      path: '/calls/${callId.trim()}/cancel',
    );
  }

  Future<Map<String, dynamic>> endCallOverHttp({required String callId}) {
    return _sendHttpCallAction(
      method: 'POST',
      path: '/calls/${callId.trim()}/end',
    );
  }

  Future<Map<String, dynamic>> timeoutCallOverHttp({required String callId}) {
    return _sendHttpCallAction(
      method: 'POST',
      path: '/calls/${callId.trim()}/timeout',
    );
  }

  Future<Map<String, dynamic>> fetchCall({required String callId}) {
    return _sendHttpCallAction(method: 'GET', path: '/calls/${callId.trim()}');
  }

  Future<Map<String, dynamic>> _runSocketActionWithHttpFallback({
    required Future<Map<String, dynamic>> Function() socketAction,
    required Future<Map<String, dynamic>> Function() httpAction,
  }) async {
    try {
      return await socketAction();
    } on CallSocketException catch (error) {
      if (!_isSocketTransportFailure(error)) {
        rethrow;
      }

      debugPrint(
        '[CallSocket] ${error.code}; retrying the call action over HTTP',
      );

      return httpAction();
    }
  }

  bool _isSocketTransportFailure(CallSocketException error) {
    return error.code == 'CALL_SOCKET_CONNECTION_FAILED' ||
        error.code == 'CALL_SOCKET_TIMEOUT' ||
        error.code == 'CALL_SOCKET_NOT_CONNECTED' ||
        error.code == 'CALL_ANSWER_TIMEOUT' ||
        error.code == 'CALL_REJECT_TIMEOUT' ||
        error.code == 'CALL_CANCEL_TIMEOUT' ||
        error.code == 'CALL_END_TIMEOUT' ||
        error.code == 'CALL_TIMEOUT_TIMEOUT';
  }

  Future<Map<String, dynamic>> _sendHttpCallAction({
    required String method,
    required String path,
  }) async {
    final String normalizedPath = path.trim();
    if (normalizedPath.isEmpty || normalizedPath.contains('/calls//')) {
      throw const CallSocketException(
        code: 'INVALID_CALL_ID',
        message: 'A valid call ID is required.',
      );
    }

    final String? token = await _tokenService.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      throw const CallSocketException(
        code: 'TOKEN_MISSING',
        message: 'Login token was not found.',
      );
    }

    final String tokenType = await _tokenService.getTokenType();
    final Dio client = Dio(
      BaseOptions(
        baseUrl: _apiBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': '$tokenType ${token.trim()}',
        },
      ),
    );

    try {
      final Response<dynamic> response;
      if (method == 'GET') {
        response = await client.get<dynamic>(normalizedPath);
      } else {
        response = await client.post<dynamic>(normalizedPath);
      }

      final Map<String, dynamic> body = _toMap(response.data);
      final dynamic rawData = body['ok'] == true ? body['data'] : body;

      if (rawData is! Map) {
        throw const CallSocketException(
          code: 'INVALID_CALL_RESPONSE',
          message: 'The server returned an invalid call response.',
        );
      }

      return Map<String, dynamic>.from(rawData);
    } on DioException catch (error) {
      throw _callExceptionFromDio(error);
    } finally {
      client.close(force: true);
    }
  }

  CallSocketException _callExceptionFromDio(DioException error) {
    final Map<String, dynamic> body = _toMap(error.response?.data);
    final dynamic rawMessage = body['message'];

    if (rawMessage is Map) {
      final Map<String, dynamic> message = Map<String, dynamic>.from(
        rawMessage,
      );
      return CallSocketException(
        code: message['code']?.toString() ?? 'CALL_HTTP_ERROR',
        message:
            message['message']?.toString() ??
            'Unable to complete the call request.',
      );
    }

    return CallSocketException(
      code: body['code']?.toString() ?? 'CALL_HTTP_ERROR',
      message: rawMessage is List
          ? rawMessage.map((dynamic value) => value.toString()).join(', ')
          : rawMessage?.toString() ??
                error.message ??
                'Unable to complete the call request.',
    );
  }

  Future<void> acknowledgeIncomingCall({required String callId}) async {
    final String normalizedCallId = callId.trim();

    if (normalizedCallId.isEmpty) {
      throw const CallSocketException(
        code: 'INVALID_CALL_ID',
        message: 'A valid call ID is required for acknowledgement.',
      );
    }

    final io.Socket? socket = _socket;

    if (socket == null || !socket.connected) {
      throw const CallSocketException(
        code: 'CALL_SOCKET_NOT_CONNECTED',
        message: 'The call socket is not connected.',
      );
    }

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    debugPrint(
      '[CallSocket] Sending call:incoming:ack '
      '$normalizedCallId',
    );

    socket.emitWithAck(
      'call:incoming:ack',
      <String, dynamic>{'callId': normalizedCallId},
      ack: (dynamic rawResponse) {
        if (completer.isCompleted) {
          return;
        }

        final Map<String, dynamic> response = _toMap(rawResponse);

        debugPrint(
          '[CallSocket] call:incoming:ack '
          'response $response',
        );

        completer.complete(response);
      },
    );

    final Map<String, dynamic> response = await completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        throw const CallSocketException(
          code: 'CALL_INCOMING_ACK_TIMEOUT',
          message: 'The incoming call acknowledgement timed out.',
        );
      },
    );

    if (response['ok'] != true) {
      throw CallSocketException.fromResponse(response);
    }
  }

  Future<Map<String, dynamic>> _emitCallAction({
    required String event,
    required Map<String, dynamic> payload,
    required String timeoutCode,
    required String timeoutMessage,
  }) async {
    await connect();

    final io.Socket? socket = _socket;

    if (socket == null || !socket.connected) {
      throw const CallSocketException(
        code: 'CALL_SOCKET_NOT_CONNECTED',
        message: 'The foreground call socket is not connected.',
      );
    }

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    debugPrint('[CallSocket] Sending $event $payload');

    socket.emitWithAck(
      event,
      payload,
      ack: (dynamic rawResponse) {
        if (completer.isCompleted) {
          return;
        }

        final Map<String, dynamic> response = _toMap(rawResponse);

        debugPrint('[CallSocket] $event response $response');

        completer.complete(response);
      },
    );

    final Map<String, dynamic> response = await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw CallSocketException(code: timeoutCode, message: timeoutMessage);
      },
    );

    if (response['ok'] != true) {
      throw CallSocketException.fromResponse(response);
    }

    final dynamic rawData = response['data'];

    if (rawData is! Map) {
      throw const CallSocketException(
        code: 'INVALID_CALL_RESPONSE',
        message: 'The server returned an invalid call response.',
      );
    }

    return Map<String, dynamic>.from(rawData);
  }

  void addConnectedListener(CallSocketListener listener) {
    _addListener(_connectedListeners, listener);
  }

  void removeConnectedListener(CallSocketListener listener) {
    _connectedListeners.remove(listener);
  }

  void addIncomingCallListener(CallSocketListener listener) {
    _addListener(_incomingCallListeners, listener);
  }

  void removeIncomingCallListener(CallSocketListener listener) {
    _incomingCallListeners.remove(listener);
  }

  void addAnsweredCallListener(CallSocketListener listener) {
    _addListener(_answeredCallListeners, listener);
  }

  void removeAnsweredCallListener(CallSocketListener listener) {
    _answeredCallListeners.remove(listener);
  }

  void addRejectedCallListener(CallSocketListener listener) {
    _addListener(_rejectedCallListeners, listener);
  }

  void removeRejectedCallListener(CallSocketListener listener) {
    _rejectedCallListeners.remove(listener);
  }

  void addCancelledCallListener(CallSocketListener listener) {
    _addListener(_cancelledCallListeners, listener);
  }

  void removeCancelledCallListener(CallSocketListener listener) {
    _cancelledCallListeners.remove(listener);
  }

  void addEndedCallListener(CallSocketListener listener) {
    _addListener(_endedCallListeners, listener);
  }

  void removeEndedCallListener(CallSocketListener listener) {
    _endedCallListeners.remove(listener);
  }

  Future<void> refreshConnectionAfterLogin() async {
    await disconnect();
    await connect();
  }

  Future<void> disconnect() async {
    await _disposeSocket();
  }

  void _handleSocketEvent({
    required String event,
    required dynamic data,
    required List<CallSocketListener> listeners,
    required String listenerName,
  }) {
    final Map<String, dynamic> payload = _toMap(data);

    debugPrint('[CallSocket] $event $payload');

    _notifyListeners(
      listeners: listeners,
      payload: payload,
      listenerName: listenerName,
    );
  }

  void _addListener(
    List<CallSocketListener> listeners,
    CallSocketListener listener,
  ) {
    if (!listeners.contains(listener)) {
      listeners.add(listener);
    }
  }

  void _notifyListeners({
    required List<CallSocketListener> listeners,
    required Map<String, dynamic> payload,
    required String listenerName,
  }) {
    final List<CallSocketListener> copiedListeners =
        List<CallSocketListener>.from(listeners);

    for (final CallSocketListener listener in copiedListeners) {
      try {
        listener(payload);
      } catch (error, stackTrace) {
        debugPrint('[CallSocket] $listenerName listener error: $error');

        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> _disposeSocket() async {
    final io.Socket? socket = _socket;

    _socket = null;
    _connectingCompleter = null;

    if (socket == null) {
      return;
    }

    try {
      socket.clearListeners();
      socket.disconnect();
      socket.dispose();
    } catch (error) {
      debugPrint('[CallSocket] Dispose error: $error');
    }
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }

  String get _apiBaseUrl {
    final String apiBaseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';

    if (apiBaseUrl.isEmpty) {
      throw const CallSocketException(
        code: 'API_BASE_URL_MISSING',
        message: 'API_BASE_URL is missing from the .env file.',
      );
    }

    return apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
  }

  String get _socketUrl {
    final Uri uri = Uri.parse(_apiBaseUrl);

    return uri.replace(path: '/calls', query: null, fragment: null).toString();
  }

  @override
  void onClose() {
    unawaited(_disposeSocket());
    super.onClose();
  }
}
