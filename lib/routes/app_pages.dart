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
import '../features/drawer_features/shop/shop_view.dart';
import '../features/drawer_features/shop/shop_controller.dart';
import '../features/drawer_features/shop/refill_ai_credits/views/ai_refill_center_view.dart';
import '../features/drawer_features/shop/refill_ai_credits/views/order_summary_view.dart';
import '../features/drawer_features/shop/refill_ai_credits/views/checkout_view.dart';
import '../features/drawer_features/shop/refill_ai_credits/views/purchase_complete.dart';
import '../features/drawer_features/shop/streak_freeze_store/streak_freeze_store_view.dart';
import '../features/drawer_features/shop/streak_freeze_store/order_summary_view.dart';
import '../features/drawer_features/shop/cv_credit_store/cv_credit_store_view.dart';
import '../features/drawer_features/shop/cv_credit_store/cv_credit_order_summary_view.dart';
import '../features/drawer_features/shop/order_history/order_history_view.dart';
import '../features/drawer_features/guide/guide_controller.dart';
import '../features/drawer_features/guide/views/guide_view.dart';
import '../features/drawer_features/guide/views/guide_faq_view.dart';
import '../features/drawer_features/rewards/reward_controller.dart';
import '../features/drawer_features/rewards/views/rewards_view.dart';
import '../features/drawer_features/rewards/views/reward_chest_view.dart';
import '../features/drawer_features/rewards/views/rewards_history_view.dart';
import '../features/drawer_features/rewards/views/reward_details_view.dart';
import '../features/drawer_features/contact/contact_controller.dart';
import '../features/drawer_features/contact/contact_support_view.dart';
import '../features/drawer_features/settings/settings_controller.dart';
import '../features/drawer_features/settings/settings_view.dart';
import '../features/drawer_features/settings/sub_features/views/profile_security_veiw.dart';
import '../features/drawer_features/settings/sub_features/views/profile_photo_view.dart';
import '../features/drawer_features/settings/sub_features/views/change_password_view.dart';
import '../features/drawer_features/settings/sub_features/views/verify_contact_view.dart';
import '../features/drawer_features/settings/sub_features/views/settings_success_view.dart';
import '../features/drawer_features/settings/sub_features/views/delete_account_confirm_view.dart';
import '../features/practice_hub/controllers/practice_hub_controller.dart';
import '../features/practice_hub/views/important_verbs/verb_details.dart';
import '../features/practice_hub/views/survival_italian/survival_italian_view.dart';
import '../features/practice_hub/views/widgets/pdf_viewer.dart';
import '../features/practice_hub/views/job_sentences/job_sentences_view.dart';
import '../features/practice_hub/views/job_sentences/job_details_view.dart';
import '../features/practice_hub/views/daily_challenges/daily_challenges_view.dart';

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
          Get.lazyPut<NotificationsMockService>(
            () => NotificationsMockService(),
          );
        }
        Get.lazyPut<NavbarAndAppbarWrapperController>(
          () => NavbarAndAppbarWrapperController(),
        );
      }),
    ),

    GetPage(
      name: AppRoutes.shop,
      page: () => ShopView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ShopController>(() => ShopController());
      }),
    ),
    GetPage(
      name: AppRoutes.aiRefillCenter,
      page: () => const AiRefillCenterPage(),
    ),
    GetPage(name: AppRoutes.orderSummary, page: () => const OrderSummaryPage()),
    GetPage(name: AppRoutes.checkout, page: () => const CheckoutPage()),
    GetPage(
      name: AppRoutes.purchaseCompleted,
      page: () => const PurchaseCompletedPage(),
    ),
    GetPage(name: AppRoutes.streakFreeze, page: () => const StreakFreezeView()),
    GetPage(
      name: AppRoutes.streakFreezeOrderSummary,
      page: () => const StreakOrderSummaryView(),
    ),

    GetPage(
      name: AppRoutes.cvCreditStore,
      page: () => const CvCreditStoreView(),
    ),

    GetPage(
      name: AppRoutes.cvCreditOrderSummary,
      page: () => const CvCreditOrderSummaryView(),
    ),
    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ShopController>()) {
          Get.lazyPut<ShopController>(() => ShopController());
        }
      }),
    ),

    GetPage(
      name: AppRoutes.guide,
      page: () => const GuideView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<GuideController>(() => GuideController());
      }),
    ),

    GetPage(
      name: AppRoutes.guideFaq,
      page: () => const GuideFaqView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<GuideController>()) {
          Get.lazyPut<GuideController>(() => GuideController());
        }
      }),
    ),

    GetPage(
      name: AppRoutes.rewards,
      page: () => const RewardsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RewardController>(() => RewardController(), fenix: true);
      }),
    ),

    GetPage(
      name: AppRoutes.rewardChest,
      page: () => const RewardChestView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<RewardController>()) {
          Get.lazyPut<RewardController>(() => RewardController(), fenix: true);
        }
      }),
    ),

    GetPage(
      name: AppRoutes.rewardsHistory,
      page: () => const RewardsHistoryView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<RewardController>()) {
          Get.lazyPut<RewardController>(() => RewardController(), fenix: true);
        }
      }),
    ),

    GetPage(
      name: AppRoutes.rewardDetails,
      page: () => const RewardDetailsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<RewardController>()) {
          Get.lazyPut<RewardController>(() => RewardController(), fenix: true);
        }
      }),
    ),

    GetPage(
      name: AppRoutes.contactSupport,
      page: () => const ContactSupportView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ContactController>(() => ContactController(), fenix: true);
      }),
    ),

    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(
          () => SettingsController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.profileSecurity,
      page: () => const ProfileSecurityView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SettingsController>()) {
          Get.lazyPut<SettingsController>(
            () => SettingsController(),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SettingsController>()) {
          Get.lazyPut<SettingsController>(
            () => SettingsController(),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(name: AppRoutes.profilePhoto, page: () => const ProfilePhotoView()),

    GetPage(
      name: AppRoutes.verifyContact,
      page: () => const VerifyContactView(),
    ),

    GetPage(
      name: AppRoutes.profileSuccess,
      page: () => const SettingsSuccessView(),
    ),

    GetPage(
      name: AppRoutes.deleteAccountConfirm,
      page: () => const DeleteAccountConfirmView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SettingsController>()) {
          Get.lazyPut<SettingsController>(
            () => SettingsController(),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.verbDetails,
      page: () => const VerbDetailsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PracticeHubController>()) {
          Get.lazyPut<PracticeHubController>(
            () => PracticeHubController(),
            fenix: true,
          );
        }

        final Object? args = Get.arguments;

        if (args is Map<String, dynamic>) {
          Get.find<PracticeHubController>().setSelectedVerbForDetails(args);
        } else if (args is Map) {
          Get.find<PracticeHubController>().setSelectedVerbForDetails(
            Map<String, dynamic>.from(args),
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.survivalItalian,
      page: () => const SurvivalItalianView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PracticeHubController>()) {
          Get.lazyPut<PracticeHubController>(
            () => PracticeHubController(),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.practiceHubPdfViewer,
      page: () => const PracticeHubPdfViewer(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PracticeHubController>()) {
          Get.lazyPut<PracticeHubController>(
            () => PracticeHubController(),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.jobSentences,
      page: () => const JobSentencesView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PracticeHubController>()) {
          Get.lazyPut<PracticeHubController>(
            () => PracticeHubController(),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.jobDetails,
      page: () => const JobDetailsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PracticeHubController>()) {
          Get.lazyPut<PracticeHubController>(
            () => PracticeHubController(),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.jobPhraseDetails,
      page: () => const JobPhraseDetailsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PracticeHubController>()) {
          Get.lazyPut<PracticeHubController>(
            () => PracticeHubController(),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.dailyChallenges,
      page: () => const DailyChallengesView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PracticeHubController>()) {
          Get.lazyPut<PracticeHubController>(
            () => PracticeHubController(),
            fenix: true,
          );
        }
      }),
    ),
  ];
}
