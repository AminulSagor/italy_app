class WebinarSessionModel {
  final String month;
  final String day;
  final String title;
  final String timeLabel;
  final String levelLabel;

  const WebinarSessionModel({
    required this.month,
    required this.day,
    required this.title,
    required this.timeLabel,
    required this.levelLabel,
  });
}

class WebinarLiveChatModel {
  final String senderName;
  final String initials;
  final String message;
  final bool isHost;
  final int colorIndex;

  const WebinarLiveChatModel({
    required this.senderName,
    required this.initials,
    required this.message,
    this.isHost = false,
    this.colorIndex = 0,
  });
}

class WebinarModel {
  final String title;
  final String liveTitle;
  final String hostName;
  final int learnersJoined;
  final int watchingCount;
  final List<WebinarSessionModel> upcomingSessions;
  final List<WebinarLiveChatModel> seedMessages;

  const WebinarModel({
    required this.title,
    required this.liveTitle,
    required this.hostName,
    required this.learnersJoined,
    required this.watchingCount,
    required this.upcomingSessions,
    required this.seedMessages,
  });
}
