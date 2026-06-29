import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';

class GuideFaqItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<GuideStepItem> steps;

  const GuideFaqItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.steps,
  });
}

class GuideStepItem {
  final String number;
  final String title;
  final String description;
  final Color color;
  final Color textColor;

  const GuideStepItem({
    required this.number,
    required this.title,
    required this.description,
    required this.color,
    required this.textColor,
  });
}

class GuideController extends GetxController {
  final List<GuideFaqItem> faqItems = <GuideFaqItem>[
    GuideFaqItem(
      id: 'restore-pro',
      title: 'gen_how_do_i_restore_my_pro_purcha'.tr.tr,
      category: 'ACCOUNT',
      description:
          'Restore your previous Pro subscription or lifetime access from your account settings.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'gen_open_settings'.tr.tr,
          description: 'Go to your profile and open the settings page.',
          color: Color(0xFF79F535),
          textColor: Color(0xFF1E7A00),
        ),
        GuideStepItem(
          number: '2',
          title: 'gen_tap_restore_purchase'.tr.tr,
          description: 'Use the restore button to check your previous payment.',
          color: Color(0xFFAED2FF),
          textColor: Color(0xFF005A94),
        ),
        GuideStepItem(
          number: '3',
          title: 'gen_wait_for_activation'.tr.tr,
          description: 'Your Pro access will be activated automatically.',
          color: Color(0xFFFF9700),
          textColor: Color(0xFF5C3800),
        ),
      ],
    ),
    GuideFaqItem(
      id: 'ai-speaking-lab',
      title: 'gen_how_to_use_the_ai_speaking_lab'.tr.tr,
      category: 'TUTORIAL',
      description:
          'Master your pronunciation with our advanced AI-driven feedback system.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'gen_select_your_topic'.tr.tr,
          description:
              'Choose from over 500+ daily life scenarios or upload your own script to start practicing specific vocabulary.',
          color: Color(0xFF79F535),
          textColor: Color(0xFF1E7A00),
        ),
        GuideStepItem(
          number: '2',
          title: 'gen_record_your_voice'.tr.tr,
          description:
              'Tap the microphone icon and speak clearly. Our AI listens for phoneme accuracy, rhythm, and intonation in real-time.',
          color: Color(0xFFAED2FF),
          textColor: Color(0xFF005A94),
        ),
        GuideStepItem(
          number: '3',
          title: 'gen_review_ai_feedback'.tr.tr,
          description:
              'Receive a detailed breakdown of your performance. Words highlighted in Green are perfect, while Red ones need more practice.',
          color: Color(0xFFFF9700),
          textColor: Color(0xFF5C3800),
        ),
      ],
    ),
    GuideFaqItem(
      id: 'caf-services',
      title: 'gen_where_to_find_caf_services'.tr.tr,
      category: 'HELP',
      description:
          'Find CAF support and related service guidance from the help section.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'gen_open_services'.tr.tr,
          description: 'Go to the services area from your dashboard or drawer.',
          color: Color(0xFF79F535),
          textColor: Color(0xFF1E7A00),
        ),
        GuideStepItem(
          number: '2',
          title: 'gen_choose_caf'.tr.tr,
          description:
              'Select the CAF service you need from the available list.',
          color: Color(0xFFAED2FF),
          textColor: Color(0xFF005A94),
        ),
        GuideStepItem(
          number: '3',
          title: 'gen_contact_support'.tr.tr,
          description:
              'Ask support if you need help choosing the correct service.',
          color: Color(0xFFFF9700),
          textColor: Color(0xFF5C3800),
        ),
      ],
    ),
  ];

  GuideFaqItem getFaqById(String? id) {
    return faqItems.firstWhere(
      (item) => item.id == id,
      orElse: () => faqItems[1],
    );
  }

  void openFaq(String id) {
    Get.toNamed(AppRoutes.guideFaq, arguments: id);
  }

  void joinFacebookCommunity() {
    Get.snackbar(
      'Facebook Community',
      'Community link will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void chatWithSupport() {
    Get.snackbar(
      'Support',
      'Support chat will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onGuideTap() {
    Get.toNamed(AppRoutes.guide);
  }
}
