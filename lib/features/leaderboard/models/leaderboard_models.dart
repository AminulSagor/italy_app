class LeagueBenefitModel {
  final String type;
  final double multiplier;
  final int durationHours;
  final int durationDays;

  const LeagueBenefitModel({
    required this.type,
    required this.multiplier,
    required this.durationHours,
    required this.durationDays,
  });

  factory LeagueBenefitModel.fromJson(Map<String, dynamic> json) {
    return LeagueBenefitModel(
      type: json['type']?.toString() ?? '',
      multiplier: (json['multiplier'] is num)
          ? (json['multiplier'] as num).toDouble()
          : double.tryParse(json['multiplier']?.toString() ?? '0') ?? 0.0,
      durationHours: json['durationHours'] is int
          ? json['durationHours'] as int
          : int.tryParse(json['durationHours']?.toString() ?? '0') ?? 0,
      durationDays: json['durationDays'] is int
          ? json['durationDays'] as int
          : int.tryParse(json['durationDays']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'multiplier': multiplier,
    'durationHours': durationHours,
    'durationDays': durationDays,
  };
}

enum LeaderboardScope { myLeague, global }

extension LeaderboardScopeX on LeaderboardScope {
  String toApiString() {
    switch (this) {
      case LeaderboardScope.global:
        return 'global';
      case LeaderboardScope.myLeague:
      default:
        return 'my_league';
    }
  }

  static LeaderboardScope fromString(String? s) {
    final String v = (s ?? '').toLowerCase();
    if (v == 'global') return LeaderboardScope.global;
    return LeaderboardScope.myLeague;
  }
}

class LeaderboardQueryDto {
  final LeaderboardScope scope;
  final int page;
  final int limit;
  final String? search;

  const LeaderboardQueryDto({
    this.scope = LeaderboardScope.myLeague,
    this.page = 1,
    this.limit = 20,
    this.search,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = <String, dynamic>{
      'scope': scope.toApiString(),
      'page': page,
      'limit': limit,
    };
    if (search != null && search!.trim().isNotEmpty)
      params['search'] = search!.trim();
    return params;
  }
}

class LeagueModel {
  final String key;
  final String name;
  final int minXp;
  final int? maxXp;
  final String rangeLabel;
  final String iconKey;
  final String themeKey;
  final int sortOrder;
  final LeagueBenefitModel? benefit;

  const LeagueModel({
    required this.key,
    required this.name,
    required this.minXp,
    this.maxXp,
    required this.rangeLabel,
    required this.iconKey,
    required this.themeKey,
    required this.sortOrder,
    this.benefit,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      key: (json['key'] ?? json['slug'] ?? json['name'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      minXp: json['minXp'] is int
          ? json['minXp'] as int
          : int.tryParse(json['minXp']?.toString() ?? '0') ?? 0,
      maxXp: json['maxXp'] is int
          ? json['maxXp'] as int
          : (json['maxXp'] == null
                ? null
                : int.tryParse(json['maxXp']?.toString() ?? '0')),
      rangeLabel: json['rangeLabel']?.toString() ?? '',
      iconKey: json['iconKey']?.toString() ?? '',
      themeKey: json['themeKey']?.toString() ?? '',
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder'] as int
          : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
      benefit: json['benefit'] is Map<String, dynamic>
          ? LeagueBenefitModel.fromJson(
              Map<String, dynamic>.from(json['benefit']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'key': key,
    'name': name,
    'minXp': minXp,
    'maxXp': maxXp,
    'rangeLabel': rangeLabel,
    'iconKey': iconKey,
    'themeKey': themeKey,
    'sortOrder': sortOrder,
    'benefit': benefit?.toJson(),
  };
}

class ProfileModel {
  final String userId;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final int totalXp;
  final int streakDays;
  final LeagueModel league;
  final bool isCurrentUser;
  final bool canChat;
  final int? scopeRank;
  final int? globalRank;
  final int? leagueRank;
  final int? leagueParticipantCount;
  final int? topPercent;
  final String? zone;
  final String? zoneLabel;
  final XpBoostModel? xpBoost;
  final String? chatTargetUserId;

  const ProfileModel({
    required this.userId,
    required this.displayName,
    this.username,
    this.avatarUrl,
    required this.totalXp,
    required this.streakDays,
    required this.league,
    required this.isCurrentUser,
    required this.canChat,
    this.scopeRank,
    this.globalRank,
    this.leagueRank,
    this.leagueParticipantCount,
    this.topPercent,
    this.zone,
    this.zoneLabel,
    this.xpBoost,
    this.chatTargetUserId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      displayName:
          json['displayName']?.toString() ?? json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      totalXp: json['totalXp'] is int
          ? json['totalXp'] as int
          : int.tryParse(json['totalXp']?.toString() ?? '0') ?? 0,
      streakDays: json['streakDays'] is int
          ? json['streakDays'] as int
          : int.tryParse(json['streakDays']?.toString() ?? '0') ?? 0,
      league: json['league'] is Map<String, dynamic>
          ? LeagueModel.fromJson(Map<String, dynamic>.from(json['league']))
          : LeagueModel.fromJson(<String, dynamic>{}),
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      canChat: json['canChat'] as bool? ?? false,
      scopeRank: json['scopeRank'] is int
          ? json['scopeRank'] as int
          : int.tryParse(json['scopeRank']?.toString() ?? ''),
      globalRank: json['globalRank'] is int
          ? json['globalRank'] as int
          : int.tryParse(json['globalRank']?.toString() ?? ''),
      leagueRank: json['leagueRank'] is int
          ? json['leagueRank'] as int
          : int.tryParse(json['leagueRank']?.toString() ?? ''),
      leagueParticipantCount: json['leagueParticipantCount'] is int
          ? json['leagueParticipantCount'] as int
          : int.tryParse(json['leagueParticipantCount']?.toString() ?? ''),
      topPercent: json['topPercent'] is int
          ? json['topPercent'] as int
          : int.tryParse(json['topPercent']?.toString() ?? ''),
      zone: json['zone']?.toString(),
      zoneLabel: json['zoneLabel']?.toString(),
      xpBoost: json['xpBoost'] is Map<String, dynamic>
          ? XpBoostModel.fromJson(Map<String, dynamic>.from(json['xpBoost']))
          : null,
      chatTargetUserId:
          json['chatTargetUserId']?.toString() ??
          json['chat_target_user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'displayName': displayName,
    'username': username,
    'avatarUrl': avatarUrl,
    'totalXp': totalXp,
    'streakDays': streakDays,
    'league': league.toJson(),
    'isCurrentUser': isCurrentUser,
    'canChat': canChat,
    'scopeRank': scopeRank,
    'globalRank': globalRank,
    'leagueRank': leagueRank,
    'leagueParticipantCount': leagueParticipantCount,
    'topPercent': topPercent,
    'zone': zone,
    'zoneLabel': zoneLabel,
    'xpBoost': xpBoost?.toJson(),
    'chatTargetUserId': chatTargetUserId,
  };
}

class RankedProfileModel extends ProfileModel {
  final int rank;

  RankedProfileModel({
    required this.rank,
    required String userId,
    required String displayName,
    String? username,
    String? avatarUrl,
    required int totalXp,
    required int streakDays,
    required LeagueModel league,
    required bool isCurrentUser,
    required bool canChat,
  }) : super(
         userId: userId,
         displayName: displayName,
         username: username,
         avatarUrl: avatarUrl,
         totalXp: totalXp,
         streakDays: streakDays,
         league: league,
         isCurrentUser: isCurrentUser,
         canChat: canChat,
       );

  factory RankedProfileModel.fromJson(Map<String, dynamic> json) {
    return RankedProfileModel(
      rank: json['rank'] is int
          ? json['rank'] as int
          : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      displayName:
          json['displayName']?.toString() ?? json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      totalXp: json['totalXp'] is int
          ? json['totalXp'] as int
          : int.tryParse(json['totalXp']?.toString() ?? '0') ?? 0,
      streakDays: json['streakDays'] is int
          ? json['streakDays'] as int
          : int.tryParse(json['streakDays']?.toString() ?? '0') ?? 0,
      league: json['league'] is Map<String, dynamic>
          ? LeagueModel.fromJson(Map<String, dynamic>.from(json['league']))
          : LeagueModel.fromJson(<String, dynamic>{}),
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      canChat: json['canChat'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> p = super.toJson();
    p['rank'] = rank;
    return p;
  }
}

class XpBoostModel {
  final double multiplier;
  final String expiresAt;
  final int remainingSeconds;

  const XpBoostModel({
    required this.multiplier,
    required this.expiresAt,
    required this.remainingSeconds,
  });

  factory XpBoostModel.fromJson(Map<String, dynamic> json) {
    return XpBoostModel(
      multiplier: (json['multiplier'] is num)
          ? (json['multiplier'] as num).toDouble()
          : double.tryParse(json['multiplier']?.toString() ?? '0') ?? 0.0,
      expiresAt: json['expiresAt']?.toString() ?? '',
      remainingSeconds: json['remainingSeconds'] is int
          ? json['remainingSeconds'] as int
          : int.tryParse(json['remainingSeconds']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'multiplier': multiplier,
    'expiresAt': expiresAt,
    'remainingSeconds': remainingSeconds,
  };
}

class LeaderboardMetaModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const LeaderboardMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory LeaderboardMetaModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardMetaModel(
      page: json['page'] is int
          ? json['page'] as int
          : int.tryParse(json['page']?.toString() ?? '1') ?? 1,
      limit: json['limit'] is int
          ? json['limit'] as int
          : int.tryParse(json['limit']?.toString() ?? '20') ?? 20,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      totalPages: json['totalPages'] is int
          ? json['totalPages'] as int
          : int.tryParse(json['totalPages']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'page': page,
    'limit': limit,
    'total': total,
    'totalPages': totalPages,
  };
}

class LeaderboardResponseModel {
  final String scope;
  final ProfileModel? currentUser;
  final List<RankedProfileModel> podium;
  final Map<String, dynamic>? milestone;
  final List<RankedProfileModel> entries;
  final LeaderboardMetaModel? meta;

  const LeaderboardResponseModel({
    required this.scope,
    this.currentUser,
    required this.podium,
    this.milestone,
    required this.entries,
    this.meta,
  });

  factory LeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic podiumRaw = json['podium'] ?? json['top'] ?? <dynamic>[];
    final List<RankedProfileModel> podiumList = (podiumRaw is List)
        ? podiumRaw
              .map<RankedProfileModel>(
                (dynamic e) =>
                    RankedProfileModel.fromJson(e as Map<String, dynamic>),
              )
              .toList()
        : <RankedProfileModel>[];

    final dynamic entriesRaw = json['entries'] ?? json['data'] ?? <dynamic>[];
    final List<RankedProfileModel> entriesList = (entriesRaw is List)
        ? entriesRaw
              .map<RankedProfileModel>(
                (dynamic e) =>
                    RankedProfileModel.fromJson(e as Map<String, dynamic>),
              )
              .toList()
        : <RankedProfileModel>[];

    return LeaderboardResponseModel(
      scope: json['scope']?.toString() ?? 'my_league',
      currentUser: json['currentUser'] is Map<String, dynamic>
          ? ProfileModel.fromJson(
              Map<String, dynamic>.from(json['currentUser']),
            )
          : null,
      podium: podiumList,
      milestone: json['milestone'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['milestone'] as Map)
          : null,
      entries: entriesList,
      meta: json['meta'] is Map<String, dynamic>
          ? LeaderboardMetaModel.fromJson(
              Map<String, dynamic>.from(json['meta']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'scope': scope,
    'currentUser': currentUser?.toJson(),
    'podium': podium.map((e) => e.toJson()).toList(),
    'milestone': milestone,
    'entries': entries.map((e) => e.toJson()).toList(),
    'meta': meta?.toJson(),
  };
}
