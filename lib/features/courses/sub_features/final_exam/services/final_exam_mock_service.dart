import '../models/final_exam_models.dart';

/// Legacy fallback kept for older routes and tests.
///
/// The production final-exam flow uses [FinalExamApiService].
class FinalExamMockService {
  Future<FinalExamOverviewModel> fetchOverview() async {
    return const FinalExamOverviewModel(
      title: 'Final Exam',
      heroTitle: 'Ready to Graduate?',
      heroSubtitle: 'Complete the final exam to earn your certificate.',
      components: <FinalExamComponentModel>[],
      noteBangla: '',
      noteEnglish: '',
      canStart: false,
      startMessage: 'Final exam data is unavailable.',
    );
  }

  Future<FinalExamListeningModel> fetchListeningTask() async {
    return const FinalExamListeningModel(
      sectionId: '',
      questionId: '',
      title: 'Listening',
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
    return const FinalExamWritingModel(
      sectionId: '',
      questionId: '',
      title: 'Writing',
      taskTitle: '',
      instruction: '',
      banglaInstruction: '',
      minWords: 0,
      maxWords: 0,
    );
  }

  Future<FinalExamSpeakingModel> fetchSpeakingTask() async {
    return const FinalExamSpeakingModel(
      sectionId: '',
      questionId: '',
      title: 'Speaking',
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
    return const FinalExamResultModel(
      markPercent: 0,
      title: 'Final Exam Result',
      subtitle: 'Result unavailable.',
      xpAwarded: 0,
      teacherComment: '',
      teacherCommentBangla: '',
      verdict: '',
      stats: <FinalExamResultStatModel>[],
    );
  }
}
