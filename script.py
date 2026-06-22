import re

with open(r'e:\ShafaCode\App\italy_app\lib\features\messages\services\chat_socket_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

replacement = '''  Future<void> connect({
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
    if (onMessage != null && !_messageListeners.contains(onMessage)) _messageListeners.add(onMessage);
    if (onReceiveMessage != null && !_receiveListeners.contains(onReceiveMessage)) _receiveListeners.add(onReceiveMessage);
    if (onNewMessage != null && !_newMessageListeners.contains(onNewMessage)) _newMessageListeners.add(onNewMessage);
    if (onPresenceChange != null && !_presenceListeners.contains(onPresenceChange)) _presenceListeners.add(onPresenceChange);
    if (onBlockChange != null && !_blockListeners.contains(onBlockChange)) _blockListeners.add(onBlockChange);
    if (onCallIncoming != null && !_callIncomingListeners.contains(onCallIncoming)) _callIncomingListeners.add(onCallIncoming);
    if (onConnect != null && !_connectListeners.contains(onConnect)) _connectListeners.add(onConnect);

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
        for (final void Function(Map<String, dynamic>) l in _newMessageListeners) {
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
        for (final void Function(Map<String, dynamic>) l in _presenceListeners) {
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
        for (final void Function(Map<String, dynamic>) l in _presenceListeners) {
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
        for (final void Function(Map<String, dynamic>) l in _callIncomingListeners) {
          try {
            l(map);
          } catch (_) {}
        }
      }
    });

    _socket?.connect();
  }'''

# Extract regex pattern to match old connect function
pattern = re.compile(r'  Future<void> connect\(\{.*?_socket\?\.connect\(\);\n  \}', re.DOTALL)

if not pattern.search(content):
    print("Could not find the function block!")
else:
    new_content = pattern.sub(replacement, content)
    with open(r'e:\ShafaCode\App\italy_app\lib\features\messages\services\chat_socket_service.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Successfully replaced.")
