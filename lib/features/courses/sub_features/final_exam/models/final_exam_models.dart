enum FinalExamComponentTone { green, blue, orange, lime }

class FinalExamComponentModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final FinalExamComponentTone tone;

  const FinalExamComponentModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.tone,
  });

  factory FinalExamComponentModel.fromJson(Map<String, dynamic> json) {
    return FinalExamComponentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconName: json['iconName'] as String,
      tone: FinalExamComponentTone.values.firstWhere(
        (FinalExamComponentTone item) => item.name == json['tone'],
        orElse: () => FinalExamComponentTone.green,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'iconName': iconName,
      'tone': tone.name,
    };
  }
}

class FinalExamOverviewModel {
  final String title;
  final String heroTitle;
  final String heroSubtitle;
  final List<FinalExamComponentModel> components;
  final String noteBangla;
  final String noteEnglish;

  const FinalExamOverviewModel({
    required this.title,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.components,
    required this.noteBangla,
    required this.noteEnglish,
  });

  factory FinalExamOverviewModel.fromJson(Map<String, dynamic> json) {
    return FinalExamOverviewModel(
      title: json['title'] as String,
      heroTitle: json['heroTitle'] as String,
      heroSubtitle: json['heroSubtitle'] as String,
      components: (json['components'] as List<dynamic>)
          .map((dynamic item) => FinalExamComponentModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      noteBangla: json['noteBangla'] as String,
      noteEnglish: json['noteEnglish'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'heroTitle': heroTitle,
      'heroSubtitle': heroSubtitle,
      'components': components.map((FinalExamComponentModel item) => item.toJson()).toList(),
      'noteBangla': noteBangla,
      'noteEnglish': noteEnglish,
    };
  }
}

class FinalExamListeningModel {
  final String title;
  final String clipTitle;
  final String questionTag;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String tip;

  const FinalExamListeningModel({
    required this.title,
    required this.clipTitle,
    required this.questionTag,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.tip,
  });

  factory FinalExamListeningModel.fromJson(Map<String, dynamic> json) {
    return FinalExamListeningModel(
      title: json['title'] as String,
      clipTitle: json['clipTitle'] as String,
      questionTag: json['questionTag'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).map((dynamic item) => item as String).toList(),
      correctIndex: json['correctIndex'] as int,
      tip: json['tip'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'clipTitle': clipTitle,
      'questionTag': questionTag,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'tip': tip,
    };
  }
}

class FinalExamWritingModel {
  final String title;
  final String taskTitle;
  final String instruction;
  final String banglaInstruction;

  const FinalExamWritingModel({
    required this.title,
    required this.taskTitle,
    required this.instruction,
    required this.banglaInstruction,
  });

  factory FinalExamWritingModel.fromJson(Map<String, dynamic> json) {
    return FinalExamWritingModel(
      title: json['title'] as String,
      taskTitle: json['taskTitle'] as String,
      instruction: json['instruction'] as String,
      banglaInstruction: json['banglaInstruction'] as String,
    );
  }
}

class FinalExamSpeakingModel {
  final String title;
  final String taskTitle;
  final String instruction;
  final String banglaInstruction;
  final String tip;

  const FinalExamSpeakingModel({
    required this.title,
    required this.taskTitle,
    required this.instruction,
    required this.banglaInstruction,
    required this.tip,
  });

  factory FinalExamSpeakingModel.fromJson(Map<String, dynamic> json) {
    return FinalExamSpeakingModel(
      title: json['title'] as String,
      taskTitle: json['taskTitle'] as String,
      instruction: json['instruction'] as String,
      banglaInstruction: json['banglaInstruction'] as String,
      tip: json['tip'] as String,
    );
  }
}

class FinalExamResultModel {
  final int markPercent;
  final String title;
  final String subtitle;
  final int xpAwarded;
  final String teacherComment;
  final String teacherCommentBangla;

  const FinalExamResultModel({
    required this.markPercent,
    required this.title,
    required this.subtitle,
    required this.xpAwarded,
    required this.teacherComment,
    required this.teacherCommentBangla,
  });

  factory FinalExamResultModel.fromJson(Map<String, dynamic> json) {
    return FinalExamResultModel(
      markPercent: json['markPercent'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      xpAwarded: json['xpAwarded'] as int,
      teacherComment: json['teacherComment'] as String,
      teacherCommentBangla: json['teacherCommentBangla'] as String,
    );
  }
}
