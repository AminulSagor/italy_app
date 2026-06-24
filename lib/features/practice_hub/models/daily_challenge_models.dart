enum DailyChallengeTaskStatus { inProgress, completed, claimed }

class DailyChallengeTaskModel {
  const DailyChallengeTaskModel({
    required this.id,
    required this.taskKey,
    required this.title,
    required this.targetValue,
    required this.progressValue,
    required this.rewardXp,
    required this.status,
  });

  final String id;
  final String taskKey;
  final String title;
  final int targetValue;
  final int progressValue;
  final int rewardXp;
  final DailyChallengeTaskStatus status;

  bool get isCompleted => status != DailyChallengeTaskStatus.inProgress;
  bool get isClaimed => status == DailyChallengeTaskStatus.claimed;
  bool get canClaim => status == DailyChallengeTaskStatus.completed;
  double get progress {
    if (targetValue <= 0) return 0;
    return (progressValue / targetValue).clamp(0, 1).toDouble();
  }

  String get unit {
    if (taskKey.contains('minute')) return ' min';
    if (taskKey.contains('xp')) return ' XP';
    return '';
  }

  factory DailyChallengeTaskModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeTaskModel(
      id: json['id']?.toString() ?? '',
      taskKey: json['taskKey']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      targetValue: _intValue(json['targetValue']),
      progressValue: _intValue(json['progressValue']),
      rewardXp: _intValue(json['rewardXp']),
      status: _statusFromValue(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'taskKey': taskKey,
      'title': title,
      'targetValue': targetValue,
      'progressValue': progressValue,
      'rewardXp': rewardXp,
      'status': switch (status) {
        DailyChallengeTaskStatus.inProgress => 'in_progress',
        DailyChallengeTaskStatus.completed => 'completed',
        DailyChallengeTaskStatus.claimed => 'claimed',
      },
    };
  }

  DailyChallengeTaskModel copyWith({
    String? id,
    String? taskKey,
    String? title,
    int? targetValue,
    int? progressValue,
    int? rewardXp,
    DailyChallengeTaskStatus? status,
  }) {
    return DailyChallengeTaskModel(
      id: id ?? this.id,
      taskKey: taskKey ?? this.taskKey,
      title: title ?? this.title,
      targetValue: targetValue ?? this.targetValue,
      progressValue: progressValue ?? this.progressValue,
      rewardXp: rewardXp ?? this.rewardXp,
      status: status ?? this.status,
    );
  }

  static DailyChallengeTaskStatus _statusFromValue(dynamic value) {
    switch (value?.toString()) {
      case 'completed':
        return DailyChallengeTaskStatus.completed;
      case 'claimed':
        return DailyChallengeTaskStatus.claimed;
      default:
        return DailyChallengeTaskStatus.inProgress;
    }
  }
}

class DailyChallengeStreakModel {
  const DailyChallengeStreakModel({
    required this.currentDays,
    required this.longestDays,
    required this.streakFreezeCount,
    this.lastActivityDate,
  });

  final int currentDays;
  final int longestDays;
  final int streakFreezeCount;
  final String? lastActivityDate;

  factory DailyChallengeStreakModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeStreakModel(
      currentDays: _intValue(json['currentDays']),
      longestDays: _intValue(json['longestDays']),
      streakFreezeCount: _intValue(json['streakFreezeCount']),
      lastActivityDate: _nullableString(json['lastActivityDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'currentDays': currentDays,
      'longestDays': longestDays,
      'streakFreezeCount': streakFreezeCount,
      'lastActivityDate': lastActivityDate,
    };
  }

  DailyChallengeStreakModel copyWith({
    int? currentDays,
    int? longestDays,
    int? streakFreezeCount,
    String? lastActivityDate,
  }) {
    return DailyChallengeStreakModel(
      currentDays: currentDays ?? this.currentDays,
      longestDays: longestDays ?? this.longestDays,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}

class DailyChallengeXpBoostModel {
  const DailyChallengeXpBoostModel({
    required this.isActive,
    required this.multiplier,
    this.remainingSeconds,
    this.expiresAt,
  });

  final bool isActive;
  final double multiplier;
  final int? remainingSeconds;
  final DateTime? expiresAt;

  factory DailyChallengeXpBoostModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeXpBoostModel(
      isActive: json['isActive'] == true,
      multiplier: _doubleValue(json['multiplier'], fallback: 1),
      remainingSeconds: _nullableInt(json['remainingSeconds']),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '')?.toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isActive': isActive,
      'multiplier': multiplier,
      'remainingSeconds': remainingSeconds,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  DailyChallengeXpBoostModel copyWith({
    bool? isActive,
    double? multiplier,
    int? remainingSeconds,
    DateTime? expiresAt,
  }) {
    return DailyChallengeXpBoostModel(
      isActive: isActive ?? this.isActive,
      multiplier: multiplier ?? this.multiplier,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class DailyChestRewardModel {
  const DailyChestRewardModel({
    required this.rewardType,
    required this.xpAmount,
    required this.boostMultiplier,
    required this.boostXp,
    required this.totalXpAwarded,
    required this.streakFreezeCount,
  });

  final String rewardType;
  final int xpAmount;
  final double boostMultiplier;
  final int boostXp;
  final int totalXpAwarded;
  final int streakFreezeCount;

  factory DailyChestRewardModel.fromJson(Map<String, dynamic> json) {
    return DailyChestRewardModel(
      rewardType: json['rewardType']?.toString() ?? '',
      xpAmount: _intValue(json['xpAmount']),
      boostMultiplier: _doubleValue(json['boostMultiplier'], fallback: 1),
      boostXp: _intValue(json['boostXp']),
      totalXpAwarded: _intValue(json['totalXpAwarded']),
      streakFreezeCount: _intValue(json['streakFreezeCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rewardType': rewardType,
      'xpAmount': xpAmount,
      'boostMultiplier': boostMultiplier,
      'boostXp': boostXp,
      'totalXpAwarded': totalXpAwarded,
      'streakFreezeCount': streakFreezeCount,
    };
  }

  DailyChestRewardModel copyWith({
    String? rewardType,
    int? xpAmount,
    double? boostMultiplier,
    int? boostXp,
    int? totalXpAwarded,
    int? streakFreezeCount,
  }) {
    return DailyChestRewardModel(
      rewardType: rewardType ?? this.rewardType,
      xpAmount: xpAmount ?? this.xpAmount,
      boostMultiplier: boostMultiplier ?? this.boostMultiplier,
      boostXp: boostXp ?? this.boostXp,
      totalXpAwarded: totalXpAwarded ?? this.totalXpAwarded,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
    );
  }
}

class DailyChestStateModel {
  const DailyChestStateModel({
    required this.isUnlocked,
    required this.isOpened,
    this.reward,
  });

  final bool isUnlocked;
  final bool isOpened;
  final DailyChestRewardModel? reward;

  factory DailyChestStateModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? rewardJson = _jsonMapOrNull(json['reward']);
    return DailyChestStateModel(
      isUnlocked: json['isUnlocked'] == true,
      isOpened: json['isOpened'] == true,
      reward: rewardJson == null
          ? null
          : DailyChestRewardModel.fromJson(rewardJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isUnlocked': isUnlocked,
      'isOpened': isOpened,
      'reward': reward?.toJson(),
    };
  }

  DailyChestStateModel copyWith({
    bool? isUnlocked,
    bool? isOpened,
    DailyChestRewardModel? reward,
    bool clearReward = false,
  }) {
    return DailyChestStateModel(
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isOpened: isOpened ?? this.isOpened,
      reward: clearReward ? null : reward ?? this.reward,
    );
  }
}

class DailyChallengeDashboardModel {
  const DailyChallengeDashboardModel({
    required this.challengeDate,
    required this.variationKey,
    required this.totalXp,
    required this.streak,
    required this.xpBoost,
    required this.tasks,
    required this.chest,
  });

  final String challengeDate;
  final String variationKey;
  final int totalXp;
  final DailyChallengeStreakModel streak;
  final DailyChallengeXpBoostModel xpBoost;
  final List<DailyChallengeTaskModel> tasks;
  final DailyChestStateModel chest;

  int get completedTaskCount =>
      tasks.where((DailyChallengeTaskModel task) => task.isCompleted).length;

  int get claimedTaskCount =>
      tasks.where((DailyChallengeTaskModel task) => task.isClaimed).length;

  String get levelLabel => 'Level ${(totalXp ~/ 100) + 1} Explorer';

  factory DailyChallengeDashboardModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeDashboardModel(
      challengeDate: json['challengeDate']?.toString() ?? '',
      variationKey: json['variationKey']?.toString() ?? '',
      totalXp: _intValue(json['totalXp']),
      streak: DailyChallengeStreakModel.fromJson(_jsonMap(json['streak'])),
      xpBoost: DailyChallengeXpBoostModel.fromJson(_jsonMap(json['xpBoost'])),
      tasks: _jsonList(json['tasks'])
          .map(DailyChallengeTaskModel.fromJson)
          .toList(growable: false),
      chest: DailyChestStateModel.fromJson(_jsonMap(json['chest'])),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'challengeDate': challengeDate,
      'variationKey': variationKey,
      'totalXp': totalXp,
      'streak': streak.toJson(),
      'xpBoost': xpBoost.toJson(),
      'tasks': tasks
          .map((DailyChallengeTaskModel task) => task.toJson())
          .toList(growable: false),
      'chest': chest.toJson(),
    };
  }

  DailyChallengeDashboardModel copyWith({
    String? challengeDate,
    String? variationKey,
    int? totalXp,
    DailyChallengeStreakModel? streak,
    DailyChallengeXpBoostModel? xpBoost,
    List<DailyChallengeTaskModel>? tasks,
    DailyChestStateModel? chest,
  }) {
    return DailyChallengeDashboardModel(
      challengeDate: challengeDate ?? this.challengeDate,
      variationKey: variationKey ?? this.variationKey,
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
      xpBoost: xpBoost ?? this.xpBoost,
      tasks: tasks ?? this.tasks,
      chest: chest ?? this.chest,
    );
  }
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _doubleValue(dynamic value, {required double fallback}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

String? _nullableString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

Map<String, dynamic>? _jsonMapOrNull(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> _jsonList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
