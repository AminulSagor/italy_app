class UserModel {
  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    this.profilePhotoFileId,
    required this.isOnline,
    this.lastSeenAt,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final bool isVerified;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? profilePhotoFileId;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'USER',
      isVerified: json['isVerified'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      profilePhotoFileId: json['profilePhotoFileId'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'profilePhotoFileId': profilePhotoFileId,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt?.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class UserSearchItemModel {
  UserSearchItemModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.isOnline,
    this.lastSeenAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeenAt;

  factory UserSearchItemModel.fromJson(Map<String, dynamic> json) {
    return UserSearchItemModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'USER',
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
    );
  }
}

class UserSearchResponseModel {
  UserSearchResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  final List<UserSearchItemModel> items;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  factory UserSearchResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        json['items'] as List<dynamic>? ?? <dynamic>[];
    return UserSearchResponseModel(
      items: rawItems
          .map(
            (dynamic e) => UserSearchItemModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      perPage: json['perPage'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class UserListItemModel {
  UserListItemModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.isOnline,
    this.lastSeenAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final bool isOnline;
  final DateTime? lastSeenAt;

  factory UserListItemModel.fromJson(Map<String, dynamic> json) {
    return UserListItemModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
    );
  }
}

class BlockStatusModel {
  BlockStatusModel({required this.status});

  final String status; // none, blocked_by_me, blocked_me, both_blocked

  factory BlockStatusModel.fromJson(Map<String, dynamic> json) {
    return BlockStatusModel(status: json['status'] as String? ?? 'none');
  }
}

class UserBlockModel {
  UserBlockModel({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.createdAt,
  });

  final String id;
  final String blockerId;
  final String blockedId;
  final DateTime createdAt;

  factory UserBlockModel.fromJson(Map<String, dynamic> json) {
    return UserBlockModel(
      id: json['id'] as String,
      blockerId: json['blockerId'] as String,
      blockedId: json['blockedId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class BlockedUserItemModel {
  BlockedUserItemModel({
    required this.blockedUserId,
    required this.fullName,
    required this.email,
    this.phone,
    required this.blockedAt,
  });

  final String blockedUserId;
  final String fullName;
  final String email;
  final String? phone;
  final DateTime blockedAt;

  factory BlockedUserItemModel.fromJson(Map<String, dynamic> json) {
    return BlockedUserItemModel(
      blockedUserId: json['blockedUserId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      blockedAt: DateTime.parse(json['blockedAt'] as String),
    );
  }
}
