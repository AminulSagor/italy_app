import 'dart:convert';
import 'dart:io';

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

              // Extract last message content and timestamp
              final dynamic lastMsg = c['lastMessage'];
              final String lastMessageText = lastMsg is Map
                  ? (lastMsg['content']?.toString() ?? '')
                  : '';
              final String timeLabel = _formatTimeLabel(
                lastMsg is Map
                    ? lastMsg['createdAt']?.toString()
                    : c['lastMessageAt']?.toString(),
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
                lastMessage: lastMessageText,
                timeLabel: timeLabel,
                unreadCount: unreadCount,
                isOnline: false,
                blockStatus: c['blockStatus']?.toString() ?? 'none',
                isHighlighted: isHighlighted,
                isDelivered: isDelivered,
                avatarUrl: avatarUrl.isNotEmpty
                    ? avatarUrl
                    : 'https://i.pravatar.cc/120?img=12',
                contactId: contactId,
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
      // expose error for debugging
      try {
        // ignore: avoid_print
        print('fetchMessages error: $err');
      } catch (_) {}
      rethrow;
    }

    return const MessagesResponseModel(
      currentUserName: '',
      currentUserAvatarUrl: '',
      threads: <MessageThreadModel>[],
    );
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
      try {
        // ignore: avoid_print
        print('markConversationRead error: $err');
      } catch (_) {}
      return null;
    }
  }

  Future<MessageChatModel> fetchChat(MessageThreadModel thread) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/chat/conversations/${thread.id}/messages',
      );
      final dynamic data = response.data;
      if (data is List) {
        final String? meId = await _extractUserIdFromToken();
        final List<String> senderIds = <String>[];
        final List<MessageChatItemModel> messages = data
            .map<MessageChatItemModel>((dynamic msg) {
              final Map<String, dynamic> m = msg is Map
                  ? Map<String, dynamic>.from(msg)
                  : <String, dynamic>{};
              final String text = m['content']?.toString() ?? '';
              final String id =
                  m['id']?.toString() ?? m['messageId']?.toString() ?? '';
              final String timeLabel = _formatTimeLabel(
                m['createdAt']?.toString(),
              );
              final String senderId =
                  m['senderId']?.toString() ?? m['userId']?.toString() ?? '';
              senderIds.add(senderId);
              final bool isMine =
                  meId != null && meId.isNotEmpty && senderId == meId;
              return MessageChatItemModel(
                id: id.isNotEmpty
                    ? id
                    : (m['clientMessageId']?.toString() ??
                          DateTime.now().millisecondsSinceEpoch.toString()),
                text: text,
                timeLabel: timeLabel,
                createdAtIso: m['createdAt']?.toString(),
                statusLabel: '',
                isMine: isMine,
              );
            })
            .toList(growable: false);

        // Infer contact id: first senderId that is not the current user
        String? contactId;
        try {
          contactId = senderIds.firstWhere(
            (String s) => s.isNotEmpty && s != (meId ?? ''),
          );
        } catch (_) {
          contactId = null;
        }

        return MessageChatModel(
          contactName: thread.learnerName,
          contactStatus: thread.isOnline ? 'Online' : 'Offline',
          contactAvatarUrl: thread.avatarUrl,
          isOnline: thread.isOnline,
          contactId: contactId,
          messages: messages,
        );
      }
    } catch (err) {
      // fallback to mock
    }

    return MessageChatModel(
      contactName: thread.learnerName,
      contactStatus: thread.isOnline ? 'Online' : 'Offline',
      contactAvatarUrl: thread.avatarUrl,
      isOnline: thread.isOnline,
      messages: <MessageChatItemModel>[],
    );
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

        String avatarUrl = '';
        if (map['avatarUrl'] != null &&
            map['avatarUrl'].toString().isNotEmpty) {
          avatarUrl = map['avatarUrl'].toString();
        } else if (map['profilePhotoFileId'] != null &&
            map['profilePhotoFileId'].toString().isNotEmpty) {
          final String fileId = map['profilePhotoFileId'].toString();
          final String base = _apiClient.dio.options.baseUrl;
          avatarUrl = base.isNotEmpty
              ? '$base/files/$fileId'
              : fallbackAvatarUrl ?? 'https://i.pravatar.cc/180?img=11';
        } else {
          avatarUrl = fallbackAvatarUrl ?? 'https://i.pravatar.cc/180?img=11';
        }

        final String streak =
            map['streakValue']?.toString() ??
            map['streak']?.toString() ??
            '0 Days';
        final String xp =
            map['xpValue']?.toString() ?? map['xp']?.toString() ?? '0 XP';

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
  ) async {
    // Preferred API: POST /user-reports
    try {
      // If an evidenceFileId is already provided, send JSON body.
      final Map<String, dynamic> payload = <String, dynamic>{
        'reportedUserId': request.reportedUserId,
        'reasonId': request.reasonId,
        'description': request.description,
      };
      if (request.clientReportId != null &&
          request.clientReportId!.isNotEmpty) {
        payload['clientReportId'] = request.clientReportId;
      }

      // If evidenceFileId was provided (signed-upload done elsewhere), use it.
      if (request.evidenceFileId != null &&
          request.evidenceFileId!.isNotEmpty) {
        payload['evidenceFileId'] = request.evidenceFileId;
        final Response<dynamic> response = await _apiClient.dio.post(
          '/user-reports',
          data: payload,
        );
        final dynamic data = response.data;
        if (data is Map) {
          final Map<String, dynamic> map = data.cast<String, dynamic>();
          final dynamic d = map['data'] ?? map;
          return MessageReportResultModel(
            referenceId:
                d['ticketId']?.toString() ?? d['id']?.toString() ?? '#N/A',
            statusLabel:
                d['status']?.toString() ??
                d['statusLabel']?.toString() ??
                'Under Review',
            reviewSteps:
                (d['reviewSteps'] as List<dynamic>?)
                    ?.map((dynamic e) => e.toString())
                    .toList() ??
                <String>[
                  'Our team has been notified',
                  'Manual review is in progress',
                  'You will be notified once a decision is made',
                ],
          );
        }
      }

      // If an evidencePath is provided, attempt signed-upload flow first.
      if (request.evidencePath != null && request.evidencePath!.isNotEmpty) {
        final String path = request.evidencePath!;
        try {
          final File f = File(path);
          final int sizeBytes = await f.length();
          final String originalName = _fileNameFromPath(path);
          final String mime = _guessMimeType(path);

          // Request signed upload URL
          try {
            final Response<dynamic> signedRes = await _apiClient.dio.post(
              '/files/signed-upload-url',
              data: <String, dynamic>{
                'originalName': originalName,
                'mimeType': mime,
                'sizeBytes': sizeBytes,
                'filePurpose': 'report_evidence',
              },
            );

            final dynamic sdata = signedRes.data;
            String? signedUrl;
            String? storageKey;
            // Headers the API wants us to send to S3 on the PUT.
            // API response shape: { signedUploadUrl, storageKey, headers: { "Content-Type": ... }, ... }
            Map<String, dynamic> s3PutHeaders = <String, dynamic>{};
            if (sdata is Map &&
                (sdata['signedUploadUrl'] != null ||
                    sdata['uploadUrl'] != null)) {
              signedUrl =
                  sdata['signedUploadUrl']?.toString() ??
                  sdata['uploadUrl']?.toString();
              storageKey = sdata['storageKey']?.toString();
              if (sdata['headers'] is Map) {
                s3PutHeaders = Map<String, dynamic>.from(
                  sdata['headers'] as Map,
                );
              }
            } else if (sdata is Map && sdata['data'] is Map) {
              signedUrl =
                  sdata['data']['signedUploadUrl']?.toString() ??
                  sdata['data']['uploadUrl']?.toString();
              storageKey = sdata['data']['storageKey']?.toString();
              if (sdata['data']['headers'] is Map) {
                s3PutHeaders = Map<String, dynamic>.from(
                  sdata['data']['headers'] as Map,
                );
              }
            }
            // Ensure Content-Type is always set (fallback to guessed mime).
            if (!s3PutHeaders.containsKey('Content-Type')) {
              s3PutHeaders['Content-Type'] = mime;
            }

            if (signedUrl != null && signedUrl.isNotEmpty) {
              // Upload bytes to signed URL (no auth header)
              final Dio tmp = Dio();
              try {
                final List<int> bytes = await f.readAsBytes();
                await tmp.put(
                  signedUrl,
                  data: Stream.fromIterable(<List<int>>[bytes]),
                  options: Options(
                    headers: s3PutHeaders,
                    contentType:
                        s3PutHeaders['Content-Type']?.toString() ?? mime,
                  ),
                );

                // Confirm upload
                final Map<String, dynamic> confirmBody = <String, dynamic>{
                  'originalName': originalName,
                  'mimeType': mime,
                  'sizeBytes': sizeBytes,
                  'filePurpose': 'report_evidence',
                };
                if (storageKey != null && storageKey.isNotEmpty) {
                  confirmBody['storageKey'] = storageKey;
                }

                final Response<dynamic> confirmRes = await _apiClient.dio.post(
                  '/files/confirm-upload',
                  data: confirmBody,
                );

                final dynamic cdata = confirmRes.data;
                String? fileId;
                if (cdata is Map) {
                  // API shape: { "message": ..., "file": { "id": UUID, ... }, "publicUrl": ... }
                  if (cdata['file'] is Map && cdata['file']['id'] != null) {
                    fileId = cdata['file']['id'].toString();
                  } else if (cdata['id'] != null) {
                    // flat response fallback
                    fileId = cdata['id'].toString();
                  } else if (cdata['data'] is Map &&
                      cdata['data']['id'] != null) {
                    // data-wrapped fallback
                    fileId = cdata['data']['id'].toString();
                  } else if (cdata['data'] is Map &&
                      cdata['data']['file'] is Map &&
                      cdata['data']['file']['id'] != null) {
                    fileId = cdata['data']['file']['id'].toString();
                  }
                }

                if (fileId != null && fileId.isNotEmpty) {
                  payload['evidenceFileId'] = fileId;
                  final Response<dynamic> createRes = await _apiClient.dio.post(
                    '/user-reports',
                    data: payload,
                  );
                  final dynamic data = createRes.data;
                  if (data is Map) {
                    final Map<String, dynamic> map = data
                        .cast<String, dynamic>();
                    final dynamic d = map['data'] ?? map;
                    return MessageReportResultModel(
                      referenceId:
                          d['ticketId']?.toString() ??
                          d['id']?.toString() ??
                          '#N/A',
                      statusLabel:
                          d['status']?.toString() ??
                          d['statusLabel']?.toString() ??
                          'Under Review',
                      reviewSteps:
                          (d['reviewSteps'] as List<dynamic>?)
                              ?.map((dynamic e) => e.toString())
                              .toList() ??
                          <String>[
                            'Our team has been notified',
                            'Manual review is in progress',
                            'You will be notified once a decision is made',
                          ],
                    );
                  }
                }
              } catch (_) {
                // If signed upload or confirm fails, fall through to multipart fallback
              }
            }
          } catch (_) {
            // signed upload not available or failed; fall through to multipart
          }
        } catch (_) {
          // file read failed — continue to fallback
        }
      }

      // Fallback: direct multipart POST to /user-reports (supports evidenceImage)
      try {
        final Map<String, dynamic> formMap = <String, dynamic>{
          'reportedUserId': request.reportedUserId,
          'reasonId': request.reasonId,
          'description': request.description,
        };
        if (request.clientReportId != null &&
            request.clientReportId!.isNotEmpty) {
          formMap['clientReportId'] = request.clientReportId;
        }

        if (request.evidencePath != null && request.evidencePath!.isNotEmpty) {
          final String pth = request.evidencePath!;
          final String filename = _fileNameFromPath(pth);
          final MultipartFile mf = await MultipartFile.fromFile(
            pth,
            filename: filename,
          );
          formMap['evidenceImage'] = mf;
        }

        final FormData fd = FormData.fromMap(formMap);
        final Response<dynamic> response = await _apiClient.dio.post(
          '/user-reports',
          data: fd,
        );
        final dynamic data = response.data;
        if (data is Map) {
          final Map<String, dynamic> map = data.cast<String, dynamic>();
          final dynamic d = map['data'] ?? map;
          return MessageReportResultModel(
            referenceId:
                d['ticketId']?.toString() ?? d['id']?.toString() ?? '#N/A',
            statusLabel:
                d['status']?.toString() ??
                d['statusLabel']?.toString() ??
                'Under Review',
            reviewSteps:
                (d['reviewSteps'] as List<dynamic>?)
                    ?.map((dynamic e) => e.toString())
                    .toList() ??
                <String>[
                  'Our team has been notified',
                  'Manual review is in progress',
                  'You will be notified once a decision is made',
                ],
          );
        }
      } catch (_) {
        // fall through to old endpoint fallback
      }
    } catch (_) {
      // fall through to mock
    }

    throw Exception('Failed to submit report');
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

  /// Fetch active report reasons from server: GET /user-reports/reasons
  Future<List<Map<String, dynamic>>> fetchReportReasons() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/user-reports/reasons',
      );
      final dynamic data = response.data;
      if (data is List) {
        return data
            .map<Map<String, dynamic>>(
              (dynamic r) =>
                  r is Map ? Map<String, dynamic>.from(r) : <String, dynamic>{},
            )
            .toList(growable: false);
      }
      if (data is Map && data['data'] is List) {
        final List<dynamic> items = data['data'] as List<dynamic>;
        return items
            .map<Map<String, dynamic>>(
              (dynamic r) =>
                  r is Map ? Map<String, dynamic>.from(r) : <String, dynamic>{},
            )
            .toList(growable: false);
      }
    } catch (_) {
      // fall through to mock generation
    }

    return <Map<String, dynamic>>[];
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

    final int enforcedPerPage = perPage.clamp(1, 100);

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
  }) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/chat/conversations/${thread.id}/messages',
        queryParameters: <String, dynamic>{'page': page, 'limit': limit},
      );
      final dynamic data = response.data;
      if (data is List) {
        final String? meId = await _extractUserIdFromToken();
        final List<MessageChatItemModel> messages = data
            .map<MessageChatItemModel>((dynamic msg) {
              final Map<String, dynamic> m = msg is Map
                  ? Map<String, dynamic>.from(msg)
                  : <String, dynamic>{};
              final String text = m['content']?.toString() ?? '';
              final String id =
                  m['id']?.toString() ?? m['messageId']?.toString() ?? '';
              final String timeLabel = _formatTimeLabel(
                m['createdAt']?.toString(),
              );
              final String senderId =
                  m['senderId']?.toString() ?? m['userId']?.toString() ?? '';
              final bool isMine =
                  meId != null && meId.isNotEmpty && senderId == meId;
              return MessageChatItemModel(
                id: id.isNotEmpty
                    ? id
                    : (m['clientMessageId']?.toString() ??
                          DateTime.now().millisecondsSinceEpoch.toString()),
                text: text,
                timeLabel: timeLabel,
                createdAtIso: m['createdAt']?.toString(),
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

    return <MessageChatItemModel>[];
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

  String _fileNameFromPath(String path) {
    try {
      final String p = path.replaceAll('\\', '/');
      return p.split('/').last;
    } catch (_) {
      return path;
    }
  }

  String _guessMimeType(String path) {
    final String p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.jpg') || p.endsWith('.jpeg')) return 'image/jpeg';
    if (p.endsWith('.webp')) return 'image/webp';
    return 'application/octet-stream';
  }
}
