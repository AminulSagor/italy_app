import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/webinar_models.dart';

class WebinarSocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String webinarId,
    required void Function() onWebinarEnded,
    required void Function(WebinarParticipantModel participant)
        onParticipantUpdated,
    required void Function(WebinarParticipantModel participant)
        onSpeakerApproved,
    required void Function(WebinarParticipantModel participant)
        onSpeakerRejected,
    required void Function(WebinarLiveChatModel chatMessage)
        onChatMessageCreated,
  }) {
    disconnect();

    _socket = io.io(
      _socketUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      _socket?.emit('join_webinar_room', <String, dynamic>{
        'webinarId': webinarId,
      });
    });

    _socket?.on('webinar_ended', (_) => onWebinarEnded());
    _socket?.on('participants_list_updated', (dynamic data) {
      final WebinarParticipantModel? participant = _participantFromEvent(data);
      if (participant != null) onParticipantUpdated(participant);
    });
    _socket?.on('speaker_request_approved', (dynamic data) {
      final WebinarParticipantModel? participant = _participantFromEvent(data);
      if (participant != null) onSpeakerApproved(participant);
    });
    _socket?.on('speaker_request_rejected', (dynamic data) {
      final WebinarParticipantModel? participant = _participantFromEvent(data);
      if (participant != null) onSpeakerRejected(participant);
    });

    _socket?.on('webinar_chat_message_created', (dynamic data) {
      final WebinarLiveChatModel? chatMessage = _chatMessageFromEvent(data);
      if (chatMessage != null) onChatMessageCreated(chatMessage);
    });

    _socket?.connect();
  }

  void leaveRoom(String webinarId) {
    _socket?.emit('leave_webinar_room', <String, dynamic>{
      'webinarId': webinarId,
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  WebinarLiveChatModel? _chatMessageFromEvent(dynamic data) {
    if (data is! Map) return null;
    final dynamic rawChatMessage = data['chatMessage'];
    if (rawChatMessage is! Map) return null;
    return WebinarLiveChatModel.fromJson(
      Map<String, dynamic>.from(rawChatMessage),
    );
  }

  WebinarParticipantModel? _participantFromEvent(dynamic data) {
    if (data is! Map) return null;
    final dynamic rawParticipant = data['participant'];
    if (rawParticipant is! Map) return null;
    return WebinarParticipantModel.fromJson(
      Map<String, dynamic>.from(rawParticipant),
    );
  }

  String get _socketUrl {
    final String apiBaseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
    final Uri uri = Uri.parse(apiBaseUrl);
    return uri.replace(path: '/webinars').toString();
  }
}
