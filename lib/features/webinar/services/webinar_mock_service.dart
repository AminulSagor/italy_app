import 'dart:math';

import '../models/webinar_models.dart';

class WebinarMockService {
  final Random _random = Random();

  Future<WebinarModel> fetchWebinar() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    return const WebinarModel(
      title: 'Mastering\nRestaurant Vocabulary',
      liveTitle: 'Italian Shikhi Live',
      hostName: 'Mario Rossi',
      learnersJoined: 152,
      watchingCount: 428,
      upcomingSessions: <WebinarSessionModel>[
        WebinarSessionModel(
          month: 'OCT',
          day: '25',
          title: 'Kitchen\nPorter Basics',
          timeLabel: 'Starts at 6:00 PM',
          levelLabel: 'Beginners',
        ),
        WebinarSessionModel(
          month: 'OCT',
          day: '27',
          title: 'Ordering\nLike a Local',
          timeLabel: 'Starts at 5:30 PM',
          levelLabel: 'Intermediate',
        ),
        WebinarSessionModel(
          month: 'OCT',
          day: '28',
          title: 'Coffee Shop\nPhrases',
          timeLabel: 'Starts at 10:00 AM',
          levelLabel: 'All levels',
        ),
      ],
      seedMessages: <WebinarLiveChatModel>[
        WebinarLiveChatModel(
          senderName: 'Arif',
          initials: 'AR',
          message: "Ciao! I'm so excited for today's session. 😍",
          colorIndex: 0,
        ),
        WebinarLiveChatModel(
          senderName: 'HOST • MARIO ROSSI',
          initials: 'MR',
          message: "Benvenuti a tutti! Let's start with common greetings.",
          isHost: true,
          colorIndex: 1,
        ),
        WebinarLiveChatModel(
          senderName: 'Giulia',
          initials: 'GL',
          message: 'Bravissimo! 👏 The library background looks amazing.',
          colorIndex: 2,
        ),
        WebinarLiveChatModel(
          senderName: 'Nasrin',
          initials: 'NS',
          message: "Can you repeat the pronunciation of 'Buongiorno'?",
          colorIndex: 0,
        ),
      ],
    );
  }

  WebinarLiveChatModel randomMessage(int index) {
    const List<WebinarLiveChatModel> messages = <WebinarLiveChatModel>[
      WebinarLiveChatModel(
        senderName: 'Luca',
        initials: 'LR',
        message: 'Could you explain the difference between vorrei and voglio?',
        colorIndex: 2,
      ),
      WebinarLiveChatModel(
        senderName: 'Sara',
        initials: 'SB',
        message: 'This restaurant lesson is really useful!',
        colorIndex: 0,
      ),
      WebinarLiveChatModel(
        senderName: 'HOST • MARIO ROSSI',
        initials: 'MR',
        message: 'Great question! Arif, try repeating the phrase after me.',
        isHost: true,
        colorIndex: 1,
      ),
      WebinarLiveChatModel(
        senderName: 'Giulia',
        initials: 'GL',
        message: 'Mi piace questa lezione! 🇮🇹',
        colorIndex: 2,
      ),
      WebinarLiveChatModel(
        senderName: 'Arif',
        initials: 'AR',
        message: 'Can we practice ordering coffee next?',
        colorIndex: 0,
      ),
    ];

    return messages[(_random.nextInt(messages.length) + index) % messages.length];
  }
}
