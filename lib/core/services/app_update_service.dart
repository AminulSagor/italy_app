import 'dart:io';

import 'package:get/get.dart' hide Response;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_update_configuration.dart';
import '../utils/app_logger.dart';
import '../widgets/app_update_dialog.dart';
import 'api_client.dart';

class AppUpdateService {
  AppUpdateService({required this.apiClient});

  final ApiClient apiClient;
  bool _optionalUpdateShownThisSession = false;

  static AppUpdateDecision decide({
    required String installedVersion,
    required AppUpdateConfiguration configuration,
  }) {
    if (!configuration.enabled) {
      return AppUpdateDecision.none;
    }

    final Version installed = Version.parse(installedVersion);
    if (installed < Version.parse(configuration.minimumSupportedVersion)) {
      return AppUpdateDecision.required;
    }
    if (installed < Version.parse(configuration.latestVersion)) {
      return AppUpdateDecision.optional;
    }
    return AppUpdateDecision.none;
  }

  Future<void> handleStartupUpdate() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      final String platform = Platform.isAndroid ? 'android' : 'ios';
      final response = await apiClient.dio.get<Map<String, dynamic>>(
        '/app-update/config',
        queryParameters: <String, String>{'platform': platform},
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) return;

      final AppUpdateConfiguration configuration =
          AppUpdateConfiguration.fromJson(data);
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final AppUpdateDecision decision = decide(
        installedVersion: packageInfo.version,
        configuration: configuration,
      );

      if (decision == AppUpdateDecision.required) {
        await Get.dialog<void>(
          AppUpdateDialog(
            configuration: configuration,
            requiredUpdate: true,
            onUpdate: () => _openStore(configuration.storeUrl, platform),
          ),
          barrierDismissible: false,
        );
        // Defensive: if the route is removed externally, re-run the gate.
        return handleStartupUpdate();
      }

      if (decision == AppUpdateDecision.optional &&
          !_optionalUpdateShownThisSession) {
        _optionalUpdateShownThisSession = true;
        await Get.dialog<void>(
          AppUpdateDialog(
            configuration: configuration,
            requiredUpdate: false,
            onUpdate: () => _openStore(configuration.storeUrl, platform),
          ),
          barrierDismissible: false,
        );
      }
    } catch (error, stackTrace) {
      // Update checks fail open so an outage or malformed config cannot brick
      // an otherwise usable released application.
      AppLogger.log(
        'App update check failed open',
        error: error,
        stackTrace: stackTrace,
        name: 'AppUpdate',
      );
    }
  }

  Future<void> _openStore(String rawUrl, String platform) async {
    final Uri uri = Uri.parse(rawUrl);
    final bool officialUrl =
        uri.scheme == 'https' &&
        ((platform == 'android' &&
                uri.host == 'play.google.com' &&
                uri.path.startsWith('/store/apps/details')) ||
            (platform == 'ios' &&
                uri.host == 'apps.apple.com' &&
                uri.path.contains('/app/')));
    if (!officialUrl ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Unable to open store', 'Please try again in a moment.');
    }
  }
}
