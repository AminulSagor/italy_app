import 'dart:math';

import '../models/webinar_models.dart';

class WebinarMockService {
  final Random _random = Random();

  WebinarLiveChatModel randomMessage(int index) {
    const List<WebinarLiveChatModel> messages = <WebinarLiveChatModel>[
      WebinarLiveChatModel(
        id: 'mock-luca',
        webinarId: 'mock-webinar',
        senderUserId: 'mock-luca-user',
        senderName: 'Luca',
        initials: 'LR',
        message: 'Could you repeat that sentence?',
        colorIndex: 2,
      ),
      WebinarLiveChatModel(
        id: 'mock-sara',
        webinarId: 'mock-webinar',
        senderUserId: 'mock-sara-user',
        senderName: 'Sara',
        initials: 'SB',
        message: 'This lesson is really useful!',
      ),
      WebinarLiveChatModel(
        id: 'mock-host',
        webinarId: 'mock-webinar',
        senderUserId: 'mock-host-user',
        senderName: 'Host',
        initials: 'HO',
        message: 'Great question. Let us practice together.',
        isHost: true,
        colorIndex: 1,
      ),
    ];

    return messages[(_random.nextInt(messages.length) + index) % messages.length];
  }
}
