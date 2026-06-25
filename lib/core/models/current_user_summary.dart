class CurrentUserSummary {
  const CurrentUserSummary({
    required this.fullName,
    required this.learnerLevel,
    this.avatarUrl,
  });

  final String fullName;
  final String learnerLevel;
  final String? avatarUrl;

  factory CurrentUserSummary.fromJson(Map<String, dynamic> json) {
    return CurrentUserSummary(
      fullName: json['fullName']?.toString().trim() ?? '',
      learnerLevel: json['learnerLevel']?.toString().trim() ?? 'A1',
      avatarUrl: _nullableString(json['avatarUrl']),
    );
  }

  CurrentUserSummary copyWith({
    String? fullName,
    String? learnerLevel,
    String? avatarUrl,
  }) {
    return CurrentUserSummary(
      fullName: fullName ?? this.fullName,
      learnerLevel: learnerLevel ?? this.learnerLevel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  static String? _nullableString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
