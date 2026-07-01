import 'package:get/get.dart';
import '../models/ai_tutor_level_test_models.dart';

List<AiTutorLevelQuestionModel> aiTutorLevelTestQuestions =
    <AiTutorLevelQuestionModel>[
  AiTutorLevelQuestionModel(
    id: 'speaking_introduction',
    skill: AiTutorSkillType.speaking,
    type: AiTutorQuestionType.openText,
    prompt: 'Presentati in italiano in 2–3 sentences.',
    helperText:
        'মাইক্রোফোন চেপে ধরে ইতালিয়ান ভাষায় বলো। নিজের নাম, দেশ বা কাজ বলতে পারো।'.tr,
  ),
  AiTutorLevelQuestionModel(
    id: 'speaking_daily_routine',
    skill: AiTutorSkillType.speaking,
    type: AiTutorQuestionType.openText,
    prompt: 'Racconta cosa fai in una giornata normale.',
    helperText:
        'মাইক্রোফোন চেপে ধরে তোমার একটি সাধারণ দিনের কথা ইতালিয়ান ভাষায় ২–৪টি বাক্যে বলো।'.tr,
  ),
  AiTutorLevelQuestionModel(
    id: 'speaking_restaurant',
    skill: AiTutorSkillType.speaking,
    type: AiTutorQuestionType.openText,
    prompt: 'Sei al ristorante. Ordina un pasto e chiedi il prezzo.',
    helperText:
        'মাইক্রোফোন চেপে ধরে রেস্টুরেন্টে খাবার অর্ডার এবং দাম জিজ্ঞেস করার মতো করে বলো।'.tr,
  ),
  AiTutorLevelQuestionModel(
    id: 'vocabulary_lavoro',
    skill: AiTutorSkillType.vocabulary,
    type: AiTutorQuestionType.singleChoice,
    prompt: 'What does the Italian word “lavoro” mean?',
    helperText: 'সঠিক ইংরেজি অর্থটি বেছে নাও।'.tr,
    options: <String>['Work', 'House', 'Train', 'Friend'],
  ),
  AiTutorLevelQuestionModel(
    id: 'vocabulary_article',
    skill: AiTutorSkillType.vocabulary,
    type: AiTutorQuestionType.singleChoice,
    prompt: 'Complete: “Vorrei ___ caffè, per favore.”',
    helperText: 'শূন্যস্থানে সবচেয়ে স্বাভাবিক শব্দটি বেছে নাও।'.tr,
    options: <String>['un', 'una', 'uno', 'le'],
  ),
  AiTutorLevelQuestionModel(
    id: 'vocabulary_perche',
    skill: AiTutorSkillType.vocabulary,
    type: AiTutorQuestionType.openText,
    prompt: 'Write one Italian sentence using “perché”.',
    helperText: 'gen_perch'.tr.tr,
  ),
  AiTutorLevelQuestionModel(
    id: 'grammar_age',
    skill: AiTutorSkillType.grammar,
    type: AiTutorQuestionType.singleChoice,
    prompt: 'Choose the natural Italian sentence for “I am 25 years old.”',
    helperText: 'ইতালিয়ান ভাষায় বয়স বলার সঠিক বাক্যটি বেছে নাও।'.tr,
    options: <String>[
      'Io sono 25 anni.',
      'Ho 25 anni.',
      'Sono avere 25 anni.',
      'Io ha 25 anni.',
    ],
  ),
  AiTutorLevelQuestionModel(
    id: 'grammar_parlare',
    skill: AiTutorSkillType.grammar,
    type: AiTutorQuestionType.singleChoice,
    prompt: 'Complete: “Noi ___ italiano ogni giorno.”',
    helperText: 'gen_parlare'.tr.tr,
    options: <String>['parliamo', 'parla', 'parlano', 'parlate'],
  ),
  AiTutorLevelQuestionModel(
    id: 'grammar_past',
    skill: AiTutorSkillType.grammar,
    type: AiTutorQuestionType.singleChoice,
    prompt: 'Complete: “Ieri Maria ___ al mercato.”',
    helperText: 'গতকালের কাজ বোঝাতে সঠিক রূপটি বেছে নাও।'.tr,
    options: <String>['è andata', 'va', 'andrà', 'andare'],
  ),
  AiTutorLevelQuestionModel(
    id: 'grammar_translation',
    skill: AiTutorSkillType.grammar,
    type: AiTutorQuestionType.openText,
    prompt:
        'Translate into Italian: “Tomorrow I will go to work because I have a meeting.”',
    helperText: 'পূর্ণ ইতালিয়ান বাক্যে অনুবাদ করো।'.tr,
  ),
];
