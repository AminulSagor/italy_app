import '../models/final_exam_models.dart';

class FinalExamMockService {
  Future<FinalExamOverviewModel> fetchOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return FinalExamOverviewModel.fromJson(<String, dynamic>{
      'title': 'Final Exam: Level A1',
      'heroTitle': 'Ready to Graduate?',
      'heroSubtitle':
          'Complete this 4-part exam to earn your official Level A1 Certificate.',
      'components': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'core_quiz',
          'title': 'Part 1: Core Quiz',
          'subtitle': '30 Questions • Auto-graded',
          'iconName': 'quiz',
          'tone': 'green',
        },
        <String, dynamic>{
          'id': 'listening',
          'title': 'Part 2: Listening Lab',
          'subtitle': '10 Audio Tasks • Auto-graded',
          'iconName': 'headphones',
          'tone': 'blue',
        },
        <String, dynamic>{
          'id': 'writing',
          'title': 'Part 3: Writing Task',
          'subtitle': 'Teacher Review Required',
          'iconName': 'write',
          'tone': 'orange',
        },
        <String, dynamic>{
          'id': 'speaking',
          'title': 'Part 4: Speaking Lab',
          'subtitle': 'Teacher Review Required',
          'iconName': 'speak',
          'tone': 'lime',
        },
      ],
      'noteBangla':
          'আপনার রাইটিং এবং স্পিকিং পার্ট\nআমাদের শিক্ষকরা রিভিউ করবেন।\n২৪–৪৮ ঘণ্টার মধ্যে রেজাল্ট পাবেন।',
      'noteEnglish':
          'Note: Parts 3 & 4 will be sent to our teachers for manual evaluation. You will receive your final results within 24–48 hours.',
    });
  }

  Future<FinalExamListeningModel> fetchListeningTask() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));

    return FinalExamListeningModel.fromJson(<String, dynamic>{
      'title': 'Daily Routines in Berlin',
      'clipTitle': 'Daily Routines in Berlin',
      'questionTag': 'QUESTION 04',
      'question': 'What did the store owner say?',
      'options': <String>[
        '"Please return the items by tomorrow."',
        '"The shop will be closed for the holiday."',
        '"All products are currently half price."',
      ],
      'correctIndex': 0,
      'tip':
          'Tips: Focus on the verbs used in the conversation to identify the correct instruction.',
    });
  }

  Future<FinalExamWritingModel> fetchWritingTask() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return FinalExamWritingModel.fromJson(<String, dynamic>{
      'title': 'Part 3: Writing Task',
      'taskTitle': 'Task: My New Life in Italy',
      'instruction':
          'Write 150–200 words describing your workplace, your colleagues, and what you do every day.',
      'banglaInstruction':
          'ইতালিতে আপনার কর্মস্থল, সহকর্মী এবং প্রতিদিনের কাজ নিয়ে ১৫০–২০০ শব্দের একটি রচনা লিখুন।',
    });
  }

  Future<FinalExamSpeakingModel> fetchSpeakingTask() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return FinalExamSpeakingModel.fromJson(<String, dynamic>{
      'title': 'Part 4: Speaking Lab',
      'taskTitle': 'Task: Ordering at a Restaurant',
      'instruction':
          'Look at the menu and record yourself ordering a 3-course meal for two people.',
      'banglaInstruction':
          'মেনু দেখে ২ জনের জন্য ৩ পদের খাবার অর্ডার করার একটি কথোপকথন রেকর্ড করুন।',
      'tip': 'Speak clearly. Teachers will grade your fluency and accent.',
    });
  }

  Future<String> submitExam() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return '#EXAM-A1-4922';
  }

  Future<FinalExamResultModel> fetchResult() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return FinalExamResultModel.fromJson(<String, dynamic>{
      'markPercent': 92,
      'title': 'Risultato Finale: A1\nGraduate!',
      'subtitle': "Excellent work, Giacomo! You've unlocked Level A2.",
      'xpAwarded': 500,
      'teacherComment':
          'Bravissimo Giacomo! Your speaking fluency has improved significantly. Focus on your past-tense conjugations in Level A2.',
      'teacherCommentBangla':
          'আপনার কথা বলা বেশ ভালো হয়েছে। লেভেল A2 তে পাস্ট টেন্সের দিকে আরও নজর দিন।',
    });
  }
}
