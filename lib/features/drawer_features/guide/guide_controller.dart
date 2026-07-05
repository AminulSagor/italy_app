import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import 'models/guide_faq_item.dart';

class GuideController extends GetxController {
  static const Color _stepOneColor = Color(0xFF79F535);
  static const Color _stepOneTextColor = Color(0xFF1E7A00);
  static const Color _stepTwoColor = Color(0xFFAED2FF);
  static const Color _stepTwoTextColor = Color(0xFF005A94);
  static const Color _stepThreeColor = Color(0xFFFFC36A);
  static const Color _stepThreeTextColor = Color(0xFF5C3800);

  final List<GuideFaqItem> faqItems = <GuideFaqItem>[
    GuideFaqItem(
      id: 'start-course',
      title: 'how_do_i_start_or_continue_a_course'.tr,
      category: 'courses'.tr,
      description:
          'open_a_course_choose_an_available_chapter_and_cont'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'open_courses'.tr,
          description:
              'tap_the_courses_icon_in_the_bottom_navigation_to_s'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'choose_a_course'.tr,
          description:
              'open_a_course_to_view_its_chapters_current_progres'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'continue_the_current_chapter'.tr,
          description:
              'select_the_current_or_unlocked_chapter_the_app_use'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'Complete chapters in order so the course progress and final exam eligibility stay up to date.',
    ),
    GuideFaqItem(
      id: 'complete-chapter',
      title: 'how_is_a_course_chapter_completed'.tr,
      category: 'courses'.tr,
      description:
          'chapter_completion_is_based_on_the_learning_resour'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'use_the_learning_resources'.tr,
          description:
              'watch_the_video_listen_to_the_audio_or_open_the_th'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'unlock_the_quiz'.tr,
          description:
              'for_chapters_with_a_video_watching_at_least_80_unl'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'finish_the_quiz'.tr,
          description:
              'complete_the_chapter_quiz_when_it_is_available_you'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'final-exam',
      title: 'how_do_i_unlock_the_final_exam_and_certificate'.tr,
      category: 'courses'.tr,
      description:
          'the_final_exam_becomes_available_after_enough_of_t'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'reach_80_course_progress'.tr,
          description:
              'complete_at_least_80_of_the_course_to_unlock_its_f'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'complete_the_exam_sections'.tr,
          description:
              'follow_the_available_quiz_listening_writing_and_sp'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'open_your_result'.tr,
          description:
              'after_submission_open_the_result_when_processing_i'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'Use a quiet place for speaking tasks and check microphone permission before starting the exam.',
    ),
    GuideFaqItem(
      id: 'ai-tutor',
      title: 'how_do_i_use_the_ai_tutor'.tr,
      category: 'ai_tutor_1'.tr,
      description:
          'use_text_chat_live_voice_guided_learning_writing_h'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'open_ai_tutor'.tr,
          description:
              'tap_the_ai_tutor_icon_in_the_bottom_navigation_and'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'choose_a_learning_mode'.tr,
          description:
              'start_a_text_conversation_enter_live_voice_select'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'continue_the_session'.tr,
          description:
              'type_or_speak_naturally_and_follow_the_tutor_respo'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'For clearer voice responses, allow microphone permission and practice in a place with low background noise.',
    ),
    GuideFaqItem(
      id: 'practice-hub',
      title: 'what_can_i_do_in_the_practice_hub'.tr,
      category: 'practice'.tr,
      description:
          'the_practice_hub_brings_together_daily_challenges'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'open_progress'.tr,
          description:
              'tap_the_progress_icon_in_the_bottom_navigation_to'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'choose_a_practice_tool'.tr,
          description:
              'study_important_verbs_open_survival_italian_pdfs_p'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'save_and_claim_progress'.tr,
          description:
              'save_useful_verbs_listen_to_available_pronunciatio'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'daily-chest',
      title: 'how_do_daily_challenges_and_the_chest_work'.tr,
      category: 'gen_rewards'.tr,
      description:
          'daily_tasks_award_xp_and_completing_all_tasks_unlo'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'complete_each_task'.tr,
          description:
              'open_daily_challenges_and_finish_the_lesson_quiz_o'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'claim_the_xp'.tr,
          description:
              'use_the_claim_button_after_a_task_is_completed_xp'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'open_the_chest'.tr,
          description:
              'when_every_daily_task_is_complete_tap_the_unlocked'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'create-cv',
      title: 'how_do_i_create_and_download_a_cv'.tr,
      category: 'gen_cv_builder'.tr,
      description:
          'create_a_cv_from_an_admin_provided_template_comple'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'open_my_cv_hub'.tr,
          description:
              'open_tools_enter_the_cv_builder_and_choose_to_crea'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'choose_and_complete_a_template'.tr,
          description:
              'select_a_template_fill_in_the_requested_profile_an'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'preview_or_download_the_pdf'.tr,
          description:
              'review_the_generated_cv_open_the_pdf_preview_or_us'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'Review names, dates, phone numbers, and email addresses carefully before downloading the final CV.',
    ),
    GuideFaqItem(
      id: 'messages-calls',
      title: 'how_do_messages_and_calls_work'.tr,
      category: 'messages'.tr,
      description:
          'search_for_another_user_open_a_conversation_exchan'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'open_messages'.tr,
          description:
              'use_the_messages_action_from_the_main_app_area_the'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'start_the_conversation'.tr,
          description:
              'send_messages_from_the_chat_screen_new_messages_an'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'answer_or_end_a_call'.tr,
          description:
              'for_an_incoming_call_accept_or_decline_from_the_ca'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'rewards',
      title: 'where_can_i_find_and_use_my_rewards'.tr,
      category: 'gen_rewards'.tr,
      description:
          'the_rewards_area_shows_unopened_chests_reward_hist'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'open_reward_from_the_drawer'.tr,
          description:
              'open_the_app_drawer_and_tap_reward_to_load_the_cur'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'open_or_review_a_reward'.tr,
          description:
              'open_an_available_chest_or_use_reward_history_to_r'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'complete_the_reward_action'.tr,
          description:
              'depending_on_the_reward_download_a_file_open_cours'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'caf-services',
      title: 'where_do_i_find_caf_and_administrative_help'.tr,
      category: 'services'.tr,
      description:
          'administrative_guidance_is_available_from_the_tool'.tr,
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'open_tools'.tr,
          description:
              'tap_the_tools_icon_in_the_bottom_navigation_to_ope'.tr,
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'choose_administrative_help'.tr,
          description:
              'open_the_caf_and_administrative_help_section_then'.tr,
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'follow_the_guide_or_contact_support'.tr,
          description:
              'review_the_listed_steps_and_checklist_use_support'.tr,
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'Administrative requirements can change, so confirm important document and appointment details with the appropriate official office.',
    ),
  ];

  GuideFaqItem getFaqById(String? id) {
    return faqItems.firstWhere(
      (GuideFaqItem item) => item.id == id,
      orElse: () => faqItems.first,
    );
  }

  void openFaq(String id) {
    Get.toNamed(AppRoutes.guideFaq, arguments: id);
  }

  void joinFacebookCommunity() {
    Get.snackbar(
      'facebook_community'.tr,
      'Community link will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void chatWithSupport() {
    Get.snackbar(
      'support'.tr,
      'Support chat will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onGuideTap() {
    Get.toNamed(AppRoutes.guide);
  }
}
