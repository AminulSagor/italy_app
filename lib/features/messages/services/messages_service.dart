import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/token_service.dart';
import 'chat_socket_service.dart';
import 'message_chat_api_service.dart';
import 'message_report_api_service.dart';
import '../models/message_models.dart';

class MessagesMockService {
  MessagesMockService({
    required ApiClient apiClient,
    required TokenService tokenService,
    required ChatSocketService chatSocketService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService,
       _chatSocketService = chatSocketService,
       _messageChatApiService = MessageChatApiService(
         apiClient: apiClient,
         tokenService: tokenService,
       ),
       _messageReportApiService = MessageReportApiService(
         apiClient: apiClient,
       );

  final ApiClient _apiClient;
  // token service is kept for potential auth needs in requests
  // ignore: unused_field
  final TokenService _tokenService;
  final ChatSocketService _chatSocketService;
  final MessageChatApiService _messageChatApiService;
  final MessageReportApiService _messageReportApiService;

  Future<String?> _extractUserIdFromToken() async {
    try {
      final String? token = await _tokenService.getAccessToken();
      if (token == null) return null;
      final List<String> parts = token.split('.');
      if (parts.length < 2) return null;
      final String payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalized));
      final dynamic obj = json.decode(decoded);
      if (obj is Map<String, dynamic>) return obj['sub']?.toString();
    } catch (_) {}
    return null;
  }

  Future<MessagesResponseModel> fetchMessages() async {
    try {
      final String? currentUserId = await _extractUserIdFromToken();

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

              final _ThreadPreview preview = _buildThreadPreview(
                c,
                currentUserId: currentUserId,
              );

              // Extract delivery and read status
              final dynamic msgStatus = c['lastMessageStatus'];
              final bool isDelivered = msgStatus is Map
                  ? (msgStatus['isDeliveredToMe'] as bool? ?? true)
                  : true;

              // Normalize unreadCount (server may return string/int/null)
              final int unreadCount = c['unreadCount'] is int
                  ? c['unreadCount'] as int
                  : int.tryParse(c['unreadCount']?.toString() ?? '') ?? 0;

              // If server doesn't provide an explicit highlight flag, derive it from unreadCount
              final bool isHighlighted = c['isHighlighted'] is bool
                  ? c['isHighlighted'] as bool
                  : (unreadCount > 0);

              String learnerName = 'Conversation';
              String avatarUrl = '';
              String? contactId;

              // Extract contact user from members (excluding current user)
              final dynamic members = c['members'];
              if (members is List && members.isNotEmpty) {
                dynamic contactMember;
                if (currentUserId != null && currentUserId.isNotEmpty) {
                  try {
                    contactMember = members.firstWhere((dynamic m) {
                      if (m is Map) {
                        final userId = m['userId']?.toString() ?? '';
                        return userId.isNotEmpty && userId != currentUserId;
                      }
                      return false;
                    });
                  } catch (_) {
                    contactMember = members.first;
                  }
                } else {
                  contactMember = members.first;
                }

                // Extract user details from member
                if (contactMember is Map) {
                  final dynamic user = contactMember['user'];
                  if (user is Map) {
                    learnerName =
                        user['fullName']?.toString() ??
                        user['name']?.toString() ??
                        learnerName;
                    avatarUrl = user['avatarUrl']?.toString() ?? '';
                    contactId = user['id']?.toString();
                  } else {
                    contactId = contactMember['userId']?.toString();
                  }
                }
              }

              return MessageThreadModel(
                id: c['id']?.toString() ?? '',
                learnerName: learnerName,
                lastMessage: preview.text,
                timeLabel: preview.timeLabel,
                unreadCount: unreadCount,
                isOnline: false,
                blockStatus: c['blockStatus']?.toString() ?? 'none',
                isHighlighted: isHighlighted,
                isDelivered: isDelivered,
                avatarUrl: avatarUrl,
                contactId: contactId,
                previewTone: preview.tone,
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
      dev.log(
        'Unable to fetch message conversations',
        name: 'MessagesService',
        error: err,
      );
      rethrow;
    }

    return const MessagesResponseModel(
      currentUserName: '',
      currentUserAvatarUrl: '',
      threads: <MessageThreadModel>[],
    );
  }

  _ThreadPreview _buildThreadPreview(
    Map<String, dynamic> conversation, {
    required String? currentUserId,
  }) {
    final Map<String, dynamic>? call = _mapValue(conversation['lastCall']);
    if (call != null) {
      final String type = call['callType']?.toString().toLowerCase() == 'video'
          ? 'video'
          : 'audio';
      final String status = call['status']?.toString().toLowerCase() ?? '';
      final String callerId = call['callerId']?.toString() ?? '';
      final bool isIncoming = currentUserId != null &&
          currentUserId.isNotEmpty &&
          callerId.isNotEmpty &&
          callerId != currentUserId;

      if (status == 'ringing' || status == 'active') {
        return _ThreadPreview(
          text: 'Ongoing $type call',
          timeLabel: _formatTimeLabel(call['createdAt']?.toString()),
          tone: MessageThreadPreviewTone.ongoing,
        );
      }

      if (status == 'missed' && isIncoming) {
        return _ThreadPreview(
          text: 'Missed $type call',
          timeLabel: _formatTimeLabel(call['createdAt']?.toString()),
          tone: MessageThreadPreviewTone.missed,
        );
      }

      final String text = status == 'rejected'
          ? '${_capitalized(type)} call rejected'
          : '${_capitalized(type)} call ended';
      return _ThreadPreview(
        text: text,
        timeLabel: _formatTimeLabel(call['createdAt']?.toString()),
      );
    }

    final Map<String, dynamic>? message = _mapValue(
      conversation['lastMessage'],
    );
    return _ThreadPreview(
      text: message?['content']?.toString() ?? '',
      timeLabel: _formatTimeLabel(
        message?['createdAt']?.toString() ??
            conversation['lastMessageAt']?.toString(),
      ),
    );
  }

  Map<String, dynamic>? _mapValue(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String _capitalized(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  /// Mark a conversation as read for the current user.
  /// Returns the server response map (if any), or null on failure.
  Future<Map<String, dynamic>?> markConversationRead(
    String conversationId, {
    String? lastReadMessageId,
    String? readAt,
  }) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{};
      if (lastReadMessageId != null && lastReadMessageId.isNotEmpty) {
        payload['lastReadMessageId'] = lastReadMessageId;
      }
      if (readAt != null && readAt.isNotEmpty) {
        payload['readAt'] = readAt;
      }

      final Response<dynamic> response = await _apiClient.dio.post(
        '/chat/conversations/$conversationId/read',
        data: payload.isEmpty ? null : payload,
      );

      final dynamic data = response.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (err) {
      dev.log(
        'Unable to mark conversation as read',
        name: 'MessagesService',
        error: err,
      );
      return null;
    }
  }

  Future<MessageChatModel> fetchChat(MessageThreadModel thread) {
    return _messageChatApiService.fetchChat(thread);
  }

  Future<MessageUserProfileModel> fetchUserProfile(
    String threadId, {
    bool isBlocked = false,
    String? fallbackName,
    String? fallbackAvatarUrl,
  }) async {
    // Try to fetch real user info from API first. threadId may be a user id
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/users/$threadId',
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic> || data is Map) {
        final Map<String, dynamic> rawMap = data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map);

        final Map<String, dynamic> map = rawMap['data'] is Map
            ? Map<String, dynamic>.from(rawMap['data'] as Map)
            : rawMap;

        final String name =
            map['fullName']?.toString() ??
            map['name']?.toString() ??
            fallbackName ??
            'User';
        final bool isOnline = map['isOnline'] as bool? ?? false;
        final String statusLabel = isOnline ? 'Online' : 'Offline';

        final String avatarUrl =
            map['avatarUrl']?.toString().trim().isNotEmpty == true
            ? map['avatarUrl'].toString().trim()
            : (fallbackAvatarUrl?.trim() ?? '');

        final int currentStreakDays = _intValue(
          map['currentStreakDays'] ?? map['streak'],
        );
        final int totalXp = _intValue(map['totalXp'] ?? map['xp']);
        final String streak =
            map['streakValue']?.toString().trim().isNotEmpty == true
            ? map['streakValue'].toString().trim()
            : '$currentStreakDays ${currentStreakDays == 1 ? 'Day' : 'Days'}';
        final String xp =
            map['xpValue']?.toString().trim().isNotEmpty == true
            ? map['xpValue'].toString().trim()
            : '$totalXp XP';

        return MessageUserProfileModel(
          name: name,
          statusLabel: statusLabel,
          avatarUrl: avatarUrl,
          streakValue: streak,
          xpValue: xp,
          isBlocked: isBlocked,
        );
      }
    } catch (_) {
      // ignore and fall back to mock
    }

    return MessageUserProfileModel(
      name: fallbackName ?? 'User',
      statusLabel: 'Offline',
      avatarUrl: fallbackAvatarUrl ?? '',
      streakValue: '0 Days',
      xpValue: '0 XP',
      isBlocked: isBlocked,
    );
  }

  Future<MessageReportResultModel> submitReport(
    MessageReportRequestModel request,
  ) {
    return _messageReportApiService.submitReport(request);
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

  /// Fetch active report reasons from server.
  Future<List<Map<String, dynamic>>> fetchReportReasons() {
    return _messageReportApiService.fetchReportReasons();
  }

  /// Search users by full name (paginated).
  /// Calls `/users/search/name?q=...&page=...&perPage=...` and returns a
  /// Map matching the API contract: items, total, page, perPage, totalPages.
  Future<Map<String, dynamic>> searchUsersByName({
    required String q,
    int page = 1,
    int perPage = 20,
  }) async {
    final String query = q.trim();
    if (query.isEmpty) {
      throw ArgumentError('q is required and must not be empty');
    }

    final int enforcedPerPage = perPage.clamp(1, 100).toInt();

    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/users/search/name',
        queryParameters: <String, dynamic>{
          'q': query,
          'page': page,
          'perPage': enforcedPerPage,
        },
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data);
      }

      if (data is List) {
        final List<Map<String, dynamic>> items = data
            .map<Map<String, dynamic>>(
              (dynamic u) =>
                  u is Map ? Map<String, dynamic>.from(u) : <String, dynamic>{},
            )
            .toList(growable: false);

        return <String, dynamic>{
          'items': items,
          'total': items.length,
          'page': page,
          'perPage': enforcedPerPage,
          'totalPages': 1,
        };
      }
    } catch (_) {
      // fall through to mock generation below
    }

    return <String, dynamic>{
      'items': <Map<String, dynamic>>[],
      'total': 0,
      'page': page,
      'perPage': enforcedPerPage,
      'totalPages': 0,
    };
  }

  /// Create or get a direct conversation with another user.
  /// POST /chat/direct { otherUserId }
  Future<String?> createDirectConversation({
    required String otherUserId,
  }) async {
    if (otherUserId.trim().isEmpty) {
      throw ArgumentError('otherUserId is required');
    }

    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/chat/direct',
        data: <String, dynamic>{'otherUserId': otherUserId},
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('conversationId')) {
        return data['conversationId']?.toString();
      }
    } catch (_) {
      // fall through to fallback
    }

    // Fallback: return null to indicate not created
    return null;
  }

  /// Sync messages since an ISO datetime string. Returns list of raw messages.
  /// GET /chat/sync?since=...
  Future<List<Map<String, dynamic>>> syncMessages({String? since}) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/chat/sync',
        queryParameters: <String, dynamic>{'since': since},
      );
      final dynamic data = response.data;
      if (data is List) {
        return data
            .map<Map<String, dynamic>>(
              (dynamic m) =>
                  m is Map ? Map<String, dynamic>.from(m) : <String, dynamic>{},
            )
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
  }) {
    return _messageChatApiService.fetchChatPage(
      thread,
      page: page,
      limit: limit,
    );
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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

class _ThreadPreview {
  const _ThreadPreview({
    required this.text,
    required this.timeLabel,
    this.tone = MessageThreadPreviewTone.normal,
  });

  final String text;
  final String timeLabel;
  final MessageThreadPreviewTone tone;
}
