import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../core/services/token_service.dart';

class ChatSocketService {
  ChatSocketService({required TokenService tokenService})
    : _tokenService = tokenService;

  io.Socket? _socket;
  final TokenService _tokenService;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({
    void Function(Map<String, dynamic>)? onMessage,
    void Function(Map<String, dynamic>)? onReceiveMessage,
    void Function(Map<String, dynamic>)? onNewMessage,
    void Function(Map<String, dynamic>)? onPresenceChange,
    void Function(Map<String, dynamic>)? onCallIncoming,
    void Function()? onConnect,
  }) async {
    await disconnect();

    final String? token = await _tokenService.getAccessToken();
    // Send the raw access token as a query parameter (e.g. /chat?token=<token>)
    // Backend will accept either raw token or a Bearer-prefixed value.
    final String authToken = token != null && token.isNotEmpty ? token : '';

    final Uri base = Uri.parse(_socketUrl);
    final String url = authToken.isNotEmpty
        ? base
              .replace(queryParameters: <String, String>{'token': authToken})
              .toString()
        : base.toString();

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      // connected
      try {
        if (onConnect != null) onConnect();
      } catch (_) {}
    });

    _socket?.on('message', (dynamic data) {
      if (data is Map && onMessage != null) {
        onMessage(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('receive_message', (dynamic data) {
      if (data is Map && onReceiveMessage != null) {
        onReceiveMessage(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('new_message', (dynamic data) {
      if (data is Map && onNewMessage != null) {
        onNewMessage(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('user_presence_change', (dynamic data) {
      if (data is Map && onPresenceChange != null) {
        onPresenceChange(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('call:incoming', (dynamic data) {
      if (data is Map && onCallIncoming != null) {
        onCallIncoming(Map<String, dynamic>.from(data));
      }
    });

    _socket?.connect();
  }

  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', <String, dynamic>{
      'conversationId': conversationId,
    });
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', <String, dynamic>{
      'conversationId': conversationId,
    });
  }

  void sendMessage({
    required String conversationId,
    String? clientMessageId,
    String? content,
    String? messageType,
    List<Map<String, dynamic>>? attachments,
  }) {
    _socket?.emit('send_message', <String, dynamic>{
      'conversationId': conversationId,
      'clientMessageId': clientMessageId,
      'content': content,
      'messageType': messageType,
      'attachments': attachments,
    });
  }

  Future<void> disconnect() async {
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
  }

  String get _socketUrl {
    final String apiBaseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
    final Uri uri = Uri.parse(apiBaseUrl);
    return uri.replace(path: '/chat').toString();
  }
}
