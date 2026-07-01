import 'package:get/get.dart';
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? '',
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
  final bool canStart;
  final String startMessage;

  const FinalExamOverviewModel({
    required this.title,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.components,
    required this.noteBangla,
    required this.noteEnglish,
    required this.canStart,
    required this.startMessage,
  });

  factory FinalExamOverviewModel.fromJson(Map<String, dynamic> json) {
    return FinalExamOverviewModel(
      title: json['title']?.toString() ?? '',
      heroTitle: json['heroTitle']?.toString() ?? '',
      heroSubtitle: json['heroSubtitle']?.toString() ?? '',
      components: ((json['components'] as List<dynamic>?) ?? <dynamic>[])
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> item) => FinalExamComponentModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      noteBangla: json['noteBangla']?.toString() ?? '',
      noteEnglish: json['noteEnglish']?.toString() ?? '',
      canStart: json['canStart'] as bool? ?? false,
      startMessage: json['startMessage']?.toString() ?? '',
    );
  }
}

class FinalExamListeningModel {
  final String sectionId;
  final String questionId;
  final String title;
  final String clipTitle;
  final String questionTag;
  final String question;
  final List<String> options;
  final List<String> optionIds;
  final String tip;
  final String audioUrl;
  final bool playbackLocked;

  const FinalExamListeningModel({
    required this.sectionId,
    required this.questionId,
    required this.title,
    required this.clipTitle,
    required this.questionTag,
    required this.question,
    required this.options,
    required this.optionIds,
    required this.tip,
    required this.audioUrl,
    required this.playbackLocked,
  });
}

class FinalExamWritingModel {
  final String sectionId;
  final String questionId;
  final String title;
  final String taskTitle;
  final String instruction;
  final String banglaInstruction;
  final int minWords;
  final int maxWords;

  const FinalExamWritingModel({
    required this.sectionId,
    required this.questionId,
    required this.title,
    required this.taskTitle,
    required this.instruction,
    required this.banglaInstruction,
    required this.minWords,
    required this.maxWords,
  });
}

class FinalExamSpeakingModel {
  final String sectionId;
  final String questionId;
  final String title;
  final String taskTitle;
  final String instruction;
  final String banglaInstruction;
  final String tip;
  final int maxDurationSeconds;
  final bool unlimitedRerecords;

  const FinalExamSpeakingModel({
    required this.sectionId,
    required this.questionId,
    required this.title,
    required this.taskTitle,
    required this.instruction,
    required this.banglaInstruction,
    required this.tip,
    required this.maxDurationSeconds,
    required this.unlimitedRerecords,
  });
}

class FinalExamResultStatModel {
  final String label;
  final String value;
  final String iconName;

  const FinalExamResultStatModel({
    required this.label,
    required this.value,
    required this.iconName,
  });
}

class FinalExamResultModel {
  final int markPercent;
  final String title;
  final String subtitle;
  final int xpAwarded;
  final String teacherComment;
  final String teacherCommentBangla;
  final String verdict;
  final List<FinalExamResultStatModel> stats;

  const FinalExamResultModel({
    required this.markPercent,
    required this.title,
    required this.subtitle,
    required this.xpAwarded,
    required this.teacherComment,
    required this.teacherCommentBangla,
    required this.verdict,
    required this.stats,
  });

  factory FinalExamResultModel.fromReview(Map<String, dynamic> review) {
    final double average = _doubleValue(review['finalAverageScore']);
    final String verdict = review['verdict']?.toString() ?? '';
    final String strength = review['keyStrength']?.toString().trim() ?? '';
    final String gap = review['criticalGap']?.toString().trim() ?? '';

    return FinalExamResultModel(
      markPercent: average.round().clamp(0, 100).toInt(),
      title: verdict == 'passed'
          ? 'Risultato Finale: Passed!'
          : verdict == 'retake_required'
              ? 'Retake Required'
              : 'Final Exam Result',
      subtitle: strength.isNotEmpty
          ? strength
          : gap.isNotEmpty
              ? gap
              : 'Your final evaluation is ready.',
      xpAwarded: 0,
      teacherComment: review['teacherComment']?.toString() ?? '',
      teacherCommentBangla: review['teacherCommentBn']?.toString() ?? '',
      verdict: verdict,
      stats: <FinalExamResultStatModel>[
        FinalExamResultStatModel(
          label: 'gen_vocabulary'.tr.tr,
          value: '${_intValue(review['vocabularyUsageScore'])}',
          iconName: 'quiz',
        ),
        FinalExamResultStatModel(
          label: 'gen_grammar'.tr.tr,
          value: '${_intValue(review['grammarAccuracyScore'])}',
          iconName: 'listening',
        ),
        FinalExamResultStatModel(
          label: 'gen_writing'.tr.tr,
          value: _scoreLabel(review['writingScore']),
          iconName: 'writing',
        ),
        FinalExamResultStatModel(
          label: 'gen_speaking'.tr.tr,
          value: _scoreLabel(review['speakingScore']),
          iconName: 'speaking',
        ),
      ],
    );
  }
}

int _intValue(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _scoreLabel(dynamic value) {
  final double score = _doubleValue(value);
  return score == score.roundToDouble()
      ? score.round().toString()
      : score.toStringAsFixed(1);
}
