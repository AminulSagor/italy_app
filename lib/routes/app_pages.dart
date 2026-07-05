import 'package:get/get.dart';

import '../core/bootstrap/app_bootstrap_controller.dart';
import '../core/bootstrap/app_bootstrap_view.dart';
import '../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_view.dart';
import '../features/auth/sub_features/Signup/controllers/signup_controller.dart';
import '../features/auth/sub_features/Signup/views/OTP_view.dart';
import '../features/auth/sub_features/Signup/views/account_created.dart';
import '../features/auth/sub_features/Signup/views/signup_view.dart';
import '../features/auth/sub_features/forgot_password/controllers/forgot_password_controller.dart';
import '../features/auth/sub_features/forgot_password/views/forgot_password_otp_view.dart';
import '../features/auth/sub_features/forgot_password/views/forgot_password_view.dart';
import '../features/auth/sub_features/forgot_password/views/password_changed_view.dart';
import '../features/auth/sub_features/forgot_password/views/reset_password_view.dart';
import '../features/auth/sub_features/login/controllers/login_controller.dart';
import '../features/auth/sub_features/login/views/login_view.dart';
import '../features/courses/controllers/course_detail_controller.dart';
import '../features/courses/controllers/course_certificate_controller.dart';
import '../features/courses/controllers/courses_controller.dart';
import '../features/courses/models/course_models.dart';
import '../features/courses/services/course_catalog_api_service.dart';
import '../features/courses/services/courses_api_service.dart';
import '../features/courses/services/course_certificate_mock_service.dart';
import '../features/courses/sub_features/chapter_detail/controllers/chapter_detail_controller.dart';
import '../features/courses/sub_features/chapter_detail/services/chapter_detail_api_service.dart';
import '../features/courses/sub_features/chapter_detail/views/chapter_detail_view.dart';
import '../features/courses/sub_features/final_exam/controllers/final_exam_controller.dart';
import '../features/courses/sub_features/final_exam/services/final_exam_api_service.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_listening_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_overview_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_result_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_speaking_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_success_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_writing_view.dart';
import '../features/courses/sub_features/pro_checkout/controllers/pro_checkout_controller.dart';
import '../features/courses/sub_features/pro_checkout/services/course_google_play_billing_service.dart';
import '../features/courses/sub_features/pro_checkout/services/pro_checkout_api_service.dart';
import '../features/courses/sub_features/pro_checkout/views/pro_checkout_view.dart';
import '../features/courses/sub_features/pro_checkout/views/pro_order_summary_view.dart';
import '../features/courses/sub_features/pro_checkout/views/pro_purchase_success_view.dart';
import '../features/courses/sub_features/quiz/controllers/quiz_controller.dart';
import '../features/courses/sub_features/quiz/services/quiz_api_service.dart';
import '../features/courses/sub_features/quiz/services/quiz_mock_service.dart';
import '../features/courses/sub_features/quiz/views/quiz_completion_view.dart';
import '../features/courses/sub_features/quiz/views/quiz_review_answers_view.dart';
import '../features/courses/sub_features/quiz/views/quiz_view.dart';
import '../features/courses/sub_features/vocabulary/controllers/vocabulary_controller.dart';
import '../features/courses/sub_features/vocabulary/services/vocabulary_api_service.dart';
import '../features/courses/sub_features/vocabulary/services/vocabulary_mock_service.dart';
import '../features/courses/sub_features/vocabulary/views/vocabulary_view.dart';
import '../features/courses/views/course_detail_view.dart';
import '../features/courses/views/course_certificate_view.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/home/services/home_api_service.dart';
import '../features/home/views/home_view.dart';
import '../features/messages/controllers/messages_controller.dart';
import '../features/messages/services/messages_service.dart';
import '../features/notifications/services/notifications_api_service.dart';
import '../features/practice_hub/services/job_sentences_api_service.dart';
import '../features/practice_hub/sub_features/course_catalog/controllers/course_catalog_controller.dart';
import '../features/practice_hub/sub_features/course_catalog/views/course_catalog_view.dart';
import '../features/service_hub/sub_features/cv_builder/controllers/create_cv_contact_controller.dart';
import '../features/service_hub/sub_features/cv_builder/controllers/create_cv_dynamic_form_controller.dart';
import '../features/service_hub/sub_features/cv_builder/controllers/create_cv_theme_controller.dart';
import '../features/service_hub/sub_features/cv_builder/controllers/create_cv_education_controller.dart';
import '../features/service_hub/sub_features/cv_builder/controllers/create_cv_experience_controller.dart';
import '../features/service_hub/sub_features/cv_builder/controllers/create_cv_summary_controller.dart';
import '../features/service_hub/sub_features/cv_builder/controllers/cv_ready_controller.dart';
import '../features/service_hub/sub_features/cv_builder/controllers/cv_template_controller.dart';
import '../features/service_hub/sub_features/cv_builder/services/cv_builder_api_service.dart';
import '../features/service_hub/sub_features/cv_builder/services/cv_pdf_download_service.dart';
import '../core/services/api_client.dart';
import '../core/controllers/user_session_controller.dart';
import '../core/services/learning_activity_api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/token_service.dart';
import '../core/services/storage_service.dart';
import '../features/messages/services/chat_socket_service.dart';
import '../features/messages/services/presence_service.dart';
import '../features/service_hub/sub_features/cv_builder/views/choose_cv_template_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/create_cv_choice_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/create_cv_contact_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/create_cv_dynamic_form_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/create_cv_theme_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/create_cv_education_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/create_cv_experience_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/create_cv_summary_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/cv_builder_view.dart';
import '../features/service_hub/sub_features/cv_builder/views/cv_ready_view.dart';
import '../features/splash/splash_view.dart';
import '../features/splash/splash_controller.dart';
import '../features/webinar/controllers/webinar_controller.dart';
import '../features/webinar/services/webinar_agora_service.dart';
import '../features/webinar/services/webinar_api_service.dart';
import '../features/webinar/services/webinar_socket_service.dart';
import '../features/webinar/views/webinar_live_view.dart';
import '../features/webinar/views/webinar_view.dart';
import 'app_route_arguments.dart';
import 'app_routes.dart';
import '../features/drawer_features/shop/shop_view.dart';
import '../features/drawer_features/shop/shop_controller.dart';
import '../features/drawer_features/shop/controllers/shop_order_history_controller.dart';
import '../features/drawer_features/shop/services/shop_api_service.dart';
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
import '../features/drawer_features/rewards/services/reward_api_service.dart';
import '../features/drawer_features/rewards/views/rewards_view.dart';
import '../features/drawer_features/rewards/views/reward_chest_view.dart';
import '../features/drawer_features/rewards/views/rewards_history_view.dart';
import '../features/drawer_features/rewards/views/reward_details_view.dart';
import '../features/drawer_features/contact/contact_controller.dart';
import '../features/drawer_features/contact/contact_support_view.dart';
import '../features/drawer_features/settings/settings_controller.dart';
import '../features/drawer_features/settings/settings_view.dart';
import '../features/drawer_features/settings/services/user_settings_service.dart';
import '../features/drawer_features/settings/sub_features/views/profile_security_veiw.dart';
import '../features/drawer_features/settings/sub_features/views/profile_photo_view.dart';
import '../features/drawer_features/settings/sub_features/views/change_password_view.dart';
import '../features/drawer_features/settings/sub_features/views/verify_contact_view.dart';
import '../features/drawer_features/settings/sub_features/views/settings_success_view.dart';
import '../features/drawer_features/settings/sub_features/views/delete_account_confirm_view.dart';
import '../features/drawer_features/settings/sub_features/views/privacy_policy_view.dart';
import '../features/drawer_features/settings/sub_features/views/terms_of_service_view.dart';
import '../features/practice_hub/controllers/practice_hub_controller.dart';
import '../features/practice_hub/controllers/job_sentences_controller.dart';
import '../features/practice_hub/models/job_track_models.dart';
import '../features/practice_hub/services/practice_hub_api_service.dart';
import '../features/practice_hub/views/important_verbs/verb_details.dart';
import '../features/practice_hub/views/survival_italian/survival_italian_view.dart';
import '../features/practice_hub/views/widgets/pdf_viewer.dart';
import '../features/practice_hub/views/job_sentences/job_sentences_view.dart';
import '../features/practice_hub/views/job_sentences/job_details_view.dart';
import '../features/practice_hub/views/daily_challenges/daily_challenges_view.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.bootstrap;

  static T _arguments<T>() => Get.arguments as T;

  static void _ensureRewardDependencies() {
    if (!Get.isRegistered<RewardApiService>()) {
      Get.lazyPut<RewardApiService>(
        () => RewardApiService(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<RewardController>()) {
      Get.lazyPut<RewardController>(
        () => RewardController(apiService: Get.find<RewardApiService>()),
        fenix: true,
      );
    }
  }

  static void _ensureCoursesApiService() {
    if (!Get.isRegistered<CoursesApiService>()) {
      Get.lazyPut<CoursesApiService>(
        () => CoursesApiService(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
  }

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
        if (!Get.isRegistered<HomeApiService>()) {
          Get.lazyPut<HomeApiService>(
            () => HomeApiService(apiClient: Get.find<ApiClient>()),
            fenix: true,
          );
        }
        if (!Get.isRegistered<HomeController>()) {
          Get.lazyPut<HomeController>(
            () => HomeController(homeApiService: Get.find<HomeApiService>()),
            fenix: true,
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.wrapper,
      page: () => const NavbarAndAppbarWrapper(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LearningActivityApiService>()) {
          Get.lazyPut<LearningActivityApiService>(
            () => LearningActivityApiService(apiClient: Get.find<ApiClient>()),
            fenix: true,
          );
        }
        if (!Get.isRegistered<HomeApiService>()) {
          Get.lazyPut<HomeApiService>(
            () => HomeApiService(apiClient: Get.find<ApiClient>()),
            fenix: true,
          );
        }
        if (!Get.isRegistered<HomeController>()) {
          Get.lazyPut<HomeController>(
            () => HomeController(homeApiService: Get.find<HomeApiService>()),
            fenix: true,
          );
        }
        _ensureCoursesApiService();
        if (!Get.isRegistered<CoursesController>()) {
          Get.lazyPut<CoursesController>(
            () => CoursesController(
              coursesApiService: Get.find<CoursesApiService>(),
            ),
          );
        }
        if (!Get.isRegistered<MessagesMockService>()) {
          if (!Get.isRegistered<ChatSocketService>()) {
            Get.lazyPut<ChatSocketService>(
              () => ChatSocketService(tokenService: Get.find<TokenService>()),
            );
          }
          if (!Get.isRegistered<PresenceService>()) {
            Get.put<PresenceService>(PresenceService());
          }

          Get.lazyPut<MessagesMockService>(
            () => MessagesMockService(
              apiClient: Get.find<ApiClient>(),
              tokenService: Get.find<TokenService>(),
              chatSocketService: Get.find<ChatSocketService>(),
            ),
          );
        }
        if (!Get.isRegistered<MessagesController>()) {
          Get.lazyPut<MessagesController>(
            () => MessagesController(
              messagesMockService: Get.find<MessagesMockService>(),
            ),
          );
        }
        if (!Get.isRegistered<NotificationsApiService>()) {
          Get.lazyPut<NotificationsApiService>(
            () => NotificationsApiService(apiClient: Get.find<ApiClient>()),
            fenix: true,
          );
        }
        if (!Get.isRegistered<NavbarAndAppbarWrapperController>()) {
          Get.lazyPut<NavbarAndAppbarWrapperController>(
            () => NavbarAndAppbarWrapperController(),
            fenix: true,
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.courseCatalog,
      page: () => const CourseCatalogView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CourseCatalogApiService>(
          () => CourseCatalogApiService(apiClient: Get.find<ApiClient>()),
        );
        Get.lazyPut<CourseCatalogController>(
          () => CourseCatalogController(
            courseCatalogApiService: Get.find<CourseCatalogApiService>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.courseDetail,
      page: () {
        final CourseDetailRouteArguments args =
            _arguments<CourseDetailRouteArguments>();
        return CourseDetailView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final CourseDetailRouteArguments args =
            _arguments<CourseDetailRouteArguments>();
        _ensureCoursesApiService();
        Get.lazyPut<CourseDetailController>(
          () => CourseDetailController(
            controllerTag: args.controllerTag,
            course: args.course,
            coursesApiService: Get.find<CoursesApiService>(),
          ),
          tag: args.controllerTag,
        );
      }),
    ),

    GetPage(name: AppRoutes.cvBuilder, page: () => const CvBuilderView()),
    GetPage(
      name: AppRoutes.createCvChoice,
      page: () => const CreateCvChoiceView(),
    ),
    GetPage(
      name: AppRoutes.chooseCvTemplate,
      page: () => const ChooseCvTemplateView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CvBuilderApiService>(
          () => CvBuilderApiService(apiClient: Get.find<ApiClient>()),
        );
        Get.lazyPut<CvTemplateController>(
          () => CvTemplateController(
            cvBuilderApiService: Get.find<CvBuilderApiService>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.createCvContact,
      page: () => const CreateCvContactView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateCvContactController>(
          () => CreateCvContactController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.createCvDynamicForm,
      page: () => const CreateCvDynamicFormView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CvBuilderApiService>()) {
          Get.lazyPut<CvBuilderApiService>(
            () => CvBuilderApiService(apiClient: Get.find<ApiClient>()),
          );
        }
        Get.lazyPut<CreateCvDynamicFormController>(
          () => CreateCvDynamicFormController(
            cvBuilderApiService: Get.find<CvBuilderApiService>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.createCvTheme,
      page: () => const CreateCvThemeView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CvBuilderApiService>()) {
          Get.lazyPut<CvBuilderApiService>(
            () => CvBuilderApiService(apiClient: Get.find<ApiClient>()),
          );
        }
        Get.lazyPut<CreateCvThemeController>(
          () => CreateCvThemeController(
            cvBuilderApiService: Get.find<CvBuilderApiService>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.chapterDetail,
      page: () {
        final Object rawArgs = Get.arguments as Object;
        final String controllerTag = rawArgs is HomeChapterRouteArguments
            ? 'home-chapter-${rawArgs.lessonId}'
            : (rawArgs as ChapterDetailRouteArguments).controllerTag;
        return ChapterDetailView(controllerTag: controllerTag);
      },
      binding: BindingsBuilder(() {
        final Object rawArgs = Get.arguments as Object;
        final HomeChapterRouteArguments? homeArgs =
            rawArgs is HomeChapterRouteArguments ? rawArgs : null;
        final ChapterDetailRouteArguments? existingArgs =
            rawArgs is ChapterDetailRouteArguments ? rawArgs : null;
        final String controllerTag = homeArgs != null
            ? 'home-chapter-${homeArgs.lessonId}'
            : existingArgs!.controllerTag;
        final CourseChapterModel chapter = homeArgs == null
            ? existingArgs!.chapter
            : CourseChapterModel(
                id: homeArgs.lessonId,
                courseId: homeArgs.courseId,
                chapterId: homeArgs.chapterId,
                title: homeArgs.title,
                subtitle: homeArgs.subtitle,
                progress: homeArgs.progress,
                state: CourseChapterState.current,
                statusLabel: 'CURRENT',
              );
        Get.lazyPut<ChapterDetailApiService>(
          () => ChapterDetailApiService(apiClient: Get.find<ApiClient>()),
          tag: controllerTag,
        );
        Get.lazyPut<ChapterDetailController>(
          () => ChapterDetailController(
            chapter: chapter,
            chapterDetailApiService: Get.find<ChapterDetailApiService>(
              tag: controllerTag,
            ),
          ),
          tag: controllerTag,
        );
      }),
    ),

    GetPage(
      name: AppRoutes.vocabulary,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return VocabularyView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final Object routeArgs = Get.arguments as Object;
        final VocabularyRouteArguments args =
            routeArgs is VocabularyRouteArguments
            ? routeArgs
            : VocabularyRouteArguments(
                controllerTag:
                    (routeArgs as ControllerTagRouteArguments).controllerTag,
              );
        Get.lazyPut<VocabularyMockService>(
          () => VocabularyMockService(),
          tag: args.controllerTag,
        );
        Get.lazyPut<VocabularyApiService>(
          () => VocabularyApiService(apiClient: Get.find<ApiClient>()),
          tag: args.controllerTag,
        );
        Get.lazyPut<VocabularyController>(
          () => VocabularyController(
            lessonId: args.lessonId,
            vocabularyMockService: Get.find<VocabularyMockService>(
              tag: args.controllerTag,
            ),
            vocabularyApiService: Get.find<VocabularyApiService>(
              tag: args.controllerTag,
            ),
            userSessionController: Get.find<UserSessionController>(),
          ),
          tag: args.controllerTag,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.createCvExperience,
      page: () => const CreateCvExperienceView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateCvExperienceController>(
          () => CreateCvExperienceController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.quiz,
      page: () {
        final Object args = Get.arguments as Object;
        final String controllerTag = args is QuizRouteArguments
            ? args.controllerTag
            : (args as ControllerTagRouteArguments).controllerTag;
        return QuizView(controllerTag: controllerTag);
      },
      binding: BindingsBuilder(() {
        final Object routeArgs = Get.arguments as Object;
        final QuizRouteArguments args = routeArgs is QuizRouteArguments
            ? routeArgs
            : QuizRouteArguments(
                controllerTag:
                    (routeArgs as ControllerTagRouteArguments).controllerTag,
              );
        Get.lazyPut<QuizMockService>(
          () => QuizMockService(),
          tag: args.controllerTag,
        );
        Get.lazyPut<QuizApiService>(
          () => QuizApiService(apiClient: Get.find<ApiClient>()),
          tag: args.controllerTag,
        );
        Get.lazyPut<QuizController>(
          () => QuizController(
            quizMockService: Get.find<QuizMockService>(tag: args.controllerTag),
            quizApiService: Get.find<QuizApiService>(tag: args.controllerTag),
            lessonId: args.lessonId,
            courseId: args.courseId,
            chapterTitle: args.chapterTitle,
            isExamMode: args.isExamMode,
            questionCount: args.questionCount,
            initialQuestions: args.initialQuestions,
            externalAnswerHandler: args.externalAnswerHandler,
          ),
          tag: args.controllerTag,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.createCvEducation,
      page: () => const CreateCvEducationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateCvEducationController>(
          () => CreateCvEducationController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.quizCompletion,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return QuizCompletionView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.quizReviewAnswers,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return QuizReviewAnswersView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.proOrderSummary,
      page: () {
        final ProOrderSummaryRouteArguments args =
            _arguments<ProOrderSummaryRouteArguments>();
        return ProOrderSummaryView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final ProOrderSummaryRouteArguments args =
            _arguments<ProOrderSummaryRouteArguments>();
        Get.lazyPut<ProCheckoutApiService>(
          () => ProCheckoutApiService(apiClient: Get.find<ApiClient>()),
          tag: args.controllerTag,
        );
        Get.lazyPut<CourseGooglePlayBillingService>(
          () => CourseGooglePlayBillingService(
            storageService: Get.find<StorageService>(),
          ),
          tag: args.controllerTag,
        );
        Get.lazyPut<ProCheckoutController>(
          () => ProCheckoutController(
            proCheckoutApiService: Get.find<ProCheckoutApiService>(
              tag: args.controllerTag,
            ),
            billingService: Get.find<CourseGooglePlayBillingService>(
              tag: args.controllerTag,
            ),
            courseId: args.courseId,
            courseName: args.courseName,
            lessonCount: args.lessonCount,
            onPurchaseCompleted: Get.find<CourseDetailController>(
              tag: args.courseDetailControllerTag,
            ).refreshAfterPurchase,
          ),
          tag: args.controllerTag,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.createCvSummary,
      page: () => const CreateCvSummaryView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CvBuilderApiService>()) {
          Get.lazyPut<CvBuilderApiService>(
            () => CvBuilderApiService(apiClient: Get.find<ApiClient>()),
          );
        }
        Get.lazyPut<CreateCvSummaryController>(
          () => CreateCvSummaryController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.proCheckout,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return ProCheckoutView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.proPurchaseSuccess,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return ProPurchaseSuccessView(controllerTag: args.controllerTag);
      },
    ),

    GetPage(
      name: AppRoutes.courseCertificate,
      page: () {
        final CourseCertificateRouteArguments args =
            _arguments<CourseCertificateRouteArguments>();
        return CourseCertificateView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final CourseCertificateRouteArguments args =
            _arguments<CourseCertificateRouteArguments>();
        Get.lazyPut<CourseCertificateMockService>(
          () => CourseCertificateMockService(),
          tag: args.controllerTag,
        );
        Get.lazyPut<CourseCertificateController>(
          () => CourseCertificateController(
            certificateMockService: Get.find<CourseCertificateMockService>(
              tag: args.controllerTag,
            ),
          ),
          tag: args.controllerTag,
        );
      }),
    ),

    GetPage(
      name: AppRoutes.finalExamOverview,
      page: () {
        final FinalExamRouteArguments args =
            _arguments<FinalExamRouteArguments>();
        return FinalExamOverviewView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final FinalExamRouteArguments args =
            _arguments<FinalExamRouteArguments>();
        Get.lazyPut<FinalExamApiService>(
          () => FinalExamApiService(apiClient: Get.find<ApiClient>()),
          tag: args.controllerTag,
        );
        Get.lazyPut<FinalExamController>(
          () => FinalExamController(
            controllerTag: args.controllerTag,
            courseId: args.courseId,
            finalExamApiService: Get.find<FinalExamApiService>(
              tag: args.controllerTag,
            ),
          ),
          tag: args.controllerTag,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.finalExamListening,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return FinalExamListeningView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.finalExamWriting,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return FinalExamWritingView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.finalExamSpeaking,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return FinalExamSpeakingView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.finalExamSuccess,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return FinalExamSuccessView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.finalExamResult,
      page: () {
        final ControllerTagRouteArguments args =
            _arguments<ControllerTagRouteArguments>();
        return FinalExamResultView(controllerTag: args.controllerTag);
      },
    ),

    GetPage(
      name: AppRoutes.webinar,
      page: () => const WebinarView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<WebinarApiService>()) {
          Get.lazyPut<WebinarApiService>(
            () => WebinarApiService(apiClient: Get.find<ApiClient>()),
          );
        }
        if (!Get.isRegistered<WebinarAgoraService>()) {
          Get.lazyPut<WebinarAgoraService>(() => WebinarAgoraService());
        }
        if (!Get.isRegistered<WebinarSocketService>()) {
          Get.lazyPut<WebinarSocketService>(() => WebinarSocketService());
        }
        if (!Get.isRegistered<WebinarController>()) {
          Get.lazyPut<WebinarController>(
            () => WebinarController(
              webinarApiService: Get.find<WebinarApiService>(),
              webinarAgoraService: Get.find<WebinarAgoraService>(),
              webinarSocketService: Get.find<WebinarSocketService>(),
            ),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.shop,
      page: () => const ShopView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ShopApiService>()) {
          Get.lazyPut<ShopApiService>(
            () => ShopApiService(apiClient: Get.find<ApiClient>()),
            fenix: true,
          );
        }
        Get.lazyPut<ShopController>(
          () => ShopController(apiService: Get.find<ShopApiService>()),
        );
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
        if (!Get.isRegistered<ShopApiService>()) {
          Get.lazyPut<ShopApiService>(
            () => ShopApiService(apiClient: Get.find<ApiClient>()),
            fenix: true,
          );
        }
        Get.lazyPut<ShopOrderHistoryController>(
          () => ShopOrderHistoryController(
            apiService: Get.find<ShopApiService>(),
          ),
        );
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
      binding: BindingsBuilder(_ensureRewardDependencies),
    ),

    GetPage(
      name: AppRoutes.rewardChest,
      page: () => const RewardChestView(),
      binding: BindingsBuilder(_ensureRewardDependencies),
    ),

    GetPage(
      name: AppRoutes.rewardsHistory,
      page: () => const RewardsHistoryView(),
      binding: BindingsBuilder(_ensureRewardDependencies),
    ),

    GetPage(
      name: AppRoutes.rewardDetails,
      page: () => const RewardDetailsView(),
      binding: BindingsBuilder(_ensureRewardDependencies),
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
          () => SettingsController(
            userSettingsService: Get.find<UserSettingsService>(),
            authService: Get.find<AuthService>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: AppRoutes.termsOfService,
      page: () => const TermsOfServiceView(),
    ),
    GetPage(
      name: AppRoutes.profileSecurity,
      page: () => const ProfileSecurityView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SettingsController>()) {
          Get.lazyPut<SettingsController>(
            () => SettingsController(
              userSettingsService: Get.find<UserSettingsService>(),
              authService: Get.find<AuthService>(),
            ),
            fenix: true,
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.webinarLive,
      page: () => const WebinarLiveView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<WebinarApiService>()) {
          Get.lazyPut<WebinarApiService>(
            () => WebinarApiService(apiClient: Get.find<ApiClient>()),
          );
        }
        if (!Get.isRegistered<WebinarAgoraService>()) {
          Get.lazyPut<WebinarAgoraService>(() => WebinarAgoraService());
        }
        if (!Get.isRegistered<WebinarSocketService>()) {
          Get.lazyPut<WebinarSocketService>(() => WebinarSocketService());
        }
        if (!Get.isRegistered<WebinarController>()) {
          Get.lazyPut<WebinarController>(
            () => WebinarController(
              webinarApiService: Get.find<WebinarApiService>(),
              webinarAgoraService: Get.find<WebinarAgoraService>(),
              webinarSocketService: Get.find<WebinarSocketService>(),
            ),
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
            () => SettingsController(
              userSettingsService: Get.find<UserSettingsService>(),
              authService: Get.find<AuthService>(),
            ),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.profilePhoto,
      page: () => const ProfilePhotoView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SettingsController>()) {
          Get.lazyPut<SettingsController>(
            () => SettingsController(
              userSettingsService: Get.find<UserSettingsService>(),
              authService: Get.find<AuthService>(),
            ),
            fenix: true,
          );
        }
      }),
    ),

    GetPage(
      name: AppRoutes.verifyContact,
      page: () => const VerifyContactView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SettingsController>()) {
          Get.lazyPut<SettingsController>(
            () => SettingsController(
              userSettingsService: Get.find<UserSettingsService>(),
              authService: Get.find<AuthService>(),
            ),
            fenix: true,
          );
        }
      }),
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
            () => SettingsController(
              userSettingsService: Get.find<UserSettingsService>(),
              authService: Get.find<AuthService>(),
            ),
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
            () => PracticeHubController(
              coursesApiService: Get.find<CoursesApiService>(),
              practiceHubApiService: Get.find<PracticeHubApiService>(),
            ),
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
            () => PracticeHubController(
              coursesApiService: Get.find<CoursesApiService>(),
              practiceHubApiService: Get.find<PracticeHubApiService>(),
            ),
            fenix: true,
          );
        }
        Get.find<PracticeHubController>().loadSurvivalItalian(showError: false);
      }),
    ),

    GetPage(
      name: AppRoutes.practiceHubPdfViewer,
      page: () => const PracticeHubPdfViewer(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PracticeHubController>()) {
          Get.lazyPut<PracticeHubController>(
            () => PracticeHubController(
              coursesApiService: Get.find<CoursesApiService>(),
              practiceHubApiService: Get.find<PracticeHubApiService>(),
            ),
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
            () => PracticeHubController(
              coursesApiService: Get.find<CoursesApiService>(),
              practiceHubApiService: Get.find<PracticeHubApiService>(),
            ),
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
            () => PracticeHubController(
              coursesApiService: Get.find<CoursesApiService>(),
              practiceHubApiService: Get.find<PracticeHubApiService>(),
            ),
            fenix: true,
          );
        }
        if (!Get.isRegistered<JobSentencesController>()) {
          Get.lazyPut<JobSentencesController>(
            () => JobSentencesController(
              apiService: Get.find<JobSentencesApiService>(),
            ),
            fenix: true,
          );
        }
        final Object? rawArgs = Get.arguments;
        if (rawArgs is HomeJobTrackRouteArguments) {
          Get.find<JobSentencesController>().prepareCareerTrack(
            JobCareerTrackModel(
              id: rawArgs.id,
              title: rawArgs.title,
              subtitleBn: rawArgs.subtitle,
              description: '',
              iconKey: rawArgs.iconKey,
              cardColor: rawArgs.cardColor,
              sortOrder: 0,
              moduleCount: rawArgs.moduleCount,
              sentenceCount: rawArgs.sentenceCount,
              learnedSentenceCount: rawArgs.learnedSentenceCount,
            ),
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
            () => PracticeHubController(
              coursesApiService: Get.find<CoursesApiService>(),
              practiceHubApiService: Get.find<PracticeHubApiService>(),
            ),
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
            () => PracticeHubController(
              coursesApiService: Get.find<CoursesApiService>(),
              practiceHubApiService: Get.find<PracticeHubApiService>(),
            ),
            fenix: true,
          );
        }
        Get.find<PracticeHubController>().loadDailyChallenges(showError: false);
      }),
    ),
    GetPage(
      name: AppRoutes.cvReady,
      page: () => const CvReadyView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CvPdfDownloadService>()) {
          Get.lazyPut<CvPdfDownloadService>(() => CvPdfDownloadService());
        }
        Get.lazyPut<CvReadyController>(
          () => CvReadyController(
            cvPdfDownloadService: Get.find<CvPdfDownloadService>(),
          ),
        );
      }),
    ),
  ];
}
