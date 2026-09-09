class AppUpdateConfiguration {
  const AppUpdateConfiguration({
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.title,
    required this.message,
    required this.storeUrl,
    required this.enabled,
  });

  factory AppUpdateConfiguration.fromJson(Map<String, dynamic> json) {
    return AppUpdateConfiguration(
      latestVersion: json['latestVersion'] as String,
      minimumSupportedVersion: json['minimumSupportedVersion'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      storeUrl: json['storeUrl'] as String,
      enabled: json['enabled'] as bool,
    );
  }

  final String latestVersion;
  final String minimumSupportedVersion;
  final String title;
  final String message;
  final String storeUrl;
  final bool enabled;
}

enum AppUpdateDecision { none, optional, required }
