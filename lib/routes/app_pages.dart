import 'package:get/get.dart';

import '../features/auth/sub_features/forgot_password/controllers/forgot_password_controller.dart';
import '../features/auth/sub_features/forgot_password/views/forgot_password_otp_view.dart';
import '../features/auth/sub_features/forgot_password/views/forgot_password_view.dart';
import '../features/auth/sub_features/forgot_password/views/password_changed_view.dart';
import '../features/auth/sub_features/forgot_password/views/reset_password_view.dart';
import '../features/auth/sub_features/login/views/login_view.dart';
import '../features/auth/sub_features/Signup/views/account_created.dart';
import '../features/auth/sub_features/Signup/views/OTP_view.dart';
import '../features/auth/sub_features/Signup/controllers/signup_controller.dart';
import '../features/auth/sub_features/Signup/views/signup_view.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/home/services/home_mock_service.dart';
import '../features/home/views/home_view.dart';
import '../features/messages/controllers/messages_controller.dart';
import '../features/messages/services/messages_mock_service.dart';
import '../features/notifications/services/notifications_mock_service.dart';
import '../features/splash/splash_view.dart';
import '../features/splash/splash_controller.dart';
import 'app_routes.dart';
import '../core/bootstrap/app_bootstrap_view.dart';
import '../core/bootstrap/app_bootstrap_controller.dart';
import '../features/auth/sub_features/login/controllers/login_controller.dart';
import '../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_view.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.bootstrap;

  static List<GetPage> pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignupController>(() => SignupController());
      }),
    ),
    GetPage(
      name: AppRoutes.signupOtp,
      page: () => const OtpView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SignupController>()) {
          Get.lazyPut<SignupController>(() => SignupController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.accountCreated,
      page: () => const AccountCreatedView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SignupController>()) {
          Get.lazyPut<SignupController>(() => SignupController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
      }),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordOtp,
      page: () => const ForgotPasswordOtpView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ForgotPasswordController>()) {
          Get.lazyPut<ForgotPasswordController>(
            () => ForgotPasswordController(),
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ForgotPasswordController>()) {
          Get.lazyPut<ForgotPasswordController>(
            () => ForgotPasswordController(),
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordSuccess,
      page: () => const PasswordChangedView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ForgotPasswordController>()) {
          Get.lazyPut<ForgotPasswordController>(
            () => ForgotPasswordController(),
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.bootstrap,
      page: () => const AppBootstrapView(),
      binding: BindingsBuilder(() {
        Get.put<AppBootstrapController>(AppBootstrapController());
      }),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeMockService>(() => HomeMockService());
        Get.lazyPut<HomeController>(
          () => HomeController(homeMockService: Get.find<HomeMockService>()),
        );
      }),
    ),

    GetPage(
      name: AppRoutes.wrapper,
      page: () => const NavbarAndAppbarWrapper(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MessagesMockService>()) {
          Get.lazyPut<MessagesMockService>(() => MessagesMockService());
        }
        if (!Get.isRegistered<MessagesController>()) {
          Get.lazyPut<MessagesController>(
            () => MessagesController(
              messagesMockService: Get.find<MessagesMockService>(),
            ),
          );
        }
        if (!Get.isRegistered<NotificationsMockService>()) {
          Get.lazyPut<NotificationsMockService>(() => NotificationsMockService());
        }
        Get.lazyPut<NavbarAndAppbarWrapperController>(
          () => NavbarAndAppbarWrapperController(),
        );
      }),
    ),
  ];
}
