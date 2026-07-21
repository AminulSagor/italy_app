import 'dart:async';
import 'dart:developer' as dev;
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
import 'core/services/connectivity_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/learning_activity_tracker_service.dart';
import 'core/services/screen_protection_service.dart';
import 'core/themes/app_theme.dart';
import 'core/widgets/connectivity_offline_view.dart';
import 'features/messages/sub-feature/call/widgets/global_call_status_card.dart';
import 'core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/messages/sub-feature/call/service/call_socket_service.dart';
import 'features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import 'routes/routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await CallkitIncomingService.showIncomingCallFromBackgroundMessage(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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

  final ConnectivityService connectivityService =
  Get.put<ConnectivityService>(
    ConnectivityService(),
    permanent: true,
  );

  await connectivityService.init();

  // Attach foreground FCM and CallKit event listeners before the first frame
  // so the first incoming call after installation cannot be missed.
  await _initializeCallKitListeners();


  Get.put<ScreenProtectionService>(
    ScreenProtectionService(),
    permanent: true,
  );


  runApp(ItalyApp(initialRoute: AppPages.initial));

  /*
   * Wait until GetMaterialApp and its navigator are mounted.
   * This is required when answering a CallKit call from
   * background or terminated state.
   */
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_completeCallKitStartup());
  });
}

Future<void> _initializeCallKitListeners() async {
  await CallkitIncomingService.initialize(
    onIncoming: (String callId, Map<String, dynamic> data) async {
      if (!Get.isRegistered<IncomingCallCoordinator>()) {
        return;
      }

      unawaited(
        Get.find<IncomingCallCoordinator>().openNativeIncomingCall(
          callId: callId,
          callData: data,
        ),
      );
    },
    onAccept: (String callId, Map<String, dynamic> data) async {
      if (!Get.isRegistered<IncomingCallCoordinator>()) {
        await CallkitIncomingService.endNativeSubsystemOnly(callId);
        return;
      }

      unawaited(
        Get.find<IncomingCallCoordinator>().acceptNativeCall(
          callId: callId,
          callData: data,
        ),
      );
    },
    onDecline: (String callId, Map<String, dynamic> data) async {
      try {
        await Get.find<CallSocketService>().rejectCall(callId: callId);

        if (Get.isRegistered<IncomingCallCoordinator>()) {
          Get.find<IncomingCallCoordinator>().dismissIncomingCall(callId);
        }
      } catch (error, stackTrace) {
        dev.log(
          'Unable to synchronize declined call',
          name: 'CallKit',
          error: error,
          stackTrace: stackTrace,
        );
      }
    },
    onTimeout: (String callId, Map<String, dynamic> data) async {
      try {
        await Get.find<CallSocketService>().timeoutCall(callId: callId);
      } catch (error, stackTrace) {
        dev.log(
          'Unable to synchronize timed-out call',
          name: 'CallKit',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        if (Get.isRegistered<IncomingCallCoordinator>()) {
          Get.find<IncomingCallCoordinator>().dismissIncomingCall(callId);
        }
        await CallkitIncomingService.endNativeSubsystemOnly(callId);
      }
    },
    onEnded: (String callId, Map<String, dynamic> data) async {
      if (CallkitIncomingService.consumeRemoteTermination(callId)) {
        return;
      }

      try {
        final CallSocketService socketService = Get.find<CallSocketService>();
        final Map<String, dynamic> statusResponse = await socketService
            .fetchCall(callId: callId);
        final dynamic rawCall = statusResponse['call'];
        final Map<String, dynamic> call = rawCall is Map
            ? Map<String, dynamic>.from(rawCall)
            : <String, dynamic>{};

        if (call['status']?.toString() == 'active') {
          await socketService.endCall(callId: callId);
        }
      } catch (error, stackTrace) {
        dev.log(
          'Unable to synchronize ended call',
          name: 'CallKit',
          error: error,
          stackTrace: stackTrace,
        );
      }
    },
  );
}

Future<void> _completeCallKitStartup() async {
  if (Get.isRegistered<IncomingCallCoordinator>()) {
    final IncomingCallCoordinator coordinator =
        Get.find<IncomingCallCoordinator>();
    unawaited(
      coordinator.restorePendingAcceptedCall(
        waitForBackgroundHandler: const Duration(milliseconds: 800),
      ),
    );
    unawaited(coordinator.restoreNativeIncomingCall());
  }

  unawaited(_requestFullScreenCallPermission());
}

Future<void> _requestFullScreenCallPermission() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final bool canUseFullScreenIntent =
        await FlutterCallkitIncoming.canUseFullScreenIntent();

    if (!canUseFullScreenIntent) {
      await FlutterCallkitIncoming.requestFullIntentPermission();
    }
  } catch (error, stackTrace) {
    dev.log(
      'Unable to request full-screen call permission',
      name: 'CallKit',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

class ItalyApp extends StatelessWidget {
  final String initialRoute;

  const ItalyApp({super.key, required this.initialRoute});

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
          title: 'gen_italir_pothe'.tr,
          translations: translationService,
          locale: translationService.currentLocale,
          fallbackLocale: TranslationService.fallbackLocale,
          theme: AppTheme.lightTheme,
          getPages: AppPages.pages,

          builder: (BuildContext context, Widget? navigator) {
            final Widget navigatorChild =
                navigator ?? const SizedBox.shrink();

            final ConnectivityService? connectivityService =
            Get.isRegistered<ConnectivityService>()
                ? Get.find<ConnectivityService>()
                : null;

            final IncomingCallCoordinator? callCoordinator =
            Get.isRegistered<IncomingCallCoordinator>()
                ? Get.find<IncomingCallCoordinator>()
                : null;

            if (connectivityService == null && callCoordinator == null) {
              return navigatorChild;
            }

            return Obx(() {
              final bool isOffline =
                  connectivityService?.isOffline ?? false;

              final bool showCallCard =
                  callCoordinator != null &&
                      callCoordinator.hasPresentedCall.value &&
                      !callCoordinator.isPresentedCallScreenVisible.value;

              /*
     * Completely hide the current application page while offline.
     * The navigator remains mounted internally, so the user returns
     * to the same page when connectivity is restored.
     */
              if (isOffline) {
                return Column(
                  children: <Widget>[
                    /*
           * Preserve the existing active-call functionality without
           * exposing the application page underneath.
           */
                    if (showCallCard)
                      const GlobalCallStatusCard(),

                    const Expanded(
                      child: ConnectivityOfflineView(),
                    ),
                  ],
                );
              }

              /*
     * Normal online state without an active call.
     */
              if (!showCallCard) {
                return navigatorChild;
              }

              /*
     * Preserve the existing global call-status-card behavior.
     */
              return Column(
                children: <Widget>[
                  const GlobalCallStatusCard(),
                  Expanded(
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).removePadding(removeTop: true),
                      child: navigatorChild,
                    ),
                  ),
                ],
              );
            });
          },

          routingCallback: (Routing? routing) {
            final String? currentRoute = routing?.current;

            if (currentRoute?.isNotEmpty == true &&
                routing?.isDialog != true &&
                routing?.isBottomSheet != true &&
                Get.isRegistered<ScreenProtectionService>()) {
              unawaited(
                Get.find<ScreenProtectionService>().updateForRoute(
                  currentRoute,
                ),
              );
            }

            if (Get.isRegistered<LearningActivityTrackerService>()) {
              Get.find<LearningActivityTrackerService>().handleRoute(
                currentRoute,
              );
            }

            if (currentRoute == AppRoutes.wrapper &&
                Get.isRegistered<NavbarAndAppbarWrapperController>() &&
                Get.find<NavbarAndAppbarWrapperController>()
                    .currentIndex
                    .value ==
                    0 &&
                Get.isRegistered<HomeController>()) {
              unawaited(
                Get.find<NavbarAndAppbarWrapperController>()
                    .refreshHomeDashboard(),
              );
            }
          },

          initialRoute: initialRoute,
        );
      },
    );
  }
}
