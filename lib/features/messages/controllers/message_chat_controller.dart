import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/message_models.dart';
import '../models/presence_model.dart';
import '../sub-feature/user-block/service/user_block_api_service.dart';
import '../services/messages_service.dart';
import '../services/chat_socket_service.dart';
import '../../../core/services/token_service.dart';
import '../sub-feature/call/views/message_call_view.dart';
import '../sub-feature/call/controllers/message_call_controller.dart';
import '../sub-feature/call/models/message_call_models.dart';
import '../sub-feature/call/service/message_call_mock_service.dart';
import '../views/message_user_info_view.dart';
import 'message_user_info_controller.dart';
import 'messages_controller.dart';
import '../services/presence_service.dart';

class MessageChatController extends GetxController {
  final MessageThreadModel thread;
  final MessagesMockService _messagesMockService;

  MessageChatController({
    required this.thread,
    required MessagesMockService messagesMockService,
  }) : _messagesMockService = messagesMockService;

  final RxBool isLoading = false.obs;
  final Rxn<MessageChatModel> chat = Rxn<MessageChatModel>();
  final TextEditingController chatTextController = TextEditingController();
  final ScrollController chatScrollController = ScrollController();
  bool _shouldAutoScrollChat = true;
  String? _currentUserId;
  ChatSocketService? _socketService;
  final List<Map<String, String>> _pendingSends = <Map<String, String>>[];
  final RxBool isSending = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString blockStatus = 'none'.obs;
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    loadChat();
    checkBlockStatus();
    chatScrollController.addListener(_handleChatScroll);
    _initSocket();
    _initPresenceSync();
  }

  void _initPresenceSync() {
    try {
      if (Get.isRegistered<PresenceService>()) {
        final PresenceService ps = Get.find<PresenceService>();
        ever(ps.presenceMap, (Map<String, MessagePresenceModel> map) {
          final String otherUserId =
              chat.value?.contactId ?? thread.contactId ?? thread.id;
          final MessagePresenceModel? p = map[otherUserId];
          if (p != null) {
            final current = chat.value;
            if (current != null && current.isOnline != p.isOnline) {
              chat.value = current.copyWith(
                isOnline: p.isOnline,
                contactStatus: p.isOnline ? 'Online' : 'Offline',
              );
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    chatTextController.dispose();
    chatScrollController.dispose();
    try {
      if (chat.value != null) {
        _socketService?.leaveConversation(thread.id);
      }
    } catch (_) {}
    super.onClose();
  }

  Future<void> checkBlockStatus() async {
    try {
      if (!Get.isRegistered<UserBlockApiService>()) {
        Get.lazyPut<UserBlockApiService>(
          () => UserBlockApiService(apiClient: Get.find()),
        );
      }
      final UserBlockApiService api = Get.find<UserBlockApiService>();
      final String otherUserId =
          chat.value?.contactId ?? thread.contactId ?? thread.id;
      final res = await api.getBlockStatus(otherUserId);
      if (res.success && res.data != null) {
        blockStatus.value = res.data!.status;
      }
    } catch (_) {}
  }

  Future<void> unblockUser() async {
    try {
      final UserBlockApiService api = Get.find<UserBlockApiService>();
      final String otherUserId =
          chat.value?.contactId ?? thread.contactId ?? thread.id;
      final res = await api.unblockUser(otherUserId);
      if (res.success) {
        blockStatus.value = 'none';
        Get.snackbar(
          'Unblocked',
          'You can now message this user.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Failed',
          'Could not unblock user. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadChat() async {
    isLoading.value = true;
    try {
      final MessageChatModel fetched = await _messagesMockService.fetchChat(
        thread,
      );

      // Merge fetched messages with any messages that may have arrived via
      // socket or been created optimistically to avoid wiping them out.
      final MessageChatModel? current = chat.value;
      if (current == null || current.messages.isEmpty) {
        chat.value = fetched;
      } else {
        final List<MessageChatItemModel> serverMsgs =
            List<MessageChatItemModel>.from(fetched.messages);
        final Set<String> serverIds = serverMsgs.map((e) => e.id).toSet();

        // Append any local-only messages
        final List<MessageChatItemModel> merged =
            List<MessageChatItemModel>.from(serverMsgs);
        for (final MessageChatItemModel m in current.messages) {
          if (!serverIds.contains(m.id)) merged.add(m);
        }

        // Ensure chronological ordering (oldest -> newest)
        merged.sort((MessageChatItemModel a, MessageChatItemModel b) {
          try {
            final DateTime da = DateTime.parse(
              a.createdAtIso ?? DateTime.now().toIso8601String(),
            );
            final DateTime db = DateTime.parse(
              b.createdAtIso ?? DateTime.now().toIso8601String(),
            );
            return da.compareTo(db);
          } catch (_) {
            return 0;
          }
        });

        chat.value = fetched.copyWith(messages: merged);
      }

      // If we have a presence entry, keep it. Otherwise prefer the
      // `/users/:id` profile endpoint for a definitive online state so
      // the header status matches the user info screen.
      final String otherUserId =
          chat.value?.contactId ?? thread.contactId ?? thread.id;

      try {
        if (Get.isRegistered<PresenceService>()) {
          final PresenceService ps = Get.find<PresenceService>();
          final MessagePresenceModel? p = ps.presenceMap[otherUserId];
          if (p != null && chat.value != null) {
            chat.value = chat.value!.copyWith(
              isOnline: p.isOnline,
              contactStatus: p.isOnline ? 'Online' : 'Offline',
            );
          }
        }
      } catch (_) {}

      // Always attempt to fetch the user's profile to get authoritative
      // info, but prioritize PresenceService for online/offline state to avoid
      // stale data overwriting real-time socket events.
      try {
        final profile = await _messagesMockService.fetchUserProfile(
          otherUserId,
          fallbackName: chat.value?.contactName ?? thread.learnerName,
          fallbackAvatarUrl: chat.value?.contactAvatarUrl ?? thread.avatarUrl,
        );
        if (chat.value != null) {
          bool isOnline = profile.statusLabel == 'ONLINE';

          // Use presence service as SSOT if it has a record
          if (Get.isRegistered<PresenceService>()) {
            final p = Get.find<PresenceService>().presenceMap[otherUserId];
            if (p != null) {
              isOnline = p.isOnline;
            }
          }

          chat.value = chat.value!.copyWith(
            isOnline: isOnline,
            contactStatus: isOnline ? 'Online' : 'Offline',
            contactAvatarUrl: profile.avatarUrl,
            contactName: profile.name,
          );
        }
      } catch (_) {}

      // Scroll to bottom to show latest messages after chat loads
      _autoScrollToBottom();
      // Persist read state on server (non-blocking)
      try {
        _messagesMockService.markConversationRead(thread.id);
      } catch (_) {}
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initSocket() async {
    try {
      _socketService = Get.find<ChatSocketService>();
    } catch (_) {
      return;
    }

    // Try to extract current user id from token for `isMine` detection
    try {
      final String? token = await Get.find<TokenService>().getAccessToken();
      _currentUserId = _extractUserIdFromToken(token);
    } catch (_) {
      _currentUserId = null;
    }

    // Tell PresenceService we're using socket now
    String? deviceId;
    try {
      if (Get.isRegistered<PresenceService>()) {
        final PresenceService ps = Get.find<PresenceService>();
        deviceId = ps.deviceId.isNotEmpty ? ps.deviceId : null;
      }
    } catch (_) {}

    await _socketService?.connect(
      deviceId: deviceId,
      conversationId: thread.id,
      onMessage: (Map<String, dynamic> data) => _handleServerMessage(data),
      onNewMessage: (Map<String, dynamic> data) => _handleServerMessage(data),
      onReceiveMessage: (Map<String, dynamic> data) =>
          _handleServerMessage(data),
      onBlockChange: (Map<String, dynamic> data) {
        try {
          final String userId =
              data['userId']?.toString() ??
              data['blockedUserId']?.toString() ??
              '';
          final String status =
              data['status']?.toString() ??
              data['blockStatus']?.toString() ??
              '';
          final MessageChatModel? current = chat.value;
          if (current != null) {
            if (userId == thread.id || userId == (thread.contactId ?? '')) {
              // Update local chat controller blockStatus so UI reflects change immediately
              if (status.isNotEmpty) {
                blockStatus.value = status;
              }

              // Update chat model contact status
              try {
                chat.value = current.copyWith(
                  contactStatus: status == 'none'
                      ? (current.contactStatus)
                      : (status == 'blocked_by_me'
                            ? 'You blocked this user'
                            : 'You cannot message this user.'),
                );
              } catch (_) {}
            }
          }
        } catch (_) {}
      },
      onCallIncoming: (Map<String, dynamic> data) {},
      onConnect: () {
        try {
          _socketService?.joinConversation(thread.id);
        } catch (_) {}
        _flushPendingSends();
      },
    );
  }

  String? _extractUserIdFromToken(String? token) {
    if (token == null) return null;
    final List<String> parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final String payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> map =
          json.decode(decoded) as Map<String, dynamic>;
      return map['sub']?.toString();
    } catch (_) {
      return null;
    }
  }

  final RxBool showScrollToBottom = false.obs;

  void _handleChatScroll() {
    if (!chatScrollController.hasClients) return;
    final ScrollPosition position = chatScrollController.position;
    _shouldAutoScrollChat = position.maxScrollExtent - position.pixels <= 48;
    showScrollToBottom.value = position.maxScrollExtent - position.pixels > 150;
    // If scrolled to top, attempt to load older messages
    if (position.pixels <= position.minScrollExtent + 48 &&
        !isLoadingMore.value) {
      _loadMore();
    }
  }

  void scrollToBottom() {
    if (chatScrollController.hasClients) {
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _autoScrollToBottom() {
    try {
      if (chatScrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (chatScrollController.hasClients) {
            chatScrollController.jumpTo(
              chatScrollController.position.maxScrollExtent,
            );
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMore() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final int nextPage = _currentPage + 1;
      final List<MessageChatItemModel> older = await _messagesMockService
          .fetchChatPage(thread, page: nextPage);
      if (older.isNotEmpty) {
        final MessageChatModel? current = chat.value;
        if (current != null) {
          final Set<String> existingIds = current.messages
              .map((e) => e.id)
              .toSet();
          final List<MessageChatItemModel> uniqueOlder = older
              .where((e) => !existingIds.contains(e.id))
              .toList();

          final List<MessageChatItemModel> updated =
              List<MessageChatItemModel>.from(uniqueOlder)
                ..addAll(current.messages);
          chat.value = current.copyWith(messages: updated);
          _currentPage = nextPage;
        }
      }
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh chat (pull-to-refresh)
  Future<void> refreshChat() async {
    _currentPage = 1;
    await loadChat();

    // Re-join conversation to ensure socket state is up-to-date
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      _socketService?.leaveConversation(thread.id);
      _socketService?.joinConversation(thread.id);
    } catch (_) {}

    // Attempt to scroll to bottom after refresh
    try {
      if (chatScrollController.hasClients) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        chatScrollController.jumpTo(
          chatScrollController.position.maxScrollExtent,
        );
      }
    } catch (_) {}
  }

  void _handleServerMessage(Map<String, dynamic> msg) {
    try {
      // Support multiple server payload shapes: prefer `messageId`, fallback to `id`.
      final String messageId =
          msg['messageId']?.toString() ?? msg['id']?.toString() ?? '';
      final String content =
          msg['content']?.toString() ?? msg['text']?.toString() ?? '';
      final String createdAt =
          msg['createdAt']?.toString() ??
          msg['created_at']?.toString() ??
          DateTime.now().toIso8601String();
      final String senderId =
          msg['senderId']?.toString() ?? msg['userId']?.toString() ?? '';
      final String clientMessageId =
          msg['clientMessageId']?.toString() ??
          msg['client_msg_id']?.toString() ??
          '';
      final String statusFromServer = msg['status']?.toString() ?? '';

      final MessageChatItemModel item = MessageChatItemModel(
        id: messageId.isNotEmpty
            ? messageId
            : (clientMessageId.isNotEmpty
                  ? clientMessageId
                  : DateTime.now().millisecondsSinceEpoch.toString()),
        text: content,
        timeLabel: _formatTimeLabel(createdAt),
        createdAtIso: createdAt,
        statusLabel: senderId == _currentUserId
            ? (statusFromServer.isNotEmpty ? statusFromServer : 'Delivered')
            : '',
        isMine: senderId == _currentUserId,
      );

      final MessageChatModel? current = chat.value;
      if (current == null) return;

      // Find existing by server id or by clientMessageId (optimistic id)
      final int existingIndex = current.messages.indexWhere((
        MessageChatItemModel m,
      ) {
        final String mid = m.id;
        return (messageId.isNotEmpty && mid == messageId) ||
            (clientMessageId.isNotEmpty && mid == clientMessageId);
      });

      final List<MessageChatItemModel> updated =
          List<MessageChatItemModel>.from(current.messages);
      if (existingIndex >= 0) {
        // Replace optimistic message with server-backed message (preserve ordering)
        updated[existingIndex] = item;
      } else {
        updated.add(item);
      }

      // keep original ordering (new messages appended)

      // keep size limit
      if (updated.length > 200) {
        updated.removeRange(0, updated.length - 200);
      }

      chat.value = current.copyWith(messages: updated);

      // Update conversation preview in messages list
      try {
        if (Get.isRegistered<MessagesController>()) {
          final MessagesController mc = Get.find<MessagesController>();
          mc.updateThreadPreview(
            threadId: thread.id,
            lastMessage: item.text,
            isoTime: createdAt,
            isMine: item.isMine,
          );
        }
      } catch (_) {}

      if (_shouldAutoScrollChat) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (chatScrollController.hasClients) {
            chatScrollController.animateTo(
              chatScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (_) {}
  }

  Future<void> sendMessage() async {
    final String text = chatTextController.text.trim();
    if (text.isEmpty || isSending.value || blockStatus.value != 'none') return;

    final MessageChatModel? current = chat.value;
    if (current == null) return;

    isSending.value = true;
    final String clientMessageId = DateTime.now().millisecondsSinceEpoch
        .toString();

    final MessageChatItemModel optimistic = MessageChatItemModel(
      id: clientMessageId,
      text: text,
      timeLabel: _formatTimeLabel(DateTime.now().toIso8601String()),
      createdAtIso: DateTime.now().toIso8601String(),
      statusLabel: 'Sending',
      isMine: true,
    );

    final List<MessageChatItemModel> updated = List<MessageChatItemModel>.from(
      current.messages,
    )..add(optimistic);
    chat.value = current.copyWith(messages: updated);
    chatTextController.clear();

    // update conversation preview immediately with optimistic text
    try {
      if (Get.isRegistered<MessagesController>()) {
        final MessagesController mc = Get.find<MessagesController>();
        mc.updateThreadPreview(
          threadId: thread.id,
          lastMessage: optimistic.text,
          isoTime: DateTime.now().toIso8601String(),
          isMine: true,
        );
      }
    } catch (_) {}

    try {
      _messagesMockService.sendMessageViaSocket(
        conversationId: thread.id,
        clientMessageId: clientMessageId,
        content: text,
      );
    } catch (_) {
      // If socket isn't connected, queue the message for later
      if (_socketService == null || !_socketService!.isConnected) {
        _pendingSends.add(<String, String>{
          'clientMessageId': clientMessageId,
          'content': text,
        });
        // update optimistic status to Queued
        final int idx = updated.indexWhere(
          (MessageChatItemModel m) => m.id == clientMessageId,
        );
        if (idx >= 0) {
          updated[idx] = updated[idx].copyWith(statusLabel: 'Queued');
          chat.value = current.copyWith(messages: updated);
        }
        isSending.value = false;
        return;
      }
      final int idx = updated.indexWhere(
        (MessageChatItemModel m) => m.id == clientMessageId,
      );
      if (idx >= 0) {
        updated[idx] = updated[idx].copyWith(statusLabel: 'Failed');
        chat.value = current.copyWith(messages: updated);
      }
    } finally {
      isSending.value = false;
    }
  }

  void _flushPendingSends() {
    if (_pendingSends.isEmpty) return;
    final MessageChatModel? current = chat.value;
    if (current == null) return;

    for (final Map<String, String> p in List<Map<String, String>>.from(
      _pendingSends,
    )) {
      final String clientId = p['clientMessageId'] ?? '';
      final String content = p['content'] ?? '';
      try {
        _messagesMockService.sendMessageViaSocket(
          conversationId: thread.id,
          clientMessageId: clientId,
          content: content,
        );

        // update message status from Queued -> Sending
        final int idx = current.messages.indexWhere(
          (MessageChatItemModel m) => m.id == clientId,
        );
        if (idx >= 0) {
          final List<MessageChatItemModel> updated =
              List<MessageChatItemModel>.from(current.messages);
          updated[idx] = updated[idx].copyWith(statusLabel: 'Sending');
          chat.value = current.copyWith(messages: updated);
        }
      } catch (_) {
        // keep queued for retry later
        continue;
      }
      _pendingSends.remove(p);
    }
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

  void openAudioCall() {
    _openCall(MessageCallType.audio);
  }

  void openVideoCall() {
    _openCall(MessageCallType.video);
  }

  void _openCall(MessageCallType callType) {
    if (blockStatus.value != 'none') {
      Get.snackbar('Blocked', "You cannot call this user.");
      return;
    }

    final MessageChatModel? currentChat = chat.value;

    if (currentChat == null) return;

    Get.to<void>(
      () => const MessageCallView(),
      binding: BindingsBuilder(() {
        Get.put<MessageCallController>(
          MessageCallController(
            conversationId: thread.id,
            callType: callType,
            participant: MessageCallParticipantModel(
              id: thread.id,
              name: currentChat.contactName,
              avatarUrl: currentChat.contactAvatarUrl,
              isOnline: currentChat.isOnline,
            ),
            messageCallService: MessageCallMockService(),
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }

  void openUserInfo() {
    Get.to<void>(
      () => const MessageUserInfoView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<UserBlockApiService>()) {
          Get.lazyPut<UserBlockApiService>(
            () => UserBlockApiService(apiClient: Get.find()),
          );
        }
        Get.put<MessageUserInfoController>(
          MessageUserInfoController(
            threadId: chat.value?.contactId ?? thread.contactId ?? thread.id,
            fallbackName: chat.value?.contactName ?? thread.learnerName,
            fallbackAvatarUrl: chat.value?.contactAvatarUrl ?? thread.avatarUrl,
            messagesMockService: _messagesMockService,
            userBlockApiService: Get.find<UserBlockApiService>(),
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }
}
