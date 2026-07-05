import 'dart:math';

import '../models/webinar_models.dart';
import 'package:get/get.dart';

class WebinarMockService {
  final Random _random = Random();

  WebinarLiveChatModel randomMessage(int index) {
    List<WebinarLiveChatModel> messages = <WebinarLiveChatModel>[
      WebinarLiveChatModel(
        id: 'mock-luca',
        webinarId: 'mock-webinar',
        senderUserId: 'mock-luca-user',
        senderName: 'Luca',
        initials: 'LR',
        message: 'could_you_repeat_that_sentence'.tr,
        colorIndex: 2,
      ),
      WebinarLiveChatModel(
        id: 'mock-sara',
        webinarId: 'mock-webinar',
        senderUserId: 'mock-sara-user',
        senderName: 'Sara',
        initials: 'SB',
        message: 'this_lesson_is_really_useful'.tr,
      ),
      WebinarLiveChatModel(
        id: 'mock-host',
        webinarId: 'mock-webinar',
        senderUserId: 'mock-host-user',
        senderName: 'Host',
        initials: 'HO',
        message: 'great_question_let_us_practice_together'.tr,
        isHost: true,
        colorIndex: 1,
      ),
    ];

    return messages[(_random.nextInt(messages.length) + index) % messages.length];
  }
}
