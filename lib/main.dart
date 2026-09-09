import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/bootstrap/app_bootstrap_controller.dart';
import 'core/localization/translation_service.dart';
import 'core/services/callkit_background_action_handler.dart';
import 'core/services/callkit_incoming_service.dart';
import 'core/services/callkit_pending_action_store.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/crash_error_policy.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/learning_activity_tracker_service.dart';
import 'core/services/screen_protection_service.dart';
import 'core/services/token_service.dart';
import 'core/themes/app_theme.dart';
import 'core/widgets/connectivity_offline_view.dart';
import 'features/messages/sub-feature/call/widgets/global_call_status_card.dart';
import 'core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/messages/sub-feature/call/controllers/message_call_controller.dart';
import 'features/messages/sub-feature/call/service/call_socket_service.dart';
import 'features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import 'routes/routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();

  final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);

  // Show the native incoming-call screen and start its ringtone first.
  await CallkitIncomingService.showIncomingCallFromBackgroundMessage(message);

  final String type = data['type']?.toString().trim() ?? '';

  final String callId = data['callId']?.toString().trim() ?? '';

  if (type != 'incoming_call' || callId.isEmpty) {
    return;
  }

  try {
    await dotenv.load(fileName: '.env');

    final TokenService tokenService = await TokenService().init();

    final CallSocketService callService = CallSocketService(
      tokenService: tokenService,
    );

    // Background isolates should use HTTP, not the foreground socket.
    await callService.acknowledgeIncomingCallOverHttp(callId: callId);
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await _configureCrashlytics();

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

  final ConnectivityService connectivityService = Get.put<ConnectivityService>(
    ConnectivityService(),
    permanent: true,
  );

  await connectivityService.init();

  // Attach foreground FCM and CallKit event listeners before the first frame
  // so the first incoming call after installation cannot be missed.
  await _initializeCallKitListeners();

  Get.put<ScreenProtectionService>(ScreenProtectionService(), permanent: true);

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

Future<void> _configureCrashlytics() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    kReleaseMode,
  );

  final FlutterExceptionHandler? previousFlutterErrorHandler =
      FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      final bool isRecoverable = CrashErrorPolicy.isRecoverable(
        details.exception,
        details.stack ?? StackTrace.empty,
      );

      unawaited(
        isRecoverable
            ? FirebaseCrashlytics.instance.recordFlutterError(details)
            : FirebaseCrashlytics.instance.recordFlutterFatalError(details),
      );
      return;
    }

    previousFlutterErrorHandler?.call(details);
  };

  final ErrorCallback? previousPlatformErrorHandler =
      PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    if (kReleaseMode) {
      final bool isRecoverable = CrashErrorPolicy.isRecoverable(
        error,
        stackTrace,
      );

      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: !isRecoverable,
        ),
      );
      return true;
    }

    return previousPlatformErrorHandler?.call(error, stackTrace) ?? false;
  };
}

Future<void> _initializeCallKitListeners() async {
  await CallkitIncomingService.initialize(
    onIncoming: (String callId, Map<String, dynamic> data) async {
      if (!Get.isRegistered<IncomingCallCoordinator>()) {
        return;
      }

      final IncomingCallCoordinator coordinator =
          Get.find<IncomingCallCoordinator>();

      // PushKit has already shown CallKit at this point. On iOS the Flutter
      // route stays unavailable while locked, so acknowledge independently of
      // route restoration and let the caller advance to ringing immediately.
      if (Platform.isIOS) {
        unawaited(_acknowledgeIosCallKitIncoming(coordinator, callId));
      }

      unawaited(
        coordinator.openNativeIncomingCall(callId: callId, callData: data),
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
      } catch (_) {
      } finally {
        // A missing call is already terminal on the server. Always remove the
        // corresponding native/Flutter incoming UI so another decline action
        // cannot be emitted for the same stale call.
        if (Get.isRegistered<IncomingCallCoordinator>()) {
          Get.find<IncomingCallCoordinator>().dismissIncomingCall(callId);
        }
        await CallkitPendingActionStore.clearDeclinedCall();
      }
    },
    onTimeout: (String callId, Map<String, dynamic> data) async {
      try {
        await Get.find<CallSocketService>().timeoutCall(callId: callId);
      } catch (_) {
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

      if (Get.isRegistered<MessageCallController>()) {
        Get.find<MessageCallController>().closeFromNativeEnd(callId);
      }

      await CallkitPendingActionStore.saveEndedCall(
        callId: callId,
        callData: data,
      );
      try {
        final CallSocketService socketService = Get.find<CallSocketService>();
        await socketService.endCallOverHttp(callId: callId);
        await CallkitPendingActionStore.clearEndedCall();
      } on CallSocketException catch (error) {
        if (error.code == 'CALL_NOT_FOUND' ||
            error.code == 'CALL_CANNOT_BE_ENDED') {
          await CallkitPendingActionStore.clearEndedCall();
        }
      } catch (_) {
      } finally {
        await CallkitPendingActionStore.clearAcceptedCall();
      }
    },
  );
}

Future<void> _acknowledgeIosCallKitIncoming(
  IncomingCallCoordinator coordinator,
  String callId,
) async {
  try {
    await coordinator.acknowledgeNativeIncomingCall(callId);
  } catch (_) {}
}

Future<void> _completeCallKitStartup() async {
  final PendingEndedCall? pendingEnd =
      await CallkitPendingActionStore.takeEndedCall();
  if (pendingEnd != null) {
    if (!Get.isRegistered<CallSocketService>()) {
      await CallkitPendingActionStore.saveEndedCall(
        callId: pendingEnd.callId,
        callData: pendingEnd.callData,
      );
    } else {
      try {
        await Get.find<CallSocketService>().endCallOverHttp(
          callId: pendingEnd.callId,
        );
      } on CallSocketException catch (error) {
        if (error.code != 'CALL_NOT_FOUND' &&
            error.code != 'CALL_CANNOT_BE_ENDED') {
          await CallkitPendingActionStore.saveEndedCall(
            callId: pendingEnd.callId,
            callData: pendingEnd.callData,
          );
        }
      } catch (_) {
        await CallkitPendingActionStore.saveEndedCall(
          callId: pendingEnd.callId,
          callData: pendingEnd.callData,
        );
      }
    }
  }

  final PendingDeclinedCall? pendingDecline =
      await CallkitPendingActionStore.takeDeclinedCall();
  if (pendingDecline != null) {
    if (!Get.isRegistered<CallSocketService>()) {
      await CallkitPendingActionStore.saveDeclinedCall(
        callId: pendingDecline.callId,
        callData: pendingDecline.callData,
      );
    } else {
      try {
        await Get.find<CallSocketService>().rejectCallOverHttp(
          callId: pendingDecline.callId,
        );
        await CallkitIncomingService.endNativeSubsystemOnly(
          pendingDecline.callId,
        );
      } on CallSocketException catch (error) {
        if (error.code == 'CALL_NOT_FOUND') {
          await CallkitIncomingService.endNativeSubsystemOnly(
            pendingDecline.callId,
          );
        } else {
          await CallkitPendingActionStore.saveDeclinedCall(
            callId: pendingDecline.callId,
            callData: pendingDecline.callData,
          );
        }
      } catch (_) {
        await CallkitPendingActionStore.saveDeclinedCall(
          callId: pendingDecline.callId,
          callData: pendingDecline.callData,
        );
      }
    }
  }

  if (Get.isRegistered<IncomingCallCoordinator>()) {
    final IncomingCallCoordinator coordinator =
        Get.find<IncomingCallCoordinator>();

    unawaited(
      coordinator.restorePendingAcceptedCall(
        waitForBackgroundHandler: Platform.isIOS
            ? const Duration(seconds: 15)
            : const Duration(milliseconds: 800),
      ),
    );

    unawaited(coordinator.restoreNativeIncomingCall());
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
            final Widget navigatorChild = navigator ?? const SizedBox.shrink();

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
              final bool isOffline = connectivityService?.isOffline ?? false;

              final bool showCallCard =
                  callCoordinator != null &&
                  callCoordinator.hasPresentedCall.value &&
                  !callCoordinator.isPresentedCallScreenVisible.value;

              return ConnectivityOfflineGate(
                isOffline: isOffline,
                header: showCallCard ? const GlobalCallStatusCard() : null,
                child: showCallCard
                    ? MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).removePadding(removeTop: true),
                        child: navigatorChild,
                      )
                    : navigatorChild,
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
