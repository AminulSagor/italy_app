import 'package:get/get.dart';
import '../models/ai_tutor_level_test_models.dart';

List<AiTutorLevelQuestionModel> aiTutorLevelTestQuestions =
    <AiTutorLevelQuestionModel>[
      AiTutorLevelQuestionModel(
        id: 'vocabulary_lavoro',
        skill: AiTutorSkillType.vocabulary,
        type: AiTutorQuestionType.singleChoice,
        prompt: 'what_does_the_italian_word_lavoro_mean'.tr,
        helperText: 'সঠিক ইংরেজি অর্থটি বেছে নাও।'.tr,
        options: <String>['work'.tr, 'house'.tr, 'train'.tr, 'friend'.tr],
      ),
      AiTutorLevelQuestionModel(
        id: 'vocabulary_article',
        skill: AiTutorSkillType.vocabulary,
        type: AiTutorQuestionType.singleChoice,
        prompt: 'complete_vorrei_caff_per_favore'.tr,
        helperText: 'শূন্যস্থানে সবচেয়ে স্বাভাবিক শব্দটি বেছে নাও।'.tr,
        options: <String>['un', 'una', 'uno', 'le'],
      ),
      AiTutorLevelQuestionModel(
        id: 'grammar_age',
        skill: AiTutorSkillType.grammar,
        type: AiTutorQuestionType.singleChoice,
        prompt: 'choose_the_natural_italian_sentence_for_i_am_25_ye'.tr,
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
        prompt: 'complete_noi_italiano_ogni_giorno'.tr,
        helperText: 'gen_parlare'.tr,
        options: <String>['parliamo', 'parla', 'parlano', 'parlate'],
      ),
      AiTutorLevelQuestionModel(
        id: 'grammar_past',
        skill: AiTutorSkillType.grammar,
        type: AiTutorQuestionType.singleChoice,
        prompt: 'complete_ieri_maria_al_mercato'.tr,
        helperText: 'গতকালের কাজ বোঝাতে সঠিক রূপটি বেছে নাও।'.tr,
        options: <String>['è andata', 'va', 'andrà', 'andare'],
      ),
    ];
