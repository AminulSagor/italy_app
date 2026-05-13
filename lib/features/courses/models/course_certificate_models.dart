class CourseCertificateModel {
  final String learnerName;
  final String proficiencyLevel;
  final String issueDate;
  final int finalScore;
  final int wordsLearned;
  final int streakDays;
  final int quizzesCompleted;

  const CourseCertificateModel({
    required this.learnerName,
    required this.proficiencyLevel,
    required this.issueDate,
    required this.finalScore,
    required this.wordsLearned,
    required this.streakDays,
    required this.quizzesCompleted,
  });

  factory CourseCertificateModel.fromJson(Map<String, dynamic> json) {
    return CourseCertificateModel(
      learnerName: json['learnerName'] as String,
      proficiencyLevel: json['proficiencyLevel'] as String,
      issueDate: json['issueDate'] as String,
      finalScore: json['finalScore'] as int,
      wordsLearned: json['wordsLearned'] as int,
      streakDays: json['streakDays'] as int,
      quizzesCompleted: json['quizzesCompleted'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'learnerName': learnerName,
      'proficiencyLevel': proficiencyLevel,
      'issueDate': issueDate,
      'finalScore': finalScore,
      'wordsLearned': wordsLearned,
      'streakDays': streakDays,
      'quizzesCompleted': quizzesCompleted,
    };
  }
}
