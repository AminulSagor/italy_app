import '../models/course_certificate_models.dart';

class CourseCertificateMockService {
  Future<CourseCertificateModel> fetchCertificate() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return CourseCertificateModel.fromJson(<String, dynamic>{
      'learnerName': 'Giacomo Rossi',
      'proficiencyLevel': 'A1 Beginner',
      'issueDate': 'Oct 24, 2023',
      'finalScore': 94,
      'wordsLearned': 1200,
      'streakDays': 45,
      'quizzesCompleted': 32,
    });
  }
}
