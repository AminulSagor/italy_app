import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/features/messages/models/message_models.dart';

void main() {
  test('message thread preserves the unavailable-user state', () {
    final MessageThreadModel thread =
        MessageThreadModel.fromJson(<String, dynamic>{
          'id': 'conversation-id',
          'learnerName': 'User unavailable',
          'lastMessage': '',
          'timeLabel': '',
          'unreadCount': 0,
          'isOnline': false,
          'isHighlighted': false,
          'isDelivered': true,
          'avatarUrl': '',
          'contactId': 'deleted-user-id',
          'isUnavailable': true,
        });

    expect(thread.isUnavailable, isTrue);
    expect(thread.toJson()['isUnavailable'], isTrue);
    expect(thread.copyWith().isUnavailable, isTrue);
  });

  test('message chat preserves the unavailable-user state', () {
    const MessageChatModel chat = MessageChatModel(
      contactName: 'User unavailable',
      contactStatus: 'This account is no longer available.',
      contactAvatarUrl: '',
      isOnline: false,
      contactId: 'deleted-user-id',
      isUnavailable: true,
      messages: <MessageChatItemModel>[],
    );

    expect(chat.isUnavailable, isTrue);
    expect(chat.toJson()['isUnavailable'], isTrue);
    expect(chat.copyWith().isUnavailable, isTrue);
  });
}
