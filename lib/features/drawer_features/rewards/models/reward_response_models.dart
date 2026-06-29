import 'reward_models.dart';

class RewardDashboardModel {
  const RewardDashboardModel({
    required this.userId,
    required this.displayName,
    required this.hasUnseenReward,
    required this.unseenRewardCount,
    required this.hasPendingChest,
    required this.pendingChest,
    required this.recentRewards,
  });

  final String userId;
  final String displayName;
  final bool hasUnseenReward;
  final int unseenRewardCount;
  final bool hasPendingChest;
  final RewardChestModel? pendingChest;
  final List<RewardModel> recentRewards;

  factory RewardDashboardModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = _mapValue(json['user']);
    return RewardDashboardModel(
      userId: _stringValue(user['userId']),
      displayName: _stringValue(user['displayName']),
      hasUnseenReward: _boolValue(json['hasUnseenReward']),
      unseenRewardCount: _intValue(json['unseenRewardCount']) ?? 0,
      hasPendingChest: _boolValue(json['hasPendingChest']),
      pendingChest: _modelMap(json['pendingChest'], RewardChestModel.fromJson),
      recentRewards: _modelList(json['recentRewards'], RewardModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user': <String, dynamic>{
        'userId': userId,
        'displayName': displayName,
      },
      'hasUnseenReward': hasUnseenReward,
      'unseenRewardCount': unseenRewardCount,
      'hasPendingChest': hasPendingChest,
      'pendingChest': pendingChest?.toJson(),
      'recentRewards': recentRewards
          .map((RewardModel item) => item.toJson())
          .toList(),
    };
  }
}

class RewardHistoryResponseModel {
  const RewardHistoryResponseModel({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<RewardModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory RewardHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> meta = _mapValue(json['meta']);
    return RewardHistoryResponseModel(
      items: _modelList(json['items'], RewardModel.fromJson),
      page: _intValue(meta['page']) ?? 1,
      limit: _intValue(meta['limit']) ?? 20,
      total: _intValue(meta['total']) ?? 0,
      totalPages: _intValue(meta['totalPages']) ?? 0,
    );
  }
}

class RewardOpenResponseModel {
  const RewardOpenResponseModel({
    required this.message,
    required this.reward,
    required this.application,
  });

  final String message;
  final RewardModel reward;
  final Map<String, dynamic>? application;

  factory RewardOpenResponseModel.fromJson(Map<String, dynamic> json) {
    return RewardOpenResponseModel(
      message: _stringValue(json['message']),
      reward: RewardModel.fromJson(_mapValue(json['reward'])),
      application: json['application'] is Map
          ? Map<String, dynamic>.from(json['application'] as Map)
          : null,
    );
  }
}

class RewardDownloadModel {
  const RewardDownloadModel({
    required this.rewardId,
    required this.title,
    required this.fileUrl,
  });

  final String rewardId;
  final String title;
  final String fileUrl;

  factory RewardDownloadModel.fromJson(Map<String, dynamic> json) {
    return RewardDownloadModel(
      rewardId: _stringValue(json['rewardId']),
      title: _stringValue(json['title']),
      fileUrl: _stringValue(json['fileUrl']),
    );
  }
}

class RewardShippingAddressPayloadModel {
  const RewardShippingAddressPayloadModel({
    required this.fullName,
    required this.whatsappNumber,
    required this.addressLine,
    this.countryCode = 'IT',
  });

  final String fullName;
  final String whatsappNumber;
  final String addressLine;
  final String countryCode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName.trim(),
      'whatsappNumber': whatsappNumber.trim(),
      'addressLine': addressLine.trim(),
      'countryCode': countryCode.trim().toUpperCase(),
    };
  }
}


String _unitSuffix(String? value) {
  final String unit = value?.trim() ?? '';
  return unit.isEmpty ? '' : ' $unit';
}

String _stringValue(dynamic value, {String fallback = ''}) {
  final String normalized = value?.toString().trim() ?? '';
  return normalized.isEmpty ? fallback : normalized;
}

String? _nullableString(dynamic value) {
  final String normalized = value?.toString().trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}

int? _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _dateValue(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

Map<String, dynamic> _mapValue(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

T? _modelMap<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  final Map<String, dynamic> map = _mapValue(value);
  return map.isEmpty ? null : parser(map);
}

List<T> _modelList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) parser,
) {
  if (value is! List) return <T>[];
  return value
      .whereType<Map>()
      .map((Map item) => parser(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}
