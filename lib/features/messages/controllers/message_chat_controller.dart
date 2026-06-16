import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/message_models.dart';
import '../services/messages_mock_service.dart';
import '../services/chat_socket_service.dart';
import '../../../core/services/token_service.dart';
import '../sub-feature/call/  views/message_call_view.dart';
import '../sub-feature/call/controllers/message_call_controller.dart';
import '../sub-feature/call/models/ message_call_models.dart';
import '../sub-feature/call/service/message_call_mock_service.dart';
import '../views/message_user_info_view.dart';
import 'message_user_info_controller.dart';

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
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    loadChat();
    chatScrollController.addListener(_handleChatScroll);
    _initSocket();
  }

  Future<void> loadChat() async {
    isLoading.value = true;
    try {
      chat.value = await _messagesMockService.fetchChat(thread);
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

    await _socketService?.connect(
      onMessage: (Map<String, dynamic> data) => _handleServerMessage(data),
      onNewMessage: (Map<String, dynamic> data) => _handleServerMessage(data),
      onReceiveMessage: (Map<String, dynamic> data) =>
          _handleServerMessage(data),
      onPresenceChange: (Map<String, dynamic> data) {
        try {
          final String userId = data['userId']?.toString() ?? '';
          final bool isOnline = data['isOnline'] == true;
          final MessageChatModel? current = chat.value;
          if (current != null) {
            // If presence change targets this conversation's participant, update online status
            if (userId == thread.id) {
              chat.value = current.copyWith(isOnline: isOnline);
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

  void _handleChatScroll() {
    if (!chatScrollController.hasClients) return;
    final ScrollPosition position = chatScrollController.position;
    _shouldAutoScrollChat = position.maxScrollExtent - position.pixels <= 48;
    // If scrolled to top, attempt to load older messages
    if (position.pixels <= position.minScrollExtent + 48 &&
        !isLoadingMore.value) {
      _loadMore();
    }
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
          final List<MessageChatItemModel> updated =
              List<MessageChatItemModel>.from(older)..addAll(current.messages);
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

      if (_shouldAutoScrollChat) {
        // attempt to scroll — view will handle actual scroll; we don't force here
      }
    } catch (_) {}
  }

  Future<void> sendMessage() async {
    final String text = chatTextController.text.trim();
    if (text.isEmpty || isSending.value) return;

    final MessageChatModel? current = chat.value;
    if (current == null) return;

    isSending.value = true;
    final String clientMessageId = DateTime.now().millisecondsSinceEpoch
        .toString();

    final MessageChatItemModel optimistic = MessageChatItemModel(
      id: clientMessageId,
      text: text,
      timeLabel: _formatTimeLabel(DateTime.now().toIso8601String()),
      statusLabel: 'Sending',
      isMine: true,
    );

    final List<MessageChatItemModel> updated = List<MessageChatItemModel>.from(
      current.messages,
    )..add(optimistic);
    chat.value = current.copyWith(messages: updated);
    chatTextController.clear();

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
        Get.put<MessageUserInfoController>(
          MessageUserInfoController(
            threadId: thread.id,
            messagesMockService: _messagesMockService,
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }
}
