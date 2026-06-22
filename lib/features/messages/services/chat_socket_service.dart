import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../core/services/token_service.dart';

class ChatSocketService {
  ChatSocketService({required TokenService tokenService})
    : _tokenService = tokenService;

  io.Socket? _socket;
  final TokenService _tokenService;

  final Set<String> _joinedConversations = <String>{};
  Timer? _heartbeatTimer;
  final int _heartbeatIntervalSeconds = 30;

  // Listener collections so multiple callers can register callbacks.
  final List<void Function(Map<String, dynamic>)> _messageListeners =
      <void Function(Map<String, dynamic>)>[];
  final List<void Function(Map<String, dynamic>)> _receiveListeners =
      <void Function(Map<String, dynamic>)>[];
  final List<void Function(Map<String, dynamic>)> _newMessageListeners =
      <void Function(Map<String, dynamic>)>[];
  final List<void Function(Map<String, dynamic>)> _presenceListeners =
      <void Function(Map<String, dynamic>)>[];
  final List<void Function(Map<String, dynamic>)> _blockListeners =
      <void Function(Map<String, dynamic>)>[];
  final List<void Function(Map<String, dynamic>)> _conversationReadListeners =
      <void Function(Map<String, dynamic>)>[];
  final List<void Function(Map<String, dynamic>)> _conversationUnreadListeners =
      <void Function(Map<String, dynamic>)>[];
  final List<void Function(Map<String, dynamic>)> _callIncomingListeners =
      <void Function(Map<String, dynamic>)>[];
  final List<void Function()> _connectListeners = <void Function()>[];

  bool get isConnected => _socket?.connected ?? false;

  void _startHeartbeat() {
    try {
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(
        Duration(seconds: _heartbeatIntervalSeconds),
        (_) {
          try {
            if (_socket != null && _socket!.connected) {
              _socket!.emit('presence:heartbeat');
            }
          } catch (_) {}
        },
      );
      // immediate heartbeat
      try {
        if (_socket != null && _socket!.connected) {
          _socket!.emit('presence:heartbeat');
        }
      } catch (_) {}
    } catch (_) {}
  }

  void _stopHeartbeat() {
    try {
      _heartbeatTimer?.cancel();
    } catch (_) {}
    _heartbeatTimer = null;
  }

  /// Add a presence listener without forcing a reconnect.
  void addPresenceListener(void Function(Map<String, dynamic>) listener) {
    _presenceListeners.add(listener);
  }

  /// Add a generic message listener. This will be called for 'message' events.
  void addMessageListener(void Function(Map<String, dynamic>) listener) {
    _messageListeners.add(listener);
  }

  /// Remove a previously registered message listener.
  void removeMessageListener(void Function(Map<String, dynamic>) listener) {
    _messageListeners.remove(listener);
  }

  /// Add a listener for 'receive_message' events.
  void addReceiveListener(void Function(Map<String, dynamic>) listener) {
    _receiveListeners.add(listener);
  }

  /// Remove a previously registered receive listener.
  void removeReceiveListener(void Function(Map<String, dynamic>) listener) {
    _receiveListeners.remove(listener);
  }

  /// Add a listener for 'new_message' events.
  void addNewMessageListener(void Function(Map<String, dynamic>) listener) {
    _newMessageListeners.add(listener);
  }

  /// Remove a previously registered new-message listener.
  void removeNewMessageListener(void Function(Map<String, dynamic>) listener) {
    _newMessageListeners.remove(listener);
  }

  /// Remove a previously registered presence listener.
  void removePresenceListener(void Function(Map<String, dynamic>) listener) {
    _presenceListeners.remove(listener);
  }

  /// Add a block-status listener.
  void addBlockListener(void Function(Map<String, dynamic>) listener) {
    _blockListeners.add(listener);
  }

  /// Remove a previously registered block-status listener.
  void removeBlockListener(void Function(Map<String, dynamic>) listener) {
    _blockListeners.remove(listener);
  }

  /// Add a listener for 'conversation:read' events.
  void addConversationReadListener(
    void Function(Map<String, dynamic>) listener,
  ) {
    _conversationReadListeners.add(listener);
  }

  /// Remove a previously registered conversation:read listener.
  void removeConversationReadListener(
    void Function(Map<String, dynamic>) listener,
  ) {
    _conversationReadListeners.remove(listener);
  }

  /// Add a listener for 'conversation:unread' events.
  void addConversationUnreadListener(
    void Function(Map<String, dynamic>) listener,
  ) {
    _conversationUnreadListeners.add(listener);
  }

  /// Remove a previously registered conversation:unread listener.
  void removeConversationUnreadListener(
    void Function(Map<String, dynamic>) listener,
  ) {
    _conversationUnreadListeners.remove(listener);
  }

  /// Emit a user block change event to the server. Server should relay to affected users.
  void emitUserBlockChange({required String userId, required String status}) {
    try {
      final Map<String, dynamic> data = <String, dynamic>{
        'userId': userId,
        'status': status,
      };

      // Notify server
      _socket?.emit('user_block_change', data);

      // Optimistically notify all local listeners immediately so UI reacts everywhere
      for (final void Function(Map<String, dynamic>) l in _blockListeners) {
        try {
          l(data);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> connect({
    String? deviceId,
    String? conversationId,
    void Function(Map<String, dynamic>)? onMessage,
    void Function(Map<String, dynamic>)? onReceiveMessage,
    void Function(Map<String, dynamic>)? onNewMessage,
    void Function(Map<String, dynamic>)? onPresenceChange,
    void Function(Map<String, dynamic>)? onBlockChange,
    void Function(Map<String, dynamic>)? onCallIncoming,
    void Function()? onConnect,
  }) async {
    // Always register the provided callbacks to the listeners list
    if (onMessage != null && !_messageListeners.contains(onMessage))
      _messageListeners.add(onMessage);
    if (onReceiveMessage != null &&
        !_receiveListeners.contains(onReceiveMessage))
      _receiveListeners.add(onReceiveMessage);
    if (onNewMessage != null && !_newMessageListeners.contains(onNewMessage))
      _newMessageListeners.add(onNewMessage);
    if (onPresenceChange != null &&
        !_presenceListeners.contains(onPresenceChange))
      _presenceListeners.add(onPresenceChange);
    if (onBlockChange != null && !_blockListeners.contains(onBlockChange))
      _blockListeners.add(onBlockChange);
    if (onCallIncoming != null &&
        !_callIncomingListeners.contains(onCallIncoming))
      _callIncomingListeners.add(onCallIncoming);
    if (onConnect != null && !_connectListeners.contains(onConnect))
      _connectListeners.add(onConnect);

    // If we have an active socket object that isn't disposed
    if (_socket != null) {
      if (_socket!.connected) {
        if (onConnect != null) {
          try {
            onConnect();
          } catch (_) {}
        }
        _startHeartbeat();
        return;
      } else {
        // Socket exists but not connected. Re-connect it.
        _socket?.connect();
        return;
      }
    }

    // Establish a fresh connection.
    await disconnect();

    final String? token = await _tokenService.getAccessToken();
    final String tokenType = await _tokenService.getTokenType();

    // Format the token with Bearer prefix for auth header
    final String authToken = token != null && token.isNotEmpty
        ? '$tokenType $token'
        : '';

    final io.OptionBuilder optionBuilder = io.OptionBuilder().setTransports(
      <String>['websocket'],
    ).disableAutoConnect();

    // Pass token in auth object for proper WebSocket authentication
    if (authToken.isNotEmpty) {
      optionBuilder.setAuth(<String, dynamic>{'token': authToken});
    }

    _socket = io.io(_socketUrl, optionBuilder.build());

    _socket?.onConnect((_) {
      try {
        if (deviceId != null) {
          final Map<String, dynamic> payload = <String, dynamic>{
            'deviceId': deviceId,
            'channel': 'chat',
          };
          if (conversationId != null) {
            payload['conversationId'] = conversationId;
          }
          _socket?.emit('presence:join', payload);
        }

        // Re-join any previously joined conversation rooms
        try {
          for (final String id in _joinedConversations) {
            _socket?.emit('join_conversation', <String, dynamic>{
              'conversationId': id,
            });
          }
        } catch (_) {}

        // Start periodic presence heartbeat while connected
        _startHeartbeat();

        for (final void Function() l in _connectListeners) {
          try {
            l();
          } catch (_) {}
        }
        if (onConnect != null) {
          try {
            onConnect();
          } catch (_) {}
        }
      } catch (_) {}
    });

    // Handle reconnection to ensure token is resent
    _socket?.onReconnect((_) {
      try {
        // Re-authenticate with token on reconnection
        _startHeartbeat();

        // Re-join any previously joined conversation rooms
        try {
          for (final String id in _joinedConversations) {
            _socket?.emit('join_conversation', <String, dynamic>{
              'conversationId': id,
            });
          }
        } catch (_) {}
      } catch (_) {}
    });

    _socket?.on('message', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l in _messageListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    _socket?.on('receive_message', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l in _receiveListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    _socket?.on('new_message', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l
            in _newMessageListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    // Conversation-level unread/read events
    _socket?.on('conversation:unread', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l
            in _conversationUnreadListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    _socket?.on('conversation:read', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l
            in _conversationReadListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    // Listen to the new standard presence:update event
    _socket?.on('presence:update', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l
            in _presenceListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    // Keep backwards compatibility for existing user_presence_change if needed
    _socket?.on('user_presence_change', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l
            in _presenceListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    // Server may broadcast user block status changes using this event name.
    _socket?.on('user_block_change', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l in _blockListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    _socket?.on('call:incoming', (dynamic data) {
      if (data is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        for (final void Function(Map<String, dynamic>) l
            in _callIncomingListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    _socket?.connect();
  }

  void joinConversation(String conversationId) {
    try {
      _joinedConversations.add(conversationId);
      _socket?.emit('join_conversation', <String, dynamic>{
        'conversationId': conversationId,
      });
    } catch (_) {}
  }

  void leaveConversation(String conversationId) {
    try {
      _joinedConversations.remove(conversationId);
      _socket?.emit('leave_conversation', <String, dynamic>{
        'conversationId': conversationId,
      });
    } catch (_) {}
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

  /// Refresh socket connection after login to apply the new token.
  /// This ensures the socket is authenticated with the latest access token.
  Future<void> refreshConnectionAfterLogin() async {
    try {
      // Disconnect existing connection to force fresh connection with new token
      await disconnect();

      // Reconnect with the new token from storage
      await connect();
    } catch (_) {
      // Silently fail - connection can retry on next action
    }
  }

  Future<void> disconnect() async {
    try {
      _stopHeartbeat();
      _joinedConversations.clear();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
  }

  /// Request a presence batch for a list of userIds. Backend may or may not support this.
  void requestPresenceBatch(List<String> userIds) {
    try {
      if (userIds.isEmpty) return;
      _socket?.emit('presence:batch', <String, dynamic>{'userIds': userIds});
    } catch (_) {}
  }

  String get _socketUrl {
    final String apiBaseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
    final Uri uri = Uri.parse(apiBaseUrl);
    return uri.replace(path: '/chat').toString();
  }
}
