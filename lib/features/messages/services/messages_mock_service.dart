import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/token_service.dart';
import 'chat_socket_service.dart';
import '../models/message_models.dart';

class MessagesMockService {
  MessagesMockService({
    required ApiClient apiClient,
    required TokenService tokenService,
    required ChatSocketService chatSocketService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService,
       _chatSocketService = chatSocketService;

  final ApiClient _apiClient;
  // token service is kept for potential auth needs in requests
  // ignore: unused_field
  final TokenService _tokenService;
  final ChatSocketService _chatSocketService;

  final Set<String> _blockedThreadIds = <String>{};

  Future<MessagesResponseModel> fetchMessages() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/chat/conversations',
      );
      final dynamic data = response.data;

      if (data is List) {
        final List<MessageThreadModel> threads = data
            .map<MessageThreadModel>((dynamic conv) {
              final Map<String, dynamic> c = conv is Map
                  ? Map<String, dynamic>.from(conv)
                  : <String, dynamic>{};
              final dynamic lastMsg = c['lastMessage'];
              final String lastMessageText = lastMsg is Map
                  ? (lastMsg['content']?.toString() ?? '')
                  : (lastMsg?.toString() ?? '');
              final String timeLabel = _formatTimeLabel(
                c['lastMessageAt']?.toString(),
              );

              String learnerName = 'Conversation';
              String avatarUrl = '';
              final dynamic members =
                  c['members'] ?? c['participants'] ?? c['members'];
              if (members is List && members.isNotEmpty) {
                final dynamic first = members.first;
                if (first is Map && first['user'] is Map) {
                  learnerName =
                      first['user']['fullName']?.toString() ?? learnerName;
                  avatarUrl = first['user']['avatarUrl']?.toString() ?? '';
                } else if (first is Map && first['fullName'] != null) {
                  learnerName = first['fullName'].toString();
                  avatarUrl = first['avatarUrl']?.toString() ?? '';
                }
              }

              return MessageThreadModel(
                id: c['id']?.toString() ?? '',
                learnerName: learnerName,
                lastMessage: lastMessageText,
                timeLabel: timeLabel,
                unreadCount: 0,
                isOnline: false,
                isHighlighted: false,
                isDelivered: true,
                avatarUrl: avatarUrl.isNotEmpty
                    ? avatarUrl
                    : 'https://i.pravatar.cc/120?img=12',
              );
            })
            .toList(growable: false);

        return MessagesResponseModel(
          currentUserName: '',
          currentUserAvatarUrl: '',
          threads: threads,
        );
      }
    } catch (err) {
      // fallback to mock data below
    }

    // Fallback mock
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const MessagesResponseModel(
      currentUserName: 'Alex Rivera',
      currentUserAvatarUrl: 'https://i.pravatar.cc/120?img=11',
      threads: <MessageThreadModel>[],
    );
  }

  Future<MessageChatModel> fetchChat(MessageThreadModel thread) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/chat/conversations/${thread.id}/messages',
      );
      final dynamic data = response.data;
      if (data is List) {
        final List<MessageChatItemModel> messages = data
            .map<MessageChatItemModel>((dynamic msg) {
              final Map<String, dynamic> m = msg is Map
                  ? Map<String, dynamic>.from(msg)
                  : <String, dynamic>{};
              final String text = m['content']?.toString() ?? '';
              final String id = m['id']?.toString() ?? '';
              final String timeLabel = _formatTimeLabel(
                m['createdAt']?.toString(),
              );
              final bool isMine = false;
              return MessageChatItemModel(
                id: id,
                text: text,
                timeLabel: timeLabel,
                statusLabel: '',
                isMine: isMine,
              );
            })
            .toList(growable: false);

        return MessageChatModel(
          contactName: thread.learnerName,
          contactStatus: thread.isOnline ? 'Online' : 'Offline',
          contactAvatarUrl: thread.avatarUrl,
          isOnline: thread.isOnline,
          messages: messages,
        );
      }
    } catch (err) {
      // fallback to mock
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));

    return MessageChatModel(
      contactName: thread.learnerName,
      contactStatus: thread.isOnline ? 'Online' : 'Offline',
      contactAvatarUrl: thread.avatarUrl,
      isOnline: thread.isOnline,
      messages: const <MessageChatItemModel>[
        MessageChatItemModel(
          id: 'm1',
          text: 'Hello! This is a fallback message.',
          timeLabel: '10:24 AM',
          statusLabel: '',
          isMine: false,
        ),
      ],
    );
  }

  Future<MessageUserProfileModel> fetchUserProfile(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return MessageUserProfileModel(
      name: 'Alex Rivera',
      statusLabel: 'ONLINE',
      avatarUrl: 'https://i.pravatar.cc/180?img=11',
      streakValue: '45 Days',
      xpValue: '12,450 XP',
      isBlocked: _blockedThreadIds.contains(threadId),
    );
  }

  Future<MessageUserProfileModel> blockUser(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _blockedThreadIds.add(threadId);
    return fetchUserProfile(threadId);
  }

  Future<MessageUserProfileModel> unblockUser(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _blockedThreadIds.remove(threadId);
    return fetchUserProfile(threadId);
  }

  Future<MessageReportResultModel> submitReport(
    MessageReportRequestModel request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const MessageReportResultModel(
      referenceId: '#SHK-REP-4922',
      statusLabel: 'Under Review',
      reviewSteps: <String>[
        'Our team has been notified',
        'Manual review is in progress',
        'You will be notified once a decision is made',
      ],
    );
  }

  Future<List<Map<String, dynamic>>> fetchPeers() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/chat/peers',
      );
      final dynamic data = response.data;
      if (data is List) {
        return data
            .map<Map<String, dynamic>>((dynamic u) {
              return u is Map
                  ? Map<String, dynamic>.from(u)
                  : <String, dynamic>{};
            })
            .toList(growable: false);
      }
    } catch (_) {}

    return <Map<String, dynamic>>[];
  }

  void sendMessageViaSocket({
    required String conversationId,
    String? clientMessageId,
    String? content,
  }) {
    _chatSocketService.sendMessage(
      conversationId: conversationId,
      clientMessageId: clientMessageId,
      content: content,
    );
  }

  Future<List<MessageChatItemModel>> fetchChatPage(
    MessageThreadModel thread, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/chat/conversations/${thread.id}/messages',
        queryParameters: <String, dynamic>{'page': page, 'limit': limit},
      );
      final dynamic data = response.data;
      if (data is List) {
        final List<MessageChatItemModel> messages = data
            .map<MessageChatItemModel>((dynamic msg) {
              final Map<String, dynamic> m = msg is Map
                  ? Map<String, dynamic>.from(msg)
                  : <String, dynamic>{};
              final String text = m['content']?.toString() ?? '';
              final String id = m['id']?.toString() ?? '';
              final String timeLabel = _formatTimeLabel(
                m['createdAt']?.toString(),
              );
              final bool isMine = false;
              return MessageChatItemModel(
                id: id,
                text: text,
                timeLabel: timeLabel,
                statusLabel: '',
                isMine: isMine,
                isSystem: m['isSystem'] as bool? ?? false,
              );
            })
            .toList(growable: false);

        return messages;
      }
    } catch (err) {
      // fallback to generated mock messages
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));

    final List<MessageChatItemModel> generated = <MessageChatItemModel>[];
    final int start = (page - 1) * limit + 1;
    for (int i = 0; i < limit; i++) {
      final int idx = start + i;
      generated.add(
        MessageChatItemModel(
          id: 'old-${thread.id}-p$page-$idx',
          text: 'Older message #$idx',
          timeLabel: _formatTimeLabel(
            DateTime.now()
                .subtract(Duration(minutes: idx * 5))
                .toIso8601String(),
          ),
          statusLabel: '',
          isMine: false,
        ),
      );
    }

    return generated;
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
}
