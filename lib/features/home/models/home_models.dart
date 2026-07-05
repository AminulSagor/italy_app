import 'package:get/get.dart';

class HomeDashboardModel {
  const HomeDashboardModel({
    required this.overview,
    required this.quickTools,
    required this.workItems,
    required this.support,
    required this.culturalTip,
    required this.streak,
    required this.aiTutor,
    required this.dailyChallenges,
    this.currentChapter,
    this.webinar,
  });

  final HomeOverviewModel overview;
  final HomeChapterModel? currentChapter;
  final List<HomeToolModel> quickTools;
  final List<HomeWorkItemModel> workItems;
  final HomeSupportModel support;
  final HomeWebinarModel? webinar;
  final HomeInfoCardModel culturalTip;
  final HomeInfoCardModel streak;
  final HomeInfoCardModel aiTutor;
  final HomeDailyChallengesModel dailyChallenges;

  HomeDashboardModel copyWith({
    HomeOverviewModel? overview,
    HomeChapterModel? currentChapter,
    bool clearCurrentChapter = false,
    List<HomeToolModel>? quickTools,
    List<HomeWorkItemModel>? workItems,
    HomeSupportModel? support,
    HomeWebinarModel? webinar,
    bool clearWebinar = false,
    HomeInfoCardModel? culturalTip,
    HomeInfoCardModel? streak,
    HomeInfoCardModel? aiTutor,
    HomeDailyChallengesModel? dailyChallenges,
  }) {
    return HomeDashboardModel(
      overview: overview ?? this.overview,
      currentChapter: clearCurrentChapter
          ? null
          : currentChapter ?? this.currentChapter,
      quickTools: quickTools ?? this.quickTools,
      workItems: workItems ?? this.workItems,
      support: support ?? this.support,
      webinar: clearWebinar ? null : webinar ?? this.webinar,
      culturalTip: culturalTip ?? this.culturalTip,
      streak: streak ?? this.streak,
      aiTutor: aiTutor ?? this.aiTutor,
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
    );
  }

  static HomeDashboardModel get initial => HomeDashboardModel(
    overview: HomeOverviewModel(totalSeconds: 0, days: <HomeActivityModel>[]),
    currentChapter: null,
    quickTools: <HomeToolModel>[
      HomeToolModel(
        title: 'cv_services'.tr,
        subtitle: 'create_a_professional_italian_cv'.tr,
        iconKey: 'document',
      ),
    ],
    workItems: <HomeWorkItemModel>[],
    support: HomeSupportModel(
      title: 'gen_need_help'.tr,
      subtitle: 'join_our_facebook_community'.tr,
    ),
    webinar: null,
    culturalTip: HomeInfoCardModel(
      eyebrow: 'gen_cultural_tip_of_the_day'.tr,
      title: 'a_little_italian_goes_a_long_way'.tr,
      body: 'practice_a_few_useful_phrases_every_day_to_build_confidence'.tr,
      actionLabel: '',
    ),
    streak: HomeInfoCardModel(
      eyebrow: 'day_streak'.tr,
      title: '0 ${'gen_days'.tr}',
      body: 'start_learning_today'.tr,
      actionLabel: '',
    ),
    aiTutor: HomeInfoCardModel(
      eyebrow: 'ai_tutor_1'.tr,
      title: 'practice_italian_anytime'.tr,
      body: 'chat_or_speak_with_your_ai_tutor_and_get_instant_support'.tr,
      actionLabel: 'start_chatting'.tr,
    ),
    dailyChallenges: HomeDailyChallengesModel(
      label: 'gen_daily_challenges_1'.tr,
      completed: 0,
      total: 0,
    ),
  );
}

class HomeOverviewModel {
  const HomeOverviewModel({required this.totalSeconds, required this.days});

  final int totalSeconds;
  final List<HomeActivityModel> days;

  String get totalTimeLabel {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    if (minutes > 0) return '${minutes}m';
    return '${totalSeconds}s';
  }
}

class HomeActivityModel {
  const HomeActivityModel({
    required this.date,
    required this.dayLabel,
    required this.durationSeconds,
    required this.isToday,
  });

  final String date;
  final String dayLabel;
  final int durationSeconds;
  final bool isToday;

  String get durationLabel {
    if (durationSeconds <= 0) return '0s';
    final int hours = durationSeconds ~/ 3600;
    final int minutes = (durationSeconds % 3600) ~/ 60;
    if (hours > 0) return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    if (minutes > 0) return '${minutes}m';
    return '${durationSeconds}s';
  }
}

class HomeChapterModel {
  const HomeChapterModel({
    required this.lessonId,
    required this.courseId,
    required this.chapterId,
    required this.courseTitle,
    required this.chapterTitle,
    required this.lessonTitle,
    required this.subtitle,
    required this.progress,
  });

  final String lessonId;
  final String courseId;
  final String chapterId;
  final String courseTitle;
  final String chapterTitle;
  final String lessonTitle;
  final String subtitle;
  final double progress;

  String get progressLabel => '${(progress * 100).round()}%';

  factory HomeChapterModel.fromJson(Map<String, dynamic> json) {
    final double percent = _doubleValue(json['progressPercent']);
    return HomeChapterModel(
      lessonId: _stringValue(json['lessonId']),
      courseId: _stringValue(json['courseId']),
      chapterId: _stringValue(json['chapterId']),
      courseTitle: _stringValue(json['courseTitle']),
      chapterTitle: _stringValue(json['chapterTitle']),
      lessonTitle: _stringValue(json['lessonTitle']),
      subtitle: _stringValue(json['subtitle']),
      progress: (percent / 100).clamp(0, 1).toDouble(),
    );
  }
}

class HomeToolModel {
  const HomeToolModel({
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });

  final String title;
  final String subtitle;
  final String iconKey;
}

class HomeWorkItemModel {
  const HomeWorkItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.cardColor,
    required this.moduleCount,
    required this.sentenceCount,
    required this.learnedSentenceCount,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final String cardColor;
  final int moduleCount;
  final int sentenceCount;
  final int learnedSentenceCount;

  factory HomeWorkItemModel.fromJson(Map<String, dynamic> json) {
    return HomeWorkItemModel(
      id: _stringValue(json['id']),
      title: _stringValue(json['title']),
      subtitle: _stringValue(json['subtitleBn']),
      iconKey: _stringValue(json['iconKey']),
      cardColor: _stringValue(json['cardColor']),
      moduleCount: _intValue(json['moduleCount']),
      sentenceCount: _intValue(json['sentenceCount']),
      learnedSentenceCount: _intValue(json['learnedSentenceCount']),
    );
  }
}

class HomeSupportModel {
  const HomeSupportModel({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

class HomeWebinarModel {
  const HomeWebinarModel({
    required this.id,
    required this.title,
    required this.hostName,
    required this.timeLabel,
  });

  final String id;
  final String title;
  final String hostName;
  final String timeLabel;

  factory HomeWebinarModel.fromJson(Map<String, dynamic> json) {
    final DateTime? date = DateTime.tryParse(
      _stringValue(json['dateTime']),
    )?.toLocal();
    return HomeWebinarModel(
      id: _stringValue(json['id']),
      title: _stringValue(json['title']),
      hostName: _stringValue(json['hostTeacherName']),
      timeLabel: date == null ? '' : _formatDateTime(date),
    );
  }
}

class HomeInfoCardModel {
  const HomeInfoCardModel({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.actionLabel,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String actionLabel;
}

class HomeDailyChallengesModel {
  const HomeDailyChallengesModel({
    required this.label,
    required this.completed,
    required this.total,
  });

  final String label;
  final int completed;
  final int total;

  double get progress =>
      total == 0 ? 0 : (completed / total).clamp(0, 1).toDouble();
  String get valueLabel => '$completed / $total';
}

String _stringValue(dynamic value) => value?.toString().trim() ?? '';

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _formatDateTime(DateTime value) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final int hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final String minute = value.minute.toString().padLeft(2, '0');
  final String period = value.hour >= 12 ? 'PM' : 'AM';
  return '${months[value.month - 1]} ${value.day}, $hour:$minute $period';
}
