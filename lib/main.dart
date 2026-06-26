import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/bindings/initial_bindings.dart';
import 'core/bootstrap/app_bootstrap_controller.dart';
import 'core/localization/translation_service.dart';
import 'core/services/callkit_background_action_handler.dart';
import 'core/services/callkit_incoming_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/themes/app_theme.dart';
import 'features/messages/sub-feature/call/service/call_socket_service.dart';
import 'features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import 'routes/routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  await Firebase.initializeApp();

  await CallkitIncomingService.showIncomingCallFromMessage(
    message,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );


  await FlutterCallkitIncoming.onBackgroundMessage(
    callkitBackgroundActionHandler,
  );

  await LocalNotificationService.instance.initialize();
  LocalNotificationService.instance.listenToForegroundMessages();

  await AppBootstrapController.init();

  /*
   * Register TokenService-dependent call services before
   * CallKit callbacks try to access them through Get.find().
   */
  InitialBindings().dependencies();

  runApp(
    ItalyApp(
      initialRoute: AppPages.initial,
    ),
  );

  /*
   * Wait until GetMaterialApp and its navigator are mounted.
   * This is required when answering a CallKit call from
   * background or terminated state.
   */
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeCallKit());
  });
}

Future<void> _initializeCallKit() async {

  if (Platform.isAndroid) {
    try {
      final bool canUseFullScreenIntent =
      await FlutterCallkitIncoming.canUseFullScreenIntent();

      if (!canUseFullScreenIntent) {
        await FlutterCallkitIncoming.requestFullIntentPermission();
      }
    } catch (error) {
      debugPrint(
        '[CallKit] Full-screen intent permission failed: $error',
      );
    }
  }

  await CallkitIncomingService.initialize(
    onAccept: (
        String callId,
        Map<String, dynamic> data,
        ) async {
      try {
        final CallSocketService socketService =
        Get.find<CallSocketService>();

        final Map<String, dynamic> answerResponse =
        await socketService.answerCall(
          callId: callId,
        );

        final IncomingCallCoordinator coordinator =
        Get.find<IncomingCallCoordinator>();

        unawaited(
          coordinator
              .openAcceptedCall(
            callId: callId,
            callData: data,
            answerResponse: answerResponse,
          )
              .catchError(
                (Object error, StackTrace stackTrace) async {
              await CallkitIncomingService.endCall(callId);

              Get.snackbar(
                'Call failed',
                error.toString(),
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        );

        await CallkitIncomingService.markCallConnected(
          callId,
        );
      } catch (error) {
        await CallkitIncomingService.endCall(callId);

        Get.snackbar(
          'Call failed',
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    },
    onDecline: (
        String callId,
        Map<String, dynamic> data,
        ) async {
      try {
        final CallSocketService socketService =
        Get.find<CallSocketService>();

        debugPrint(
          '[CallKit] Sending receiver rejection '
              'callId=$callId',
        );

        await socketService.rejectCall(
          callId: callId,
        );

        debugPrint(
          '[CallKit] Receiver rejection completed '
              'callId=$callId',
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[CallKit] Receiver rejection failed: $error',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      }
    },
    onEnded: (
        String callId,
        Map<String, dynamic> data,
        ) async {
      try {
        final CallSocketService socketService =
        Get.find<CallSocketService>();

        await socketService.endCall(
          callId: callId,
        );
      } finally {
        await CallkitIncomingService.endCall(
          callId,
        );
      }
    },
  );
}

class ItalyApp extends StatelessWidget {
  final String initialRoute;

  const ItalyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 884),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final TranslationService translationService =
        Get.find<TranslationService>();

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Italir Pothe',
          translations: translationService,
          locale: translationService.currentLocale,
          fallbackLocale: TranslationService.fallbackLocale,
          theme: AppTheme.lightTheme,
          getPages: AppPages.pages,
          initialRoute: initialRoute,
        );
      },
    );
  }
}