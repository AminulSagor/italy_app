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
import '../features/courses/services/courses_mock_service.dart';
import '../features/courses/services/course_certificate_mock_service.dart';
import '../features/courses/sub_features/chapter_detail/controllers/chapter_detail_controller.dart';
import '../features/courses/sub_features/chapter_detail/services/chapter_detail_mock_service.dart';
import '../features/courses/sub_features/chapter_detail/views/chapter_detail_view.dart';
import '../features/courses/sub_features/final_exam/controllers/final_exam_controller.dart';
import '../features/courses/sub_features/final_exam/services/final_exam_mock_service.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_listening_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_overview_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_result_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_speaking_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_success_view.dart';
import '../features/courses/sub_features/final_exam/views/final_exam_writing_view.dart';
import '../features/courses/sub_features/pro_checkout/controllers/pro_checkout_controller.dart';
import '../features/courses/sub_features/pro_checkout/services/pro_checkout_mock_service.dart';
import '../features/courses/sub_features/pro_checkout/views/pro_checkout_view.dart';
import '../features/courses/sub_features/pro_checkout/views/pro_order_summary_view.dart';
import '../features/courses/sub_features/pro_checkout/views/pro_purchase_success_view.dart';
import '../features/courses/sub_features/quiz/controllers/quiz_controller.dart';
import '../features/courses/sub_features/quiz/services/quiz_mock_service.dart';
import '../features/courses/sub_features/quiz/views/quiz_completion_view.dart';
import '../features/courses/sub_features/quiz/views/quiz_review_answers_view.dart';
import '../features/courses/sub_features/quiz/views/quiz_view.dart';
import '../features/courses/sub_features/vocabulary/controllers/vocabulary_controller.dart';
import '../features/courses/sub_features/vocabulary/services/vocabulary_mock_service.dart';
import '../features/courses/sub_features/vocabulary/views/vocabulary_view.dart';
import '../features/courses/views/course_detail_view.dart';
import '../features/courses/views/course_certificate_view.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/home/services/home_mock_service.dart';
import '../features/home/views/home_view.dart';
import '../features/messages/controllers/messages_controller.dart';
import '../features/messages/services/messages_mock_service.dart';
import '../features/notifications/services/notifications_mock_service.dart';
import '../features/splash/splash_controller.dart';
import '../features/splash/splash_view.dart';
import '../features/webinar/controllers/webinar_controller.dart';
import '../features/webinar/services/webinar_mock_service.dart';
import '../features/webinar/views/webinar_live_view.dart';
import '../features/webinar/views/webinar_view.dart';
import 'app_route_arguments.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.bootstrap;

  static T _arguments<T>() => Get.arguments as T;

  static void _ensureCoursesMockService() {
    if (!Get.isRegistered<CoursesMockService>()) {
      Get.lazyPut<CoursesMockService>(() => CoursesMockService());
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
        _ensureCoursesMockService();
        if (!Get.isRegistered<CoursesController>()) {
          Get.lazyPut<CoursesController>(
            () => CoursesController(
              coursesMockService: Get.find<CoursesMockService>(),
            ),
          );
        }
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
    GetPage(
      name: AppRoutes.courseDetail,
      page: () {
        final CourseDetailRouteArguments args = _arguments<CourseDetailRouteArguments>();
        return CourseDetailView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final CourseDetailRouteArguments args = _arguments<CourseDetailRouteArguments>();
        _ensureCoursesMockService();
        Get.lazyPut<CourseDetailController>(
          () => CourseDetailController(
            controllerTag: args.controllerTag,
            course: args.course,
            coursesMockService: Get.find<CoursesMockService>(),
          ),
          tag: args.controllerTag,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.chapterDetail,
      page: () {
        final ChapterDetailRouteArguments args = _arguments<ChapterDetailRouteArguments>();
        return ChapterDetailView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final ChapterDetailRouteArguments args = _arguments<ChapterDetailRouteArguments>();
        Get.lazyPut<ChapterDetailMockService>(() => ChapterDetailMockService(), tag: args.controllerTag);
        Get.lazyPut<ChapterDetailController>(
          () => ChapterDetailController(
            chapter: args.chapter,
            chapterDetailMockService: Get.find<ChapterDetailMockService>(tag: args.controllerTag),
          ),
          tag: args.controllerTag,
        );
      }),
    ),

    GetPage(
      name: AppRoutes.vocabulary,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return VocabularyView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        Get.lazyPut<VocabularyMockService>(() => VocabularyMockService(), tag: args.controllerTag);
        Get.lazyPut<VocabularyController>(
          () => VocabularyController(
            vocabularyMockService: Get.find<VocabularyMockService>(tag: args.controllerTag),
          ),
          tag: args.controllerTag,
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
                controllerTag: (routeArgs as ControllerTagRouteArguments).controllerTag,
              );
        Get.lazyPut<QuizMockService>(() => QuizMockService(), tag: args.controllerTag);
        Get.lazyPut<QuizController>(
          () => QuizController(
            quizMockService: Get.find<QuizMockService>(tag: args.controllerTag),
            isExamMode: args.isExamMode,
            questionCount: args.questionCount,
          ),
          tag: args.controllerTag,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.quizCompletion,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return QuizCompletionView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.quizReviewAnswers,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return QuizReviewAnswersView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.proOrderSummary,
      page: () {
        final ProOrderSummaryRouteArguments args = _arguments<ProOrderSummaryRouteArguments>();
        return ProOrderSummaryView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final ProOrderSummaryRouteArguments args = _arguments<ProOrderSummaryRouteArguments>();
        Get.lazyPut<ProCheckoutMockService>(() => ProCheckoutMockService(), tag: args.controllerTag);
        Get.lazyPut<ProCheckoutController>(
          () => ProCheckoutController(
            proCheckoutMockService: Get.find<ProCheckoutMockService>(tag: args.controllerTag),
            onPurchaseCompleted: Get.find<CourseDetailController>(
              tag: args.courseDetailControllerTag,
            ).enablePro,
          ),
          tag: args.controllerTag,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.proCheckout,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return ProCheckoutView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.proPurchaseSuccess,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return ProPurchaseSuccessView(controllerTag: args.controllerTag);
      },
    ),


    GetPage(
      name: AppRoutes.courseCertificate,
      page: () {
        final CourseCertificateRouteArguments args = _arguments<CourseCertificateRouteArguments>();
        return CourseCertificateView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final CourseCertificateRouteArguments args = _arguments<CourseCertificateRouteArguments>();
        Get.lazyPut<CourseCertificateMockService>(
          () => CourseCertificateMockService(),
          tag: args.controllerTag,
        );
        Get.lazyPut<CourseCertificateController>(
          () => CourseCertificateController(
            certificateMockService: Get.find<CourseCertificateMockService>(tag: args.controllerTag),
          ),
          tag: args.controllerTag,
        );
      }),
    ),

    GetPage(
      name: AppRoutes.finalExamOverview,
      page: () {
        final FinalExamRouteArguments args = _arguments<FinalExamRouteArguments>();
        return FinalExamOverviewView(controllerTag: args.controllerTag);
      },
      binding: BindingsBuilder(() {
        final FinalExamRouteArguments args = _arguments<FinalExamRouteArguments>();
        Get.lazyPut<FinalExamMockService>(() => FinalExamMockService(), tag: args.controllerTag);
        Get.lazyPut<FinalExamController>(
          () => FinalExamController(
            controllerTag: args.controllerTag,
            finalExamMockService: Get.find<FinalExamMockService>(tag: args.controllerTag),
          ),
          tag: args.controllerTag,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.finalExamListening,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return FinalExamListeningView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.finalExamWriting,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return FinalExamWritingView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.finalExamSpeaking,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return FinalExamSpeakingView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.finalExamSuccess,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return FinalExamSuccessView(controllerTag: args.controllerTag);
      },
    ),
    GetPage(
      name: AppRoutes.finalExamResult,
      page: () {
        final ControllerTagRouteArguments args = _arguments<ControllerTagRouteArguments>();
        return FinalExamResultView(controllerTag: args.controllerTag);
      },
    ),

    GetPage(
      name: AppRoutes.webinar,
      page: () => const WebinarView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<WebinarMockService>()) {
          Get.lazyPut<WebinarMockService>(() => WebinarMockService());
        }
        if (!Get.isRegistered<WebinarController>()) {
          Get.lazyPut<WebinarController>(
            () => WebinarController(
              webinarMockService: Get.find<WebinarMockService>(),
            ),
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.webinarLive,
      page: () => const WebinarLiveView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<WebinarMockService>()) {
          Get.lazyPut<WebinarMockService>(() => WebinarMockService());
        }
        if (!Get.isRegistered<WebinarController>()) {
          Get.lazyPut<WebinarController>(
            () => WebinarController(
              webinarMockService: Get.find<WebinarMockService>(),
            ),
          );
        }
      }),
    ),
  ];
}
