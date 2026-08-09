import 'dart:convert';
import 'package:italir_pothe/core/utils/app_logger.dart';

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/token_service.dart';
import '../models/message_models.dart';

class MessageChatApiService {
  MessageChatApiService({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  final ApiClient _apiClient;
  final TokenService _tokenService;

  Future<MessageChatModel> fetchChat(MessageThreadModel thread) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/chat/conversations/${thread.id}/messages',
        queryParameters: const <String, dynamic>{'page': 1, 'limit': 50},
      );
      final dynamic data = response.data;
      if (data is List) {
        final String? currentUserId = await _extractUserIdFromToken();
        final List<MessageChatItemModel> messages = data
            .whereType<Map>()
            .map(
              (Map<dynamic, dynamic> item) => _mapChatItem(
                Map<String, dynamic>.from(item),
                currentUserId: currentUserId,
              ),
            )
            .toList(growable: false);

        return MessageChatModel(
          contactName: thread.learnerName,
          contactStatus: thread.isOnline ? 'Online' : 'Offline',
          contactAvatarUrl: thread.avatarUrl,
          isOnline: thread.isOnline,
          contactId: thread.contactId,
          messages: messages,
        );
      }
    } catch (error) {
      AppLogger.log(
        'Unable to fetch chat timeline',
        name: 'MessageChatApiService',
        error: error,
      );
    }

    return MessageChatModel(
      contactName: thread.learnerName,
      contactStatus: thread.isOnline ? 'Online' : 'Offline',
      contactAvatarUrl: thread.avatarUrl,
      isOnline: thread.isOnline,
      contactId: thread.contactId,
      messages: const <MessageChatItemModel>[],
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
        final String? currentUserId = await _extractUserIdFromToken();
        return data
            .whereType<Map>()
            .map(
              (Map<dynamic, dynamic> item) => _mapChatItem(
                Map<String, dynamic>.from(item),
                currentUserId: currentUserId,
              ),
            )
            .toList(growable: false);
      }
    } catch (error) {
      AppLogger.log(
        'Unable to fetch older chat timeline items',
        name: 'MessageChatApiService',
        error: error,
      );
    }

    return <MessageChatItemModel>[];
  }

  Future<String?> _extractUserIdFromToken() async {
    try {
      final String? token = await _tokenService.getAccessToken();
      if (token == null) return null;
      final List<String> parts = token.split('.');
      if (parts.length < 2) return null;
      final String normalized = base64Url.normalize(parts[1]);
      final dynamic decoded = json.decode(
        utf8.decode(base64Url.decode(normalized)),
      );
      if (decoded is Map<String, dynamic>) {
        return decoded['sub']?.toString();
      }
    } catch (_) {}
    return null;
  }

  MessageChatItemModel _mapChatItem(
    Map<String, dynamic> json, {
    required String? currentUserId,
  }) {
    final String senderId =
        json['senderId']?.toString() ?? json['userId']?.toString() ?? '';
    final bool isMine =
        currentUserId != null &&
        currentUserId.isNotEmpty &&
        senderId == currentUserId;
    final String createdAt =
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String();
    final bool isCall =
        json['itemType']?.toString() == 'call' ||
        json['messageType']?.toString() == 'call';

    if (isCall) {
      return MessageChatItemModel(
        id:
            json['id']?.toString() ??
            'call:${json['callId']?.toString() ?? createdAt}',
        text: '',
        timeLabel: _formatTimeLabel(createdAt),
        createdAtIso: createdAt,
        statusLabel: '',
        isMine: isMine,
        itemType: MessageChatItemType.call,
        callId: json['callId']?.toString(),
        callType: json['callType']?.toString() == 'video'
            ? MessageChatCallType.video
            : MessageChatCallType.audio,
        callStatus: _parseCallStatus(json['callStatus']),
        callDurationSeconds: _intValue(json['durationSeconds']),
      );
    }

    final String id =
        json['id']?.toString() ?? json['messageId']?.toString() ?? '';
    return MessageChatItemModel(
      id: id.isNotEmpty
          ? id
          : (json['clientMessageId']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString()),
      text: json['content']?.toString() ?? '',
      timeLabel: _formatTimeLabel(createdAt),
      createdAtIso: createdAt,
      statusLabel: '',
      isMine: isMine,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  MessageChatCallStatus _parseCallStatus(dynamic value) {
    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    for (final MessageChatCallStatus status in MessageChatCallStatus.values) {
      if (status.name == normalized) return status;
    }
    return MessageChatCallStatus.failed;
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatTimeLabel(String? iso) {
    if (iso == null) return '';
    try {
      final DateTime dateTime = DateTime.parse(iso).toLocal();
      final int hour = dateTime.hour == 0
          ? 12
          : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
      final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final String minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (_) {
      return '';
    }
  }
}
