import '../features/courses/models/course_models.dart';
import '../features/courses/sub_features/quiz/models/quiz_models.dart';

class CourseDetailRouteArguments {
  final CourseCardModel course;
  final String controllerTag;

  const CourseDetailRouteArguments({
    required this.course,
    required this.controllerTag,
  });
}

class ChapterDetailRouteArguments {
  final CourseChapterModel chapter;
  final String controllerTag;

  const ChapterDetailRouteArguments({
    required this.chapter,
    required this.controllerTag,
  });
}

class ControllerTagRouteArguments {
  final String controllerTag;

  const ControllerTagRouteArguments({required this.controllerTag});
}

class VocabularyRouteArguments extends ControllerTagRouteArguments {
  final String? lessonId;

  const VocabularyRouteArguments({
    required super.controllerTag,
    this.lessonId,
  });
}

class QuizRouteArguments {
  final String controllerTag;
  final bool isExamMode;
  final int questionCount;
  final String? lessonId;
  final String? courseId;
  final String? chapterTitle;
  final List<QuizQuestionModel> initialQuestions;
  final QuizExternalAnswerHandler? externalAnswerHandler;

  const QuizRouteArguments({
    required this.controllerTag,
    this.isExamMode = false,
    this.questionCount = 15,
    this.lessonId,
    this.courseId,
    this.chapterTitle,
    this.initialQuestions = const <QuizQuestionModel>[],
    this.externalAnswerHandler,
  });
}


class FinalExamRouteArguments {
  final String controllerTag;
  final String courseId;

  const FinalExamRouteArguments({
    required this.controllerTag,
    required this.courseId,
  });
}

class FinalExamResultRouteArguments {
  final String controllerTag;
  final String courseId;
  final String attemptId;

  const FinalExamResultRouteArguments({
    required this.controllerTag,
    required this.courseId,
    required this.attemptId,
  });
}

class ProOrderSummaryRouteArguments {
  final String controllerTag;
  final String courseDetailControllerTag;
  final String courseId;
  final String courseName;
  final int lessonCount;

  const ProOrderSummaryRouteArguments({
    required this.controllerTag,
    required this.courseDetailControllerTag,
    required this.courseId,
    required this.courseName,
    required this.lessonCount,
  });
}


class CourseCertificateRouteArguments {
  final String controllerTag;
  final String attemptId;

  const CourseCertificateRouteArguments({
    required this.controllerTag,
    required this.attemptId,
  });
}








class HomeChapterRouteArguments {
  const HomeChapterRouteArguments({
    required this.lessonId,
    required this.courseId,
    required this.chapterId,
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  final String lessonId;
  final String courseId;
  final String chapterId;
  final String title;
  final String subtitle;
  final double progress;
}

class HomeJobTrackRouteArguments {
  const HomeJobTrackRouteArguments({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.cardColor,
    required this.moduleCount,
    required this.sentenceCount,
    required this.learnedSentenceCount,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final String cardColor;
  final int moduleCount;
  final int sentenceCount;
  final int learnedSentenceCount;
}
