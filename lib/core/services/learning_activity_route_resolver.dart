import '../../routes/app_routes.dart';
import '../models/learning_activity_models.dart';

class LearningActivityRouteResolver {
  const LearningActivityRouteResolver();

  String normalize(String? routeName) {
    final String value = routeName?.trim() ?? '';
    if (value.isEmpty) return '';
    return value.split('?').first.split('#').first;
  }

  LearningActivityKind? forShellTab(int index) {
    switch (index) {
      case 1:
        return LearningActivityKind.practiceHub;
      case 2:
        return LearningActivityKind.aiTutor;
      default:
        return null;
    }
  }

  LearningActivityKind? forRoute(String route) {
    if (route.startsWith(AppRoutes.chapterDetail)) {
      if (route.contains('/quiz')) return LearningActivityKind.quiz;
      if (route.contains('/vocabulary')) {
        return LearningActivityKind.vocabulary;
      }
      return LearningActivityKind.lesson;
    }
    if (route.startsWith(AppRoutes.finalExamOverview)) {
      return LearningActivityKind.exam;
    }
    if (route == AppRoutes.courseDetail) return LearningActivityKind.course;
    if (route == AppRoutes.practiceHubPdfViewer) {
      return LearningActivityKind.pdf;
    }
    if (route.startsWith('/practice-hub/job')) {
      return LearningActivityKind.jobSentences;
    }
    if (route == AppRoutes.survivalItalian) {
      return LearningActivityKind.survivalItalian;
    }
    if (route == AppRoutes.verbDetails) {
      return LearningActivityKind.importantVerbs;
    }
    if (route == AppRoutes.dailyChallenges) {
      return LearningActivityKind.practiceHub;
    }
    if (route.startsWith(AppRoutes.webinar)) {
      return LearningActivityKind.webinar;
    }
    return null;
  }

  bool isKnownNonLearningRoute(String route) {
    const List<String> nonLearningPrefixes = <String>[
      '/login',
      '/signup',
      '/account-created',
      '/forgot-password',
      '/reset-password',
      '/splash',
      '/bootstrap',
      '/home',
      '/notifications',
      '/shop',
      '/streak-freeze',
      '/cv',
      '/create-cv',
      '/purchase-completed',
      '/guide',
      '/rewards',
      '/contact-support',
      '/settings',
      '/courses/pro',
      '/courses/certificate',
    ];
    return nonLearningPrefixes.any(route.startsWith);
  }
}
