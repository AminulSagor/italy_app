import 'package:get/get.dart';
import '../models/final_exam_models.dart';

/// Legacy fallback kept for older routes and tests.
///
/// The production final-exam flow uses [FinalExamApiService].
class FinalExamMockService {
  Future<FinalExamOverviewModel> fetchOverview() async {
    return FinalExamOverviewModel(
      title: 'gen_final_exam'.tr,
      heroTitle: 'Ready to Graduate?',
      heroSubtitle: 'gen_complete_the_final_exam_to_ear'.tr,
      components: <FinalExamComponentModel>[],
      noteBangla: '',
      noteEnglish: '',
      canStart: false,
      startMessage: 'Final exam data is unavailable.',
    );
  }

  Future<FinalExamListeningModel> fetchListeningTask() async {
    return FinalExamListeningModel(
      sectionId: '',
      questionId: '',
      title: 'gen_listening'.tr,
      clipTitle: '',
      questionTag: '',
      question: '',
      options: <String>[],
      optionIds: <String>[],
      tip: '',
      audioUrl: '',
      playbackLocked: false,
    );
  }

  Future<FinalExamWritingModel> fetchWritingTask() async {
    return FinalExamWritingModel(
      sectionId: '',
      questionId: '',
      title: 'gen_writing'.tr,
      taskTitle: '',
      instruction: '',
      banglaInstruction: '',
      minWords: 0,
      maxWords: 0,
    );
  }

  Future<FinalExamSpeakingModel> fetchSpeakingTask() async {
    return FinalExamSpeakingModel(
      sectionId: '',
      questionId: '',
      title: 'gen_speaking'.tr,
      taskTitle: '',
      instruction: '',
      banglaInstruction: '',
      tip: '',
      maxDurationSeconds: 60,
      unlimitedRerecords: true,
    );
  }

  Future<String> submitExam() async => '';

  Future<FinalExamResultModel> fetchResult() async {
    return FinalExamResultModel(
      markPercent: 0,
      title: 'gen_final_exam_result'.tr,
      subtitle: 'gen_result_unavailable'.tr,
      xpAwarded: 0,
      teacherComment: '',
      teacherCommentBangla: '',
      verdict: '',
      stats: <FinalExamResultStatModel>[],
    );
  }
}
