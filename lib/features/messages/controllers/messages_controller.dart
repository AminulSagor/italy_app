import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';

import '../models/message_models.dart';
import '../services/messages_mock_service.dart';
import '../views/message_chat_view.dart';
import '../../../core/services/token_service.dart';
import '../services/presence_service.dart';
import '../models/presence_model.dart';
import 'message_chat_controller.dart';
import '../services/chat_socket_service.dart';

class MessagesController extends GetxController {
  final MessagesMockService _messagesMockService;

  MessagesController({required MessagesMockService messagesMockService})
    : _messagesMockService = messagesMockService;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final RxString currentUserName = ''.obs;
  final RxString currentUserAvatarUrl = ''.obs;
  final RxList<MessageThreadModel> threads = <MessageThreadModel>[].obs;

  String? _currentUserId;

  Timer? _presenceTimer;
  final Set<String> _seenMessageIds = <String>{};

  // Keep a reference to the registered socket listener so we can remove it onClose
  void Function(Map<String, dynamic>)? _socketListener;

  List<MessageThreadModel> get filteredThreads {
    final String query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return threads;
    }

    return threads
        .where(
          (MessageThreadModel thread) =>
              thread.learnerName.toLowerCase().contains(query) ||
              thread.lastMessage.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadMessages();

    // debounce the search query and call the backend search when user pauses typing
    debounce<String>(searchQuery, (String val) {
      _performUserSearch(val);
    }, time: const Duration(milliseconds: 400));

    _initPresenceSync();
    _startPresencePolling();

    // Register a global socket listener so the conversation list updates immediately
    try {
      if (Get.isRegistered<ChatSocketService>()) {
        final ChatSocketService socket = Get.find<ChatSocketService>();
        _socketListener = (Map<String, dynamic> data) {
          _handleIncomingSocketMessage(data);
        };
        socket.addNewMessageListener(_socketListener!);
        socket.addMessageListener(_socketListener!);
        socket.addReceiveListener(_socketListener!);
        // conversation-level events
        socket.addConversationUnreadListener(_handleConversationUnread);
        socket.addConversationReadListener(_handleConversationRead);
      }
    } catch (_) {}

    // Initialize current user id from token for read event handling
    _initCurrentUserId();
  }

  @override
  void onClose() {
    _presenceTimer?.cancel();
    try {
      if (_socketListener != null && Get.isRegistered<ChatSocketService>()) {
        final ChatSocketService socket = Get.find<ChatSocketService>();
        socket.removeNewMessageListener(_socketListener!);
        socket.removeMessageListener(_socketListener!);
        socket.removeReceiveListener(_socketListener!);
        socket.removeConversationUnreadListener(_handleConversationUnread);
        socket.removeConversationReadListener(_handleConversationRead);
      }
    } catch (_) {}
    super.onClose();
  }

  void _initCurrentUserId() async {
    try {
      final TokenService tokenService = Get.find<TokenService>();
      final String? token = await tokenService.getAccessToken();
      if (token == null) {
        _currentUserId = null;
        return;
      }
      final List<String> parts = token.split('.');
      if (parts.length < 2) {
        _currentUserId = null;
        return;
      }
      final String payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> map =
          json.decode(decoded) as Map<String, dynamic>;
      _currentUserId = map['sub']?.toString();
    } catch (_) {
      _currentUserId = null;
    }
  }

  void _handleIncomingSocketMessage(Map<String, dynamic> msg) {
    try {
      final String messageId =
          msg['messageId']?.toString() ?? msg['id']?.toString() ?? '';

      // Deduplicate messages we've already processed
      if (messageId.isNotEmpty && _seenMessageIds.contains(messageId)) return;
      if (messageId.isNotEmpty) _seenMessageIds.add(messageId);

      final String content =
          msg['content']?.toString() ?? msg['text']?.toString() ?? '';
      final String createdAt =
          msg['createdAt']?.toString() ??
          msg['created_at']?.toString() ??
          DateTime.now().toIso8601String();

      final String senderId =
          msg['senderId']?.toString() ?? msg['userId']?.toString() ?? '';

      final String conversationId =
          msg['conversationId']?.toString() ??
          msg['threadId']?.toString() ??
          msg['conversation_id']?.toString() ??
          '';

      // Try to locate existing thread by conversation id or sender contact id
      int idx = -1;
      if (conversationId.isNotEmpty) {
        idx = threads.indexWhere(
          (t) => t.id == conversationId || t.contactId == conversationId,
        );
      }
      if (idx < 0 && senderId.isNotEmpty) {
        idx = threads.indexWhere(
          (t) => t.id == senderId || t.contactId == senderId,
        );
      }

      if (idx >= 0) {
        final MessageThreadModel old = threads[idx];
        final MessageThreadModel updated = old.copyWith(
          lastMessage: content,
          timeLabel: _formatTimeLabel(createdAt),
          unreadCount: (old.unreadCount ?? 0) + 1,
          isHighlighted: true,
        );
        threads.removeAt(idx);
        threads.insert(0, updated);
      } else {
        // New conversation — create a thread entry
        final String id = conversationId.isNotEmpty
            ? conversationId
            : (senderId.isNotEmpty
                  ? senderId
                  : DateTime.now().millisecondsSinceEpoch.toString());
        final String name =
            msg['senderName']?.toString() ??
            msg['senderFullName']?.toString() ??
            'User';
        final String avatar = msg['senderAvatar']?.toString() ?? '';
        final MessageThreadModel thread = MessageThreadModel(
          id: id,
          learnerName: name,
          lastMessage: content,
          timeLabel: _formatTimeLabel(createdAt),
          unreadCount: 1,
          isOnline: false,
          blockStatus: 'none',
          isHighlighted: true,
          isDelivered: true,
          avatarUrl: avatar.isNotEmpty
              ? avatar
              : 'https://i.pravatar.cc/120?img=12',
          contactId: senderId.isNotEmpty ? senderId : null,
        );
        // prevent duplicates
        threads.removeWhere(
          (t) => t.id == thread.id || t.contactId == thread.contactId,
        );
        threads.insert(0, thread);
      }
      threads.refresh();
    } catch (_) {}
  }

  void _startPresencePolling() {
    _presenceTimer?.cancel();
    // Poll every 30 seconds for real-time presence updates outside of chat
    _presenceTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchInitialPresence();
    });
  }

  void _initPresenceSync() {
    try {
      if (Get.isRegistered<PresenceService>()) {
        final PresenceService presenceService = Get.find<PresenceService>();
        // Reactively update thread presence when the global presence map changes
        ever(presenceService.presenceMap, (
          Map<String, MessagePresenceModel> map,
        ) {
          bool updated = false;
          for (int i = 0; i < threads.length; i++) {
            final String contactId = threads[i].contactId ?? '';
            final String threadId = threads[i].id;
            final MessagePresenceModel? p = map[contactId] ?? map[threadId];
            if (p != null && p.isOnline != threads[i].isOnline) {
              threads[i] = threads[i].copyWith(isOnline: p.isOnline);
              updated = true;
            }
          }
          if (updated) {
            threads.refresh();
          }
        });
      }
    } catch (_) {}
  }

  // Kept here for socket block syncing via global events.
  // Real-time messages while outside chat are not supported under new chat-only socket rule,
  // but if the socket IS active (e.g. ChatView open in background/split screen), we still listen.

  Future<void> loadMessages() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final MessagesResponseModel response = await _messagesMockService
          .fetchMessages();

      // Try to get user info from JWT token
      try {
        final TokenService tokenService = Get.find<TokenService>();
        final String? token = await tokenService.getAccessToken();
        if (token != null) {
          final List<String> parts = token.split('.');
          if (parts.length >= 2) {
            final String payload = parts[1];
            final String normalized = base64Url.normalize(payload);
            final String decoded = utf8.decode(base64Url.decode(normalized));
            final Map<String, dynamic> map =
                json.decode(decoded) as Map<String, dynamic>;
            currentUserName.value =
                map['name']?.toString() ??
                map['fullName']?.toString() ??
                response.currentUserName;
            currentUserAvatarUrl.value =
                map['avatarUrl']?.toString() ?? response.currentUserAvatarUrl;
          }
        } else {
          currentUserName.value = response.currentUserName;
          currentUserAvatarUrl.value = response.currentUserAvatarUrl;
        }
      } catch (_) {
        currentUserName.value = response.currentUserName;
        currentUserAvatarUrl.value = response.currentUserAvatarUrl;
      }

      threads.assignAll(_mergePreservedThreadState(response.threads));

      // Sync immediately with the global presence map to override any stale server data
      // that might have arrived if a socket event fired while the API request was in flight.
      try {
        if (Get.isRegistered<PresenceService>()) {
          final PresenceService ps = Get.find<PresenceService>();
          bool updated = false;
          final map = ps.presenceMap;
          for (int i = 0; i < threads.length; i++) {
            final String contactId = threads[i].contactId ?? '';
            final String threadId = threads[i].id;
            final MessagePresenceModel? p = map[contactId] ?? map[threadId];
            if (p != null && p.isOnline != threads[i].isOnline) {
              threads[i] = threads[i].copyWith(isOnline: p.isOnline);
              updated = true;
            }
          }
          if (updated) {
            threads.refresh();
          }
        }
      } catch (_) {}

      _fetchInitialPresence();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load conversations.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMessages() async {
    await loadMessages();
  }

  void removeThread(String threadId) {
    threads.removeWhere((t) => t.id == threadId);
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  List<MessageThreadModel> _mergePreservedThreadState(
    List<MessageThreadModel> refreshedThreads,
  ) {
    final Map<String, MessageThreadModel> preservedMap =
        <String, MessageThreadModel>{};

    for (final MessageThreadModel thread in threads) {
      if (thread.id.isNotEmpty) {
        preservedMap[thread.id] = thread;
      }
      if (thread.contactId != null && thread.contactId!.isNotEmpty) {
        preservedMap[thread.contactId!] = thread;
      }
    }

    final List<MessageThreadModel> merged = <MessageThreadModel>[];
    for (final MessageThreadModel refreshed in refreshedThreads) {
      final MessageThreadModel? preserved =
          preservedMap[refreshed.id] ??
          (refreshed.contactId != null
              ? preservedMap[refreshed.contactId!]
              : null);
      if (preserved != null) {
        merged.add(
          refreshed.copyWith(
            unreadCount: preserved.unreadCount,
            isHighlighted: preserved.isHighlighted,
          ),
        );
      } else {
        merged.add(refreshed);
      }
    }

    return merged;
  }

  Future<void> _performUserSearch(String q) async {
    final String query = q.trim();
    if (query.length < 2) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    try {
      final Map<String, dynamic> resp = await _messagesMockService
          .searchUsersByName(q: query);
      final List<dynamic>? items = resp['items'] is List<dynamic>
          ? resp['items'] as List<dynamic>
          : (resp['data'] is List<dynamic>
                ? resp['data'] as List<dynamic>
                : null);

      if (items != null) {
        final List<Map<String, dynamic>> parsed = items
            .map<Map<String, dynamic>>(
              (dynamic e) => e is Map<String, dynamic>
                  ? Map<String, dynamic>.from(e)
                  : <String, dynamic>{},
            )
            .toList(growable: false);
        searchResults.assignAll(parsed);
      } else {
        searchResults.clear();
      }
    } catch (_) {
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// Start or get a direct conversation with a user result and open the chat view.
  Future<void> startDirectConversation(Map<String, dynamic> user) async {
    final String otherUserId = (user['id'] ?? user['userId'])?.toString() ?? '';
    if (otherUserId.isEmpty) return;

    String? conversationId;
    try {
      conversationId = await _messagesMockService.createDirectConversation(
        otherUserId: otherUserId,
      );
    } catch (_) {}

    final MessageThreadModel thread = MessageThreadModel(
      id: conversationId ?? otherUserId,
      learnerName:
          user['fullName']?.toString() ?? user['name']?.toString() ?? 'User',
      lastMessage: '',
      timeLabel: '',
      unreadCount: 0,
      isOnline: user['isOnline'] as bool? ?? false,
      blockStatus: user['blockStatus']?.toString() ?? 'none',
      isHighlighted: false,
      isDelivered: true,
      avatarUrl:
          user['avatarUrl']?.toString() ?? 'https://i.pravatar.cc/120?img=12',
      contactId: otherUserId,
    );

    // Ensure we have a thread entry for navigation and quick access.
    threads.removeWhere(
      (t) => t.id == thread.id || t.contactId == thread.contactId,
    );
    threads.insert(0, thread);

    // clear search state
    searchQuery.value = '';
    searchResults.clear();

    // navigate to chat
    Get.to<void>(
      () => const MessageChatView(),
      binding: BindingsBuilder(() {
        Get.put<MessageChatController>(
          MessageChatController(
            thread: thread,
            messagesMockService: _messagesMockService,
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }

  void openChat(MessageThreadModel thread) {
    // Clear unread/highlight when opening the chat so the UI updates instantly
    try {
      final int idx = threads.indexWhere(
        (t) => t.id == thread.id || t.contactId == thread.contactId,
      );
      if (idx >= 0) {
        final MessageThreadModel old = threads[idx];
        threads[idx] = old.copyWith(unreadCount: 0, isHighlighted: false);
      }
    } catch (_) {}

    // Persist read state on server (do not block navigation)
    try {
      _messagesMockService.markConversationRead(thread.id);
    } catch (_) {}

    Get.to<void>(
      () => const MessageChatView(),
      binding: BindingsBuilder(() {
        Get.put<MessageChatController>(
          MessageChatController(
            thread: thread,
            messagesMockService: _messagesMockService,
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }

  void _handleConversationUnread(Map<String, dynamic> data) {
    try {
      final String conversationId = data['conversationId']?.toString() ?? '';
      if (conversationId.isEmpty) return;
      final int unreadCount = data['unreadCount'] is int
          ? data['unreadCount'] as int
          : int.tryParse(data['unreadCount']?.toString() ?? '') ?? 0;
      final bool isHighlighted = data['isHighlighted'] is bool
          ? data['isHighlighted'] as bool
          : (unreadCount > 0);

      final int idx = threads.indexWhere(
        (t) =>
            t.id == conversationId ||
            (t.contactId != null && t.contactId == conversationId),
      );
      if (idx >= 0) {
        final MessageThreadModel old = threads[idx];
        final MessageThreadModel updated = old.copyWith(
          unreadCount: unreadCount,
          isHighlighted: isHighlighted,
        );
        threads.removeAt(idx);
        threads.insert(0, updated);
        threads.refresh();
      }
    } catch (_) {}
  }

  void _handleConversationRead(Map<String, dynamic> data) {
    try {
      final String conversationId = data['conversationId']?.toString() ?? '';
      final String userId = data['userId']?.toString() ?? '';
      if (conversationId.isEmpty) return;

      final int idx = threads.indexWhere(
        (t) =>
            t.id == conversationId ||
            (t.contactId != null && t.contactId == conversationId),
      );
      if (idx >= 0) {
        final MessageThreadModel old = threads[idx];
        if (userId.isNotEmpty && userId == _currentUserId) {
          threads[idx] = old.copyWith(unreadCount: 0, isHighlighted: false);
          threads.refresh();
        }
      }
    } catch (_) {}
  }

  /// Update a thread's preview (last message and time) when a message is sent/received.
  void updateThreadPreview({
    required String threadId,
    required String lastMessage,
    required String isoTime,
    bool isMine = false,
  }) {
    final int idx = threads.indexWhere(
      (MessageThreadModel t) =>
          t.id == threadId || (t.contactId != null && t.contactId == threadId),
    );
    if (idx < 0) return;
    final MessageThreadModel old = threads[idx];
    // If the message is from the current user, clear unread/highlight.
    // For incoming messages we preserve the existing unread count.
    final MessageThreadModel updated = old.copyWith(
      lastMessage: lastMessage,
      timeLabel: _formatTimeLabel(isoTime),
      isDelivered: isMine ? true : old.isDelivered,
      unreadCount: isMine ? 0 : old.unreadCount,
      isHighlighted: isMine ? false : true,
    );
    threads.removeAt(idx);
    threads.insert(0, updated);
  }

  String _formatTimeLabel(String? iso) {
    if (iso == null) return '';
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      final int hour = dt.hour == 0
          ? 12
          : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final String minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute $ampm';
    } catch (_) {
      return '';
    }
  }

  Future<void> _fetchInitialPresence() async {
    try {
      final List<String> userIds = threads
          .map((e) => e.contactId ?? e.id)
          .where((id) => id.isNotEmpty)
          .toList();
      if (userIds.isEmpty) return;

      // Try to request presence statuses from the socket if the backend
      // supports a batch presence request. Otherwise presence updates
      // will arrive via `presence:update` / `user_presence_change` events.
      try {
        if (Get.isRegistered<ChatSocketService>()) {
          Get.find<ChatSocketService>().requestPresenceBatch(userIds);
        }
      } catch (_) {}
    } catch (_) {}
  }
}
