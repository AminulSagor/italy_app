import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/features/drawer_features/shop/widgets/app_store_subscription_disclosure.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel urlLauncherChannel = MethodChannel(
    'plugins.flutter.io/url_launcher',
  );
  final List<String> launchedUrls = <String>[];

  setUp(() {
    launchedUrls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, (MethodCall call) async {
          if (call.method == 'launch') {
            launchedUrls.add(
              (call.arguments as Map<Object?, Object?>)['url']! as String,
            );
            return true;
          }
          return null;
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, null);
  });

  test('iOS subscription terms use Apple Standard EULA', () {
    expect(
      subscriptionTermsOfUseUri(TargetPlatform.iOS).toString(),
      appleStandardEulaUrl,
    );
  });

  test('Android subscription terms keep Italir Pothe terms', () {
    expect(
      subscriptionTermsOfUseUri(TargetPlatform.android).toString(),
      platformTermsAndConditionsUrl,
    );
  });

  test('privacy policy URL remains unchanged', () {
    expect(appPrivacyPolicyUrl, 'https://www.italirpothe.com/privacy-policy');
  });

  testWidgets('iOS disclosure keeps required details and functional actions', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    var restoreCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AppStoreSubscriptionDisclosure(
              title: 'Monthly AI Credits',
              price: r'$9.99',
              billingDuration: '1 month',
              isRestoring: false,
              onRestore: () async {
                restoreCalls++;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Monthly AI Credits'), findsOneWidget);
    expect(find.text(r'$9.99'), findsOneWidget);
    expect(find.text('1 month'), findsOneWidget);
    expect(find.text('apple_subscription_renewal_disclosure'), findsOneWidget);
    expect(find.text('apple_subscription_cancellation'), findsOneWidget);
    expect(find.text('privacy_policy'), findsOneWidget);
    expect(find.text('Terms of Use (EULA)'), findsOneWidget);
    expect(find.text('restore_purchases'), findsOneWidget);

    await tester.tap(find.text('Terms of Use (EULA)'));
    await tester.pump();
    expect(launchedUrls.removeLast(), appleStandardEulaUrl);

    await tester.tap(find.text('privacy_policy'));
    await tester.pump();
    expect(launchedUrls.removeLast(), appPrivacyPolicyUrl);

    await tester.tap(find.text('apple_subscription_cancellation'));
    await tester.pump();
    expect(
      launchedUrls.removeLast(),
      'https://apps.apple.com/account/subscriptions',
    );

    await tester.tap(find.text('restore_purchases'));
    await tester.pump();
    expect(restoreCalls, 1);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Android disclosure retains existing terms link and label', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStoreSubscriptionDisclosure(
            title: 'Monthly AI Credits',
            price: r'$9.99',
            billingDuration: '1 month',
            isRestoring: false,
            onRestore: () async {},
          ),
        ),
      ),
    );

    expect(find.text('terms_and_conditions'), findsOneWidget);
    await tester.tap(find.text('terms_and_conditions'));
    await tester.pump();
    expect(launchedUrls.single, platformTermsAndConditionsUrl);
    debugDefaultTargetPlatformOverride = null;
  });
}
