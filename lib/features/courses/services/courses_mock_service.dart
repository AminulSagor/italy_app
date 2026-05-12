import '../models/course_models.dart';

class CoursesMockService {
  Future<CoursesDashboardModel> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    return CoursesDashboardModel.fromJson(<String, dynamic>{
      'courses': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'level-a1',
          'title': 'Level A1',
          'subtitle': 'Foundations of Italian',
          'progressLabel': '60%',
          'progress': 0.6,
          'statusLabel': 'ACTIVE',
          'state': 'active',
        },
        <String, dynamic>{
          'id': 'level-a2',
          'title': 'Level A2',
          'subtitle': 'Intermediate Italian',
          'progressLabel': '0%',
          'progress': 0.0,
          'statusLabel': 'LOCKED',
          'state': 'locked',
        },
      ],
      'skillBuilders': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'verbs',
          'title': 'Important Verbs',
          'iconName': 'bolt',
          'tone': 'green',
        },
        <String, dynamic>{
          'id': 'survival',
          'title': 'Survival Italian',
          'iconName': 'work',
          'tone': 'yellow',
        },
        <String, dynamic>{
          'id': 'job',
          'title': 'Job Sentences',
          'iconName': 'workbench',
          'tone': 'blue',
        },
        <String, dynamic>{
          'id': 'challenge',
          'title': 'Daily Challenges',
          'iconName': 'target',
          'tone': 'pink',
        },
      ],
      'specializedLearning': <String, dynamic>{
        'title': 'Final Exam – Esame finale',
        'subtitle': 'Complete the course to unlock final exam',
        'requirementLabel': '80% Required',
        'lockedLabel': 'Locked',
      },
    });
  }

  Future<CourseDetailModel> fetchCourseDetail({
    required String courseId,
    required bool isProEnabled,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (isProEnabled) {
      return _proUnlockedCourse(courseId: courseId);
    }

    return _freeCourse(courseId: courseId);
  }

  Future<void> enableProAccess() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  CourseDetailModel _freeCourse({required String courseId}) {
    return CourseDetailModel.fromJson(<String, dynamic>{
      'id': courseId,
      'title': 'Level A1 Basics',
      'progressLabel': '12%',
      'isProEnabled': false,
      'isExamFinished': false,
      'chapters': <Map<String, dynamic>>[
        _chapter(
          '1',
          "Capitolo 1: L'alfabeto",
          '',
          'completed',
          1.0,
          statusLabel: 'COMPLETED',
        ),
        _chapter(
          '2',
          'Capitolo 2: Saluti',
          '',
          'current',
          0.6,
          statusLabel: 'CURRENT STUDY',
        ),
        _chapter(
          '3',
          'Capitolo 3: Articoli',
          'The power of definite articles',
          'free',
          0.0,
          tagLabel: 'FREE',
        ),
        _chapter(
          '4',
          'Capitolo 4: Verbi Base',
          'Essential verb conjugations',
          'locked',
          0.0,
          tagLabel: 'PRO',
        ),
        _chapter(
          '5',
          'Capitolo 5: Numeri',
          'Counting to one hundred',
          'locked',
          0.0,
          tagLabel: 'PRO',
        ),
        _chapter(
          '6',
          'Capitolo 6: Numeri',
          'Counting to one hundred',
          'locked',
          0.0,
          tagLabel: 'PRO',
        ),
        _chapter(
          '7',
          'Capitolo 7: Numeri',
          'Counting to one hundred',
          'locked',
          0.0,
          tagLabel: 'PRO',
        ),
      ],
      'finalExam': _lockedFinalExamJson(),
    });
  }

  CourseDetailModel _proUnlockedCourse({required String courseId}) {
    return CourseDetailModel.fromJson(<String, dynamic>{
      'id': courseId,
      'title': 'Level A1 Basics',
      'progressLabel': '12%',
      'isProEnabled': true,
      'isExamFinished': false,
      'chapters': <Map<String, dynamic>>[
        _chapter(
          '1',
          "Capitolo 1: L'alfabeto",
          '',
          'completed',
          1.0,
          statusLabel: 'COMPLETED',
        ),
        _chapter(
          '2',
          'Capitolo 2: Saluti',
          '',
          'current',
          0.6,
          statusLabel: 'CURRENT STUDY',
        ),
        _chapter(
          '3',
          'Capitolo 3: Articoli',
          'The power of definite articles',
          'available',
          0.0,
        ),
        _chapter(
          '4',
          'Capitolo 4: Verbi Base',
          'Essential verb conjugations',
          'available',
          0.0,
        ),
        _chapter(
          '5',
          'Capitolo 5: Numeri',
          'Counting to one hundred',
          'available',
          0.0,
        ),
        _chapter(
          '6',
          'Capitolo 6: Numeri',
          'Counting to one hundred',
          'available',
          0.0,
        ),
        _chapter(
          '7',
          'Capitolo 7: Numeri',
          'Counting to one hundred',
          'available',
          0.0,
        ),
        _chapter(
          '8',
          'Capitolo 8: Numeri',
          'Counting to one hundred',
          'available',
          0.0,
        ),
        _chapter(
          '9',
          'Capitolo 9: Numeri',
          'Counting to one hundred',
          'available',
          0.0,
        ),
        _chapter(
          '10',
          'Capitolo 10: Numeri',
          'Counting to one hundred',
          'available',
          0.0,
        ),
      ],
      'finalExam': _lockedFinalExamJson(),
    });
  }

  Map<String, dynamic> _lockedFinalExamJson() {
    return <String, dynamic>{
      'title': 'Final Exam',
      'description':
          'Unlock after completing all chapters to prove your Italian mastery & earn certificate.',
      'actionLabel': 'NOT YET ELIGIBLE',
      'helperLabel': 'Requires 8 more chapters',
      'canStart': false,
    };
  }

  Map<String, dynamic> _chapter(
    String id,
    String title,
    String subtitle,
    String state,
    double progress, {
    String? statusLabel,
    String? tagLabel,
  }) {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'statusLabel': statusLabel,
      'tagLabel': tagLabel,
      'progress': progress,
      'state': state,
    };
  }
}
