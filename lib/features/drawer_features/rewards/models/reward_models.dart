enum RewardType {
  physicalGift('physical_gift'),
  physicalPrize('physical_prize'),
  streakFreeze('streak_freeze'),
  cvCredits('cv_credits'),
  aiPackage('ai_package'),
  xp('xp'),
  courseAccess('course_access'),
  downloadableFile('downloadable_file'),
  certificate('certificate'),
  badge('badge'),
  unknown('unknown');

  const RewardType(this.apiValue);

  final String apiValue;

  bool get isPhysical =>
      this == RewardType.physicalGift || this == RewardType.physicalPrize;

  static RewardType fromApi(dynamic value) {
    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    return RewardType.values.firstWhere(
      (RewardType item) => item.apiValue == normalized,
      orElse: () => RewardType.unknown,
    );
  }
}

enum RewardActionType {
  openChest('open_chest'),
  shippingAddress('shipping_address'),
  trackDelivery('track_delivery'),
  startCourse('start_course'),
  downloadFile('download_file'),
  viewCertificate('view_certificate'),
  unknown('unknown');

  const RewardActionType(this.apiValue);

  final String apiValue;

  static RewardActionType fromApi(dynamic value) {
    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    return RewardActionType.values.firstWhere(
      (RewardActionType item) => item.apiValue == normalized,
      orElse: () => RewardActionType.unknown,
    );
  }
}

class RewardActionModel {
  const RewardActionModel({
    required this.type,
    required this.label,
    required this.resourceId,
    required this.fileUrl,
  });

  final RewardActionType type;
  final String label;
  final String? resourceId;
  final String? fileUrl;

  factory RewardActionModel.fromJson(Map<String, dynamic> json) {
    return RewardActionModel(
      type: RewardActionType.fromApi(json['type']),
      label: _stringValue(json['label']),
      resourceId: _nullableString(json['resourceId']),
      fileUrl: _nullableString(json['fileUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.apiValue,
      'label': label,
      'resourceId': resourceId,
      'fileUrl': fileUrl,
    };
  }

  RewardActionModel copyWith({
    RewardActionType? type,
    String? label,
    String? resourceId,
    String? fileUrl,
  }) {
    return RewardActionModel(
      type: type ?? this.type,
      label: label ?? this.label,
      resourceId: resourceId ?? this.resourceId,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}

class RewardChestModel {
  const RewardChestModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rewardType,
    required this.imageUrl,
    required this.congratulatoryNote,
    required this.headline,
    required this.playConfettiAnimation,
    required this.requestShippingAddress,
    required this.action,
    required this.awardedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final RewardType rewardType;
  final String? imageUrl;
  final String congratulatoryNote;
  final String headline;
  final bool playConfettiAnimation;
  final bool requestShippingAddress;
  final RewardActionModel? action;
  final DateTime? awardedAt;

  factory RewardChestModel.fromJson(Map<String, dynamic> json) {
    return RewardChestModel(
      id: _stringValue(json['id']),
      title: _stringValue(json['title']),
      subtitle: _stringValue(json['subtitle']),
      rewardType: RewardType.fromApi(json['rewardType']),
      imageUrl: _nullableString(json['imageUrl']),
      congratulatoryNote: _stringValue(json['congratulatoryNote']),
      headline: _stringValue(json['headline']),
      playConfettiAnimation: _boolValue(json['playConfettiAnimation']),
      requestShippingAddress: _boolValue(json['requestShippingAddress']),
      action: _modelMap(json['action'], RewardActionModel.fromJson),
      awardedAt: _dateValue(json['awardedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'rewardType': rewardType.apiValue,
      'imageUrl': imageUrl,
      'congratulatoryNote': congratulatoryNote,
      'headline': headline,
      'playConfettiAnimation': playConfettiAnimation,
      'requestShippingAddress': requestShippingAddress,
      'action': action?.toJson(),
      'awardedAt': awardedAt?.toIso8601String(),
    };
  }

  RewardChestModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    RewardType? rewardType,
    String? imageUrl,
    String? congratulatoryNote,
    String? headline,
    bool? playConfettiAnimation,
    bool? requestShippingAddress,
    RewardActionModel? action,
    DateTime? awardedAt,
  }) {
    return RewardChestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      rewardType: rewardType ?? this.rewardType,
      imageUrl: imageUrl ?? this.imageUrl,
      congratulatoryNote: congratulatoryNote ?? this.congratulatoryNote,
      headline: headline ?? this.headline,
      playConfettiAnimation:
          playConfettiAnimation ?? this.playConfettiAnimation,
      requestShippingAddress:
          requestShippingAddress ?? this.requestShippingAddress,
      action: action ?? this.action,
      awardedAt: awardedAt ?? this.awardedAt,
    );
  }
}

class RewardShippingAddressModel {
  const RewardShippingAddressModel({
    required this.fullName,
    required this.whatsappNumber,
    required this.addressLine,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.isLocked,
    required this.updatedAt,
  });

  final String fullName;
  final String whatsappNumber;
  final String addressLine;
  final String countryCode;
  final double? latitude;
  final double? longitude;
  final bool isLocked;
  final DateTime? updatedAt;

  factory RewardShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return RewardShippingAddressModel(
      fullName: _stringValue(json['fullName']),
      whatsappNumber: _stringValue(json['whatsappNumber']),
      addressLine: _stringValue(json['addressLine']),
      countryCode: _stringValue(json['countryCode'], fallback: 'IT'),
      latitude: _doubleValue(json['latitude']),
      longitude: _doubleValue(json['longitude']),
      isLocked: _boolValue(json['isLocked']),
      updatedAt: _dateValue(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName,
      'whatsappNumber': whatsappNumber,
      'addressLine': addressLine,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'isLocked': isLocked,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  RewardShippingAddressModel copyWith({
    String? fullName,
    String? whatsappNumber,
    String? addressLine,
    String? countryCode,
    double? latitude,
    double? longitude,
    bool? isLocked,
    DateTime? updatedAt,
  }) {
    return RewardShippingAddressModel(
      fullName: fullName ?? this.fullName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      addressLine: addressLine ?? this.addressLine,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocked: isLocked ?? this.isLocked,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RewardFulfillmentModel {
  const RewardFulfillmentModel({
    required this.addressRequestedAt,
    required this.addressReceivedAt,
    required this.processingAt,
    required this.dispatchedAt,
    required this.deliveredAt,
    required this.carrierName,
    required this.trackingNumber,
    required this.invoiceUrl,
  });

  final DateTime? addressRequestedAt;
  final DateTime? addressReceivedAt;
  final DateTime? processingAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final String? carrierName;
  final String? trackingNumber;
  final String? invoiceUrl;

  factory RewardFulfillmentModel.fromJson(Map<String, dynamic> json) {
    return RewardFulfillmentModel(
      addressRequestedAt: _dateValue(json['addressRequestedAt']),
      addressReceivedAt: _dateValue(json['addressReceivedAt']),
      processingAt: _dateValue(json['processingAt']),
      dispatchedAt: _dateValue(json['dispatchedAt']),
      deliveredAt: _dateValue(json['deliveredAt']),
      carrierName: _nullableString(json['carrierName']),
      trackingNumber: _nullableString(json['trackingNumber']),
      invoiceUrl: _nullableString(json['invoiceUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'addressRequestedAt': addressRequestedAt?.toIso8601String(),
      'addressReceivedAt': addressReceivedAt?.toIso8601String(),
      'processingAt': processingAt?.toIso8601String(),
      'dispatchedAt': dispatchedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'carrierName': carrierName,
      'trackingNumber': trackingNumber,
      'invoiceUrl': invoiceUrl,
    };
  }
}

class RewardModel {
  const RewardModel({
    required this.id,
    required this.rewardType,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.iconKey,
    required this.status,
    required this.statusLabel,
    required this.primaryAmount,
    required this.secondaryAmount,
    required this.primaryUnit,
    required this.secondaryUnit,
    required this.isSeen,
    required this.isOpened,
    required this.awardedAt,
    required this.action,
    required this.congratulatoryNote,
    required this.earnedReason,
    required this.fileUrl,
    required this.relatedResourceId,
    required this.playConfettiAnimation,
    required this.requestShippingAddress,
    required this.openedAt,
    required this.shippingAddress,
    required this.fulfillment,
  });

  final String id;
  final RewardType rewardType;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String iconKey;
  final String status;
  final String statusLabel;
  final int? primaryAmount;
  final int? secondaryAmount;
  final String? primaryUnit;
  final String? secondaryUnit;
  final bool isSeen;
  final bool isOpened;
  final DateTime? awardedAt;
  final RewardActionModel? action;
  final String? congratulatoryNote;
  final String? earnedReason;
  final String? fileUrl;
  final String? relatedResourceId;
  final bool playConfettiAnimation;
  final bool requestShippingAddress;
  final DateTime? openedAt;
  final RewardShippingAddressModel? shippingAddress;
  final RewardFulfillmentModel? fulfillment;

  bool get canConfirmDelivery =>
      rewardType.isPhysical && status.toLowerCase() == 'dispatched';

  String get valueLabel {
    final List<String> values = <String>[];
    if (primaryAmount != null) {
      values.add('$primaryAmount${_unitSuffix(primaryUnit)}');
    }
    if (secondaryAmount != null) {
      values.add('$secondaryAmount${_unitSuffix(secondaryUnit)}');
    }
    return values.join(' + ');
  }

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: _stringValue(json['id']),
      rewardType: RewardType.fromApi(json['rewardType']),
      title: _stringValue(json['title']),
      subtitle: _stringValue(json['subtitle']),
      imageUrl: _nullableString(json['imageUrl']),
      iconKey: _stringValue(json['iconKey']),
      status: _stringValue(json['status']),
      statusLabel: _stringValue(json['statusLabel']),
      primaryAmount: _intValue(json['primaryAmount']),
      secondaryAmount: _intValue(json['secondaryAmount']),
      primaryUnit: _nullableString(json['primaryUnit']),
      secondaryUnit: _nullableString(json['secondaryUnit']),
      isSeen: _boolValue(json['isSeen']),
      isOpened: _boolValue(json['isOpened']),
      awardedAt: _dateValue(json['awardedAt']),
      action: _modelMap(json['action'], RewardActionModel.fromJson),
      congratulatoryNote: _nullableString(json['congratulatoryNote']),
      earnedReason: _nullableString(json['earnedReason']),
      fileUrl: _nullableString(json['fileUrl']),
      relatedResourceId: _nullableString(json['relatedResourceId']),
      playConfettiAnimation: _boolValue(json['playConfettiAnimation']),
      requestShippingAddress: _boolValue(json['requestShippingAddress']),
      openedAt: _dateValue(json['openedAt']),
      shippingAddress: _modelMap(
        json['shippingAddress'],
        RewardShippingAddressModel.fromJson,
      ),
      fulfillment: _modelMap(
        json['fulfillment'],
        RewardFulfillmentModel.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'rewardType': rewardType.apiValue,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'iconKey': iconKey,
      'status': status,
      'statusLabel': statusLabel,
      'primaryAmount': primaryAmount,
      'secondaryAmount': secondaryAmount,
      'primaryUnit': primaryUnit,
      'secondaryUnit': secondaryUnit,
      'isSeen': isSeen,
      'isOpened': isOpened,
      'awardedAt': awardedAt?.toIso8601String(),
      'action': action?.toJson(),
      'congratulatoryNote': congratulatoryNote,
      'earnedReason': earnedReason,
      'fileUrl': fileUrl,
      'relatedResourceId': relatedResourceId,
      'playConfettiAnimation': playConfettiAnimation,
      'requestShippingAddress': requestShippingAddress,
      'openedAt': openedAt?.toIso8601String(),
      'shippingAddress': shippingAddress?.toJson(),
      'fulfillment': fulfillment?.toJson(),
    };
  }

  RewardModel copyWith({
    String? status,
    String? statusLabel,
    bool? isSeen,
    bool? isOpened,
    RewardActionModel? action,
    DateTime? openedAt,
    RewardShippingAddressModel? shippingAddress,
    RewardFulfillmentModel? fulfillment,
  }) {
    return RewardModel(
      id: id,
      rewardType: rewardType,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      iconKey: iconKey,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      primaryAmount: primaryAmount,
      secondaryAmount: secondaryAmount,
      primaryUnit: primaryUnit,
      secondaryUnit: secondaryUnit,
      isSeen: isSeen ?? this.isSeen,
      isOpened: isOpened ?? this.isOpened,
      awardedAt: awardedAt,
      action: action ?? this.action,
      congratulatoryNote: congratulatoryNote,
      earnedReason: earnedReason,
      fileUrl: fileUrl,
      relatedResourceId: relatedResourceId,
      playConfettiAnimation: playConfettiAnimation,
      requestShippingAddress: requestShippingAddress,
      openedAt: openedAt ?? this.openedAt,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      fulfillment: fulfillment ?? this.fulfillment,
    );
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
