import '../features/service_hub/sub_features/cv_builder/models/cv_builder_models.dart';
import '../features/courses/models/course_models.dart';

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

class QuizRouteArguments {
  final String controllerTag;
  final bool isExamMode;
  final int questionCount;

  const QuizRouteArguments({
    required this.controllerTag,
    this.isExamMode = false,
    this.questionCount = 15,
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

  const CvThemeRouteArguments({
    required this.template,
    required this.documentTitle,
    required this.primaryColor,
    required this.accentColor,
    required this.formData,
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
