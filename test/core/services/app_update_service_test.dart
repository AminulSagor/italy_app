import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/models/app_update_configuration.dart';
import 'package:italir_pothe/core/services/app_update_service.dart';

AppUpdateConfiguration config({
  String latest = '1.10.0',
  String minimum = '1.9.0',
  bool enabled = true,
}) => AppUpdateConfiguration(
  latestVersion: latest,
  minimumSupportedVersion: minimum,
  title: 'Update',
  message: 'Update available',
  storeUrl: 'https://play.google.com/store/apps/details?id=test',
  enabled: enabled,
);

void main() {
  test('compares semantic versions numerically', () {
    expect(
      AppUpdateService.decide(
        installedVersion: '1.9.0',
        configuration: config(),
      ),
      AppUpdateDecision.optional,
    );
  });

  test('automatically requires versions below minimum', () {
    expect(
      AppUpdateService.decide(
        installedVersion: '1.8.9',
        configuration: config(),
      ),
      AppUpdateDecision.required,
    );
  });

  test('automatically offers optional update between minimum and latest', () {
    expect(
      AppUpdateService.decide(
        installedVersion: '1.9.0',
        configuration: config(),
      ),
      AppUpdateDecision.optional,
    );
  });

  test('does not prompt users already on latest version', () {
    expect(
      AppUpdateService.decide(
        installedVersion: '1.10.0',
        configuration: config(),
      ),
      AppUpdateDecision.none,
    );
  });

  test('disabled configuration never prompts', () {
    expect(
      AppUpdateService.decide(
        installedVersion: '0.1.0',
        configuration: config(enabled: false),
      ),
      AppUpdateDecision.none,
    );
  });
}
