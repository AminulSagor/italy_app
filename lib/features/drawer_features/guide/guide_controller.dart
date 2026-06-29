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

  final List<GuideFaqItem> faqItems = const <GuideFaqItem>[
    GuideFaqItem(
      id: 'start-course',
      title: 'How do I start or continue a course?',
      category: 'COURSES',
      description:
          'Open a course, choose an available chapter, and continue from the learning progress already saved to your account.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Open Courses',
          description:
              'Tap the Courses icon in the bottom navigation to see the available learning programs.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Choose a Course',
          description:
              'Open a course to view its chapters, current progress, locked content, and final exam status.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Continue the Current Chapter',
          description:
              'Select the current or unlocked chapter. The app uses your saved progress so you can continue learning.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'Complete chapters in order so the course progress and final exam eligibility stay up to date.',
    ),
    GuideFaqItem(
      id: 'complete-chapter',
      title: 'How is a course chapter completed?',
      category: 'COURSES',
      description:
          'Chapter completion is based on the learning resources and quiz configured for that chapter.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Use the Learning Resources',
          description:
              'Watch the video, listen to the audio, or open the theory PDF when those resources are available.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Unlock the Quiz',
          description:
              'For chapters with a video, watching at least 80% unlocks the quiz. Chapters without a quiz use their available lesson content for completion.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Finish the Quiz',
          description:
              'Complete the chapter quiz when it is available. Your result and chapter progress are then synced with the course.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'final-exam',
      title: 'How do I unlock the final exam and certificate?',
      category: 'COURSES',
      description:
          'The final exam becomes available after enough of the selected course has been completed.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Reach 80% Course Progress',
          description:
              'Complete at least 80% of the course to unlock its final exam card.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Complete the Exam Sections',
          description:
              'Follow the available quiz, listening, writing, and speaking sections shown for the exam.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Open Your Result',
          description:
              'After submission, open the result when processing is complete. A certificate can be opened from a successful result when available.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'Use a quiet place for speaking tasks and check microphone permission before starting the exam.',
    ),
    GuideFaqItem(
      id: 'ai-tutor',
      title: 'How do I use the AI Tutor?',
      category: 'AI TUTOR',
      description:
          'Use text chat, live voice, guided learning, writing help, or the level test from the AI Tutor area.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Open AI Tutor',
          description:
              'Tap the AI Tutor icon in the bottom navigation and choose a suggested starter or enter your own message.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Choose a Learning Mode',
          description:
              'Start a text conversation, enter live voice, select a guided topic, request writing help, or take the level test.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Continue the Session',
          description:
              'Type or speak naturally and follow the tutor response. End a live voice session when you have finished practicing.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'For clearer voice responses, allow microphone permission and practice in a place with low background noise.',
    ),
    GuideFaqItem(
      id: 'practice-hub',
      title: 'What can I do in the Practice Hub?',
      category: 'PRACTICE',
      description:
          'The Practice Hub brings together daily challenges, important verbs, survival Italian, and job-focused sentences.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Open Progress',
          description:
              'Tap the Progress icon in the bottom navigation to open the Practice Hub and view your active learning tools.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Choose a Practice Tool',
          description:
              'Study important verbs, open survival Italian PDFs, practice job sentences, or complete the daily tasks.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Save and Claim Progress',
          description:
              'Save useful verbs, listen to available pronunciation, and claim XP after a daily challenge has been completed.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'daily-chest',
      title: 'How do daily challenges and the chest work?',
      category: 'REWARDS',
      description:
          'Daily tasks award XP, and completing all tasks unlocks the daily chest.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Complete Each Task',
          description:
              'Open Daily Challenges and finish the lesson, quiz, or learning activity described by each task.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Claim the XP',
          description:
              'Use the claim button after a task is completed. XP cannot be claimed before the task requirement is met.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Open the Chest',
          description:
              'When every daily task is complete, tap the unlocked chest to reveal the reward.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'create-cv',
      title: 'How do I create and download a CV?',
      category: 'CV BUILDER',
      description:
          'Create a CV from an admin-provided template, complete its fields, choose theme colors, and generate the PDF.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Open My CV Hub',
          description:
              'Open Tools, enter the CV Builder, and choose to create a new CV.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Choose and Complete a Template',
          description:
              'Select a template, fill in the requested profile and work details, and choose the available primary and accent colors.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Preview or Download the PDF',
          description:
              'Review the generated CV, open the PDF preview, or use Download PDF when the document is ready.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
      expertTip:
          'Review names, dates, phone numbers, and email addresses carefully before downloading the final CV.',
    ),
    GuideFaqItem(
      id: 'messages-calls',
      title: 'How do messages and calls work?',
      category: 'MESSAGES',
      description:
          'Search for another user, open a conversation, exchange messages, and use calling when it is available for that conversation.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Open Messages',
          description:
              'Use the messages action from the main app area, then open an existing thread or search for a user.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Start the Conversation',
          description:
              'Send messages from the chat screen. New messages and presence updates are synchronized while the app is connected.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Answer or End a Call',
          description:
              'For an incoming call, accept or decline from the call screen. During a call, use the provided controls and end the call when finished.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'rewards',
      title: 'Where can I find and use my rewards?',
      category: 'REWARDS',
      description:
          'The Rewards area shows unopened chests, reward history, and the action required for each reward type.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Open Reward from the Drawer',
          description:
              'Open the app drawer and tap Reward to load the current dashboard and any unopened chest.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Open or Review a Reward',
          description:
              'Open an available chest or use Reward History to review previously unlocked items.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Complete the Reward Action',
          description:
              'Depending on the reward, download a file, open course access, or provide shipping information for a physical item.',
          color: _stepThreeColor,
          textColor: _stepThreeTextColor,
        ),
      ],
    ),
    GuideFaqItem(
      id: 'caf-services',
      title: 'Where do I find CAF and administrative help?',
      category: 'SERVICES',
      description:
          'Administrative guidance is available from the Tools area, including CAF paths, document checklists, and permit guidance.',
      steps: <GuideStepItem>[
        GuideStepItem(
          number: '1',
          title: 'Open Tools',
          description:
              'Tap the Tools icon in the bottom navigation to open the service hub.',
          color: _stepOneColor,
          textColor: _stepOneTextColor,
        ),
        GuideStepItem(
          number: '2',
          title: 'Choose Administrative Help',
          description:
              'Open the CAF and administrative help section, then select the service or guide that matches your need.',
          color: _stepTwoColor,
          textColor: _stepTwoTextColor,
        ),
        GuideStepItem(
          number: '3',
          title: 'Follow the Guide or Contact Support',
          description:
              'Review the listed steps and checklist. Use Support from the drawer when you need direct assistance.',
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
