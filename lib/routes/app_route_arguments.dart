import 'package:image_picker/image_picker.dart';

import '../features/service_hub/sub_features/cv_builder/models/cv_builder_models.dart';
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

class ProOrderSummaryRouteArguments {
  final String controllerTag;
  final String courseDetailControllerTag;

  const ProOrderSummaryRouteArguments({
    required this.controllerTag,
    required this.courseDetailControllerTag,
  });
}


class CourseCertificateRouteArguments {
  final String controllerTag;

  const CourseCertificateRouteArguments({required this.controllerTag});
}


class CvTemplateFormRouteArguments {
  final CvTemplateModel template;
  final String themeColor;

  const CvTemplateFormRouteArguments({
    required this.template,
    required this.themeColor,
  });
}


class CvThemeRouteArguments {
  final CvTemplateModel template;
  final String documentTitle;
  final String primaryColor;
  final String accentColor;
  final Map<String, dynamic> formData;
  final Map<String, XFile> pendingPhotoFiles;

  const CvThemeRouteArguments({
    required this.template,
    required this.documentTitle,
    required this.primaryColor,
    required this.accentColor,
    required this.formData,
    this.pendingPhotoFiles = const <String, XFile>{},
  });
}


class CvReadyRouteArguments {
  final CvDocumentModel document;
  final CvTemplateModel template;

  const CvReadyRouteArguments({
    required this.document,
    required this.template,
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
