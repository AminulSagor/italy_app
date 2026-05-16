enum HomeToolTone { blue, orange }

enum HomeActivityTone { muted, soft, primary, lime }

class HomeDashboardModel {
  final HomeUserModel user;
  final HomeOverviewModel overview;
  final HomeChapterModel currentChapter;
  final List<HomeToolModel> quickTools;
  final List<HomeWorkItemModel> workItems;
  final HomeSupportModel support;
  final HomeWebinarModel webinar;
  final HomeInfoCardModel culturalTip;
  final HomeInfoCardModel streak;
  final HomeInfoCardModel aiTutor;
  final HomeDailyChallengesModel dailyChallenges;

  const HomeDashboardModel({
    required this.user,
    required this.overview,
    required this.currentChapter,
    required this.quickTools,
    required this.workItems,
    required this.support,
    required this.webinar,
    required this.culturalTip,
    required this.streak,
    required this.aiTutor,
    required this.dailyChallenges,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      user: HomeUserModel.fromJson(json['user'] as Map<String, dynamic>),
      overview: HomeOverviewModel.fromJson(
        json['overview'] as Map<String, dynamic>,
      ),
      currentChapter: HomeChapterModel.fromJson(
        json['currentChapter'] as Map<String, dynamic>,
      ),
      quickTools: (json['quickTools'] as List<dynamic>)
          .map((dynamic item) => HomeToolModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      workItems: (json['workItems'] as List<dynamic>)
          .map((dynamic item) => HomeWorkItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      support: HomeSupportModel.fromJson(json['support'] as Map<String, dynamic>),
      webinar: HomeWebinarModel.fromJson(json['webinar'] as Map<String, dynamic>),
      culturalTip: HomeInfoCardModel.fromJson(
        json['culturalTip'] as Map<String, dynamic>,
      ),
      streak: HomeInfoCardModel.fromJson(json['streak'] as Map<String, dynamic>),
      aiTutor: HomeInfoCardModel.fromJson(json['aiTutor'] as Map<String, dynamic>),
      dailyChallenges: HomeDailyChallengesModel.fromJson(
        json['dailyChallenges'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user': user.toJson(),
      'overview': overview.toJson(),
      'currentChapter': currentChapter.toJson(),
      'quickTools': quickTools.map((HomeToolModel item) => item.toJson()).toList(),
      'workItems': workItems.map((HomeWorkItemModel item) => item.toJson()).toList(),
      'support': support.toJson(),
      'webinar': webinar.toJson(),
      'culturalTip': culturalTip.toJson(),
      'streak': streak.toJson(),
      'aiTutor': aiTutor.toJson(),
      'dailyChallenges': dailyChallenges.toJson(),
    };
  }

  HomeDashboardModel copyWith({
    HomeUserModel? user,
    HomeOverviewModel? overview,
    HomeChapterModel? currentChapter,
    List<HomeToolModel>? quickTools,
    List<HomeWorkItemModel>? workItems,
    HomeSupportModel? support,
    HomeWebinarModel? webinar,
    HomeInfoCardModel? culturalTip,
    HomeInfoCardModel? streak,
    HomeInfoCardModel? aiTutor,
    HomeDailyChallengesModel? dailyChallenges,
  }) {
    return HomeDashboardModel(
      user: user ?? this.user,
      overview: overview ?? this.overview,
      currentChapter: currentChapter ?? this.currentChapter,
      quickTools: quickTools ?? this.quickTools,
      workItems: workItems ?? this.workItems,
      support: support ?? this.support,
      webinar: webinar ?? this.webinar,
      culturalTip: culturalTip ?? this.culturalTip,
      streak: streak ?? this.streak,
      aiTutor: aiTutor ?? this.aiTutor,
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
    );
  }
}

class HomeUserModel {
  final String greeting;
  final String displayName;
  final String streakLabel;
  final int notificationCount;
  final int messageCount;

  const HomeUserModel({
    required this.greeting,
    required this.displayName,
    required this.streakLabel,
    required this.notificationCount,
    required this.messageCount,
  });

  factory HomeUserModel.fromJson(Map<String, dynamic> json) {
    return HomeUserModel(
      greeting: json['greeting'] as String,
      displayName: json['displayName'] as String,
      streakLabel: json['streakLabel'] as String,
      notificationCount: json['notificationCount'] as int,
      messageCount: json['messageCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'greeting': greeting,
      'displayName': displayName,
      'streakLabel': streakLabel,
      'notificationCount': notificationCount,
      'messageCount': messageCount,
    };
  }

  HomeUserModel copyWith({
    String? greeting,
    String? displayName,
    String? streakLabel,
    int? notificationCount,
    int? messageCount,
  }) {
    return HomeUserModel(
      greeting: greeting ?? this.greeting,
      displayName: displayName ?? this.displayName,
      streakLabel: streakLabel ?? this.streakLabel,
      notificationCount: notificationCount ?? this.notificationCount,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}

class HomeOverviewModel {
  final String title;
  final String subtitle;
  final String totalTime;
  final String totalTimeLabel;
  final List<HomeActivityModel> activities;

  const HomeOverviewModel({
    required this.title,
    required this.subtitle,
    required this.totalTime,
    required this.totalTimeLabel,
    required this.activities,
  });

  factory HomeOverviewModel.fromJson(Map<String, dynamic> json) {
    return HomeOverviewModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      totalTime: json['totalTime'] as String,
      totalTimeLabel: json['totalTimeLabel'] as String,
      activities: (json['activities'] as List<dynamic>)
          .map((dynamic item) => HomeActivityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'totalTime': totalTime,
      'totalTimeLabel': totalTimeLabel,
      'activities': activities.map((HomeActivityModel item) => item.toJson()).toList(),
    };
  }

  HomeOverviewModel copyWith({
    String? title,
    String? subtitle,
    String? totalTime,
    String? totalTimeLabel,
    List<HomeActivityModel>? activities,
  }) {
    return HomeOverviewModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      totalTime: totalTime ?? this.totalTime,
      totalTimeLabel: totalTimeLabel ?? this.totalTimeLabel,
      activities: activities ?? this.activities,
    );
  }
}

class HomeActivityModel {
  final String dayLabel;
  final double trackHeight;
  final double valueHeight;
  final bool isSelected;
  final HomeActivityTone tone;

  const HomeActivityModel({
    required this.dayLabel,
    required this.trackHeight,
    required this.valueHeight,
    required this.isSelected,
    required this.tone,
  });

  factory HomeActivityModel.fromJson(Map<String, dynamic> json) {
    return HomeActivityModel(
      dayLabel: json['dayLabel'] as String,
      trackHeight: (json['trackHeight'] as num).toDouble(),
      valueHeight: (json['valueHeight'] as num).toDouble(),
      isSelected: json['isSelected'] as bool,
      tone: HomeActivityTone.values.firstWhere(
        (HomeActivityTone tone) => tone.name == json['tone'],
        orElse: () => HomeActivityTone.soft,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dayLabel': dayLabel,
      'trackHeight': trackHeight,
      'valueHeight': valueHeight,
      'isSelected': isSelected,
      'tone': tone.name,
    };
  }

  HomeActivityModel copyWith({
    String? dayLabel,
    double? trackHeight,
    double? valueHeight,
    bool? isSelected,
    HomeActivityTone? tone,
  }) {
    return HomeActivityModel(
      dayLabel: dayLabel ?? this.dayLabel,
      trackHeight: trackHeight ?? this.trackHeight,
      valueHeight: valueHeight ?? this.valueHeight,
      isSelected: isSelected ?? this.isSelected,
      tone: tone ?? this.tone,
    );
  }
}

class HomeChapterModel {
  final String eyebrow;
  final String title;
  final String progressLabel;
  final double progress;
  final String buttonLabel;

  const HomeChapterModel({
    required this.eyebrow,
    required this.title,
    required this.progressLabel,
    required this.progress,
    required this.buttonLabel,
  });

  factory HomeChapterModel.fromJson(Map<String, dynamic> json) {
    return HomeChapterModel(
      eyebrow: json['eyebrow'] as String,
      title: json['title'] as String,
      progressLabel: json['progressLabel'] as String,
      progress: (json['progress'] as num).toDouble(),
      buttonLabel: json['buttonLabel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'eyebrow': eyebrow,
      'title': title,
      'progressLabel': progressLabel,
      'progress': progress,
      'buttonLabel': buttonLabel,
    };
  }

  HomeChapterModel copyWith({
    String? eyebrow,
    String? title,
    String? progressLabel,
    double? progress,
    String? buttonLabel,
  }) {
    return HomeChapterModel(
      eyebrow: eyebrow ?? this.eyebrow,
      title: title ?? this.title,
      progressLabel: progressLabel ?? this.progressLabel,
      progress: progress ?? this.progress,
      buttonLabel: buttonLabel ?? this.buttonLabel,
    );
  }
}

class HomeToolModel {
  final String title;
  final String subtitle;
  final String iconKey;
  final HomeToolTone tone;

  const HomeToolModel({
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.tone,
  });

  factory HomeToolModel.fromJson(Map<String, dynamic> json) {
    return HomeToolModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconKey: json['iconKey'] as String,
      tone: HomeToolTone.values.firstWhere(
        (HomeToolTone tone) => tone.name == json['tone'],
        orElse: () => HomeToolTone.blue,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'iconKey': iconKey,
      'tone': tone.name,
    };
  }

  HomeToolModel copyWith({
    String? title,
    String? subtitle,
    String? iconKey,
    HomeToolTone? tone,
  }) {
    return HomeToolModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconKey: iconKey ?? this.iconKey,
      tone: tone ?? this.tone,
    );
  }
}

class HomeWorkItemModel {
  final String title;
  final String emoji;

  const HomeWorkItemModel({required this.title, required this.emoji});

  factory HomeWorkItemModel.fromJson(Map<String, dynamic> json) {
    return HomeWorkItemModel(
      title: json['title'] as String,
      emoji: json['emoji'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'title': title, 'emoji': emoji};
  }

  HomeWorkItemModel copyWith({String? title, String? emoji}) {
    return HomeWorkItemModel(
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
    );
  }
}

class HomeSupportModel {
  final String title;
  final String subtitle;

  const HomeSupportModel({required this.title, required this.subtitle});

  factory HomeSupportModel.fromJson(Map<String, dynamic> json) {
    return HomeSupportModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'title': title, 'subtitle': subtitle};
  }

  HomeSupportModel copyWith({String? title, String? subtitle}) {
    return HomeSupportModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}

class HomeWebinarModel {
  final String badgeLabel;
  final String title;
  final String hostName;
  final String timeLabel;
  final String buttonLabel;

  const HomeWebinarModel({
    required this.badgeLabel,
    required this.title,
    required this.hostName,
    required this.timeLabel,
    required this.buttonLabel,
  });

  factory HomeWebinarModel.fromJson(Map<String, dynamic> json) {
    return HomeWebinarModel(
      badgeLabel: json['badgeLabel'] as String,
      title: json['title'] as String,
      hostName: json['hostName'] as String,
      timeLabel: json['timeLabel'] as String,
      buttonLabel: json['buttonLabel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'badgeLabel': badgeLabel,
      'title': title,
      'hostName': hostName,
      'timeLabel': timeLabel,
      'buttonLabel': buttonLabel,
    };
  }

  HomeWebinarModel copyWith({
    String? badgeLabel,
    String? title,
    String? hostName,
    String? timeLabel,
    String? buttonLabel,
  }) {
    return HomeWebinarModel(
      badgeLabel: badgeLabel ?? this.badgeLabel,
      title: title ?? this.title,
      hostName: hostName ?? this.hostName,
      timeLabel: timeLabel ?? this.timeLabel,
      buttonLabel: buttonLabel ?? this.buttonLabel,
    );
  }
}

class HomeInfoCardModel {
  final String eyebrow;
  final String title;
  final String body;
  final String actionLabel;

  const HomeInfoCardModel({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.actionLabel,
  });

  factory HomeInfoCardModel.fromJson(Map<String, dynamic> json) {
    return HomeInfoCardModel(
      eyebrow: json['eyebrow'] as String? ?? '',
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'eyebrow': eyebrow,
      'title': title,
      'body': body,
      'actionLabel': actionLabel,
    };
  }

  HomeInfoCardModel copyWith({
    String? eyebrow,
    String? title,
    String? body,
    String? actionLabel,
  }) {
    return HomeInfoCardModel(
      eyebrow: eyebrow ?? this.eyebrow,
      title: title ?? this.title,
      body: body ?? this.body,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }
}

class HomeDailyChallengesModel {
  final String label;
  final int completed;
  final int total;

  const HomeDailyChallengesModel({
    required this.label,
    required this.completed,
    required this.total,
  });

  double get progress => total == 0 ? 0 : completed / total;

  String get valueLabel => '$completed / $total';

  factory HomeDailyChallengesModel.fromJson(Map<String, dynamic> json) {
    return HomeDailyChallengesModel(
      label: json['label'] as String,
      completed: json['completed'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'completed': completed,
      'total': total,
    };
  }

  HomeDailyChallengesModel copyWith({String? label, int? completed, int? total}) {
    return HomeDailyChallengesModel(
      label: label ?? this.label,
      completed: completed ?? this.completed,
      total: total ?? this.total,
    );
  }
}
