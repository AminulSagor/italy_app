import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/services/connectivity_service.dart';
import 'package:italir_pothe/core/widgets/connectivity_offline_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.put<ConnectivityService>(ConnectivityService());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('keeps the active child state mounted while offline', (
    WidgetTester tester,
  ) async {
    final GlobalKey<_StatefulProbeState> probeKey =
        GlobalKey<_StatefulProbeState>();

    Future<void> pumpGate(bool isOffline) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityOfflineGate(
              isOffline: isOffline,
              child: _StatefulProbe(key: probeKey),
            ),
          ),
        ),
      );
    }

    await pumpGate(false);
    probeKey.currentState!.increment();
    await tester.pump();
    expect(find.text('value: 1'), findsOneWidget);

    await pumpGate(true);
    expect(probeKey.currentState, isNotNull);
    expect(find.byType(ConnectivityOfflineView), findsOneWidget);

    await pumpGate(false);
    expect(find.text('value: 1'), findsOneWidget);
    expect(find.byType(ConnectivityOfflineView), findsNothing);
  });
}

class _StatefulProbe extends StatefulWidget {
  const _StatefulProbe({super.key});

  @override
  State<_StatefulProbe> createState() => _StatefulProbeState();
}

class _StatefulProbeState extends State<_StatefulProbe> {
  int value = 0;

  void increment() {
    setState(() {
      value += 1;
    });
  }

  @override
  Widget build(BuildContext context) => Text('value: $value');
}
