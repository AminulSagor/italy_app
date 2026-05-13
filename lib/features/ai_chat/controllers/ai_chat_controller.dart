import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/ai_tutor_chat_view.dart';
import '../views/ai_tutor_discovery_view.dart';
import '../views/ai_tutor_live_voice_view.dart';
import '../views/guided_learning_level_selection_view.dart';
import '../views/guided_learning_topics_view.dart';
import '../views/ai_level_test_view.dart';

class AiChatController extends GetxController {
  final TextEditingController inputController = TextEditingController();

  final RxString inputText = ''.obs;
  final RxString chatMode = 'voice'.obs;
  final RxBool isRecording = false.obs;

  final RxList<int> expandedTranscriptIds = <int>[].obs;
  final RxList<int> expandedTranslationIds = <int>[].obs;

  final RxList<Map<String, dynamic>> visibleStarters =
      <Map<String, dynamic>>[].obs;

  final List<Map<String, dynamic>> _allStarters = <Map<String, dynamic>>[
    {
      'title': 'Practice ordering food',
      'subtitle': 'Al ristorante',
      'prompt': 'How do I order a coffee?',
      'mode': 'voice',
      'icon': Icons.restaurant_rounded,
    },
    {
      'title': 'Talk about my day',
      'subtitle': 'La mia giornata',
      'prompt': 'I want to talk about my day',
      'mode': 'text',
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'title': 'Review basic greetings',
      'subtitle': 'I saluti base',
      'prompt': 'Teach me basic Italian greetings',
      'mode': 'text',
      'icon': Icons.school_rounded,
    },
    {
      'title': 'Ask for directions',
      'subtitle': 'Chiedere indicazioni',
      'prompt': 'How do I ask for directions?',
      'mode': 'text',
      'icon': Icons.near_me_rounded,
    },
    {
      'title': 'Coffee shop phrases',
      'subtitle': 'Al bar',
      'prompt': 'Teach me coffee shop phrases',
      'mode': 'voice',
      'icon': Icons.local_cafe_rounded,
    },
  ];

  final RxList<Map<String, dynamic>> voiceMessages = <Map<String, dynamic>>[
    {
      'id': 1,
      'sender': 'user',
      'type': 'voice',
      'duration': '0:12',
      'time': '10:40 AM',
    },
    {
      'id': 2,
      'sender': 'ai',
      'type': 'voice',
      'duration': '0:15',
      'time': '10:41 AM',
      'transcriptOriginal':
          '"Ciao! Sto bene, grazie. Certo, iniziamo con i saluti formali."',
      'transcriptBangla':
          'হ্যালো! আমি ভালো আছি, ধন্যবাদ। অবশ্যই, আমরা আনুষ্ঠানিক অভিবাদন দিয়ে শুরু করি।',
    },
    {
      'id': 3,
      'sender': 'user',
      'type': 'voice',
      'duration': '0:08',
      'time': '10:42 AM',
    },
    {
      'id': 4,
      'sender': 'ai',
      'type': 'voice',
      'duration': '0:10',
      'time': '10:43 AM',
      'transcriptOriginal':
          '"Perfetto! Ripeti dopo di me: Buongiorno, piacere di conoscerti."',
      'transcriptBangla':
          'চমৎকার! আমার পরে বলুন: শুভ সকাল, আপনার সাথে পরিচিত হয়ে ভালো লাগলো।',
    },
  ].obs;

  final RxList<Map<String, dynamic>> textMessages = <Map<String, dynamic>>[
    {
      'id': 101,
      'sender': 'user',
      'type': 'text',
      'primary': 'How do I order a coffee?',
      'time': '10:47 AM',
    },
    {
      'id': 102,
      'sender': 'ai',
      'type': 'text',
      'primary': 'Un caffè, per favore.',
      'english': 'A coffee, please.',
      'bangla': 'একটি কফি, দয়া করে।',
      'time': '10:42 AM',
    },
    {
      'id': 103,
      'sender': 'user',
      'type': 'text',
      'primary': 'What about asking for the bill?',
      'time': '10:45 AM',
    },
    {
      'id': 104,
      'sender': 'ai',
      'type': 'text',
      'primary': 'Il conto, per favore.',
      'english': 'The bill, please.',
      'bangla': 'বিলটি, দয়া করে।',
      'time': '10:45 AM',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    refreshStarters();
  }

  void onEnterLabTap() {
    refreshStarters();
    Get.to<void>(
      () => const AiTutorDiscoveryView(),
      transition: Transition.rightToLeft,
    );
  }

  void refreshStarters() {
    final List<Map<String, dynamic>> shuffled = List<Map<String, dynamic>>.from(
      _allStarters,
    )..shuffle(Random());
    visibleStarters.assignAll(shuffled.take(3));
  }

  void onInputChanged(String value) {
    inputText.value = value;
  }

  void onStarterTap(Map<String, dynamic> starter) {
    final String mode = starter['mode'] as String? ?? 'text';

    if (mode == 'voice') {
      startVoiceConversation();
      return;
    }

    startTextConversation(starter['prompt'] as String? ?? '');
  }

  void startVoiceConversation() {
    chatMode.value = 'voice';
    isRecording.value = false;
    expandedTranscriptIds.clear();

    Get.to<void>(
      () => const AiTutorChatView(),
      transition: Transition.rightToLeft,
    );
  }

  void startTextConversation(String prompt) {
    chatMode.value = 'text';
    isRecording.value = false;
    expandedTranslationIds.clear();

    if (prompt.trim().isNotEmpty) {
      textMessages.assignAll(<Map<String, dynamic>>[
        {
          'id': 101,
          'sender': 'user',
          'type': 'text',
          'primary': prompt.trim(),
          'time': '10:47 AM',
        },
        {
          'id': 102,
          'sender': 'ai',
          'type': 'text',
          'primary': 'Un caffè, per favore.',
          'english': 'A coffee, please.',
          'bangla': 'একটি কফি, দয়া করে।',
          'time': '10:42 AM',
        },
        {
          'id': 103,
          'sender': 'user',
          'type': 'text',
          'primary': 'What about asking for the bill?',
          'time': '10:45 AM',
        },
        {
          'id': 104,
          'sender': 'ai',
          'type': 'text',
          'primary': 'Il conto, per favore.',
          'english': 'The bill, please.',
          'bangla': 'বিলটি, দয়া করে।',
          'time': '10:45 AM',
        },
      ]);
    }

    inputController.clear();
    inputText.value = '';

    Get.to<void>(
      () => const AiTutorChatView(),
      transition: Transition.rightToLeft,
    );
  }

  void sendTextFromDiscovery() {
    final String value = inputController.text.trim();
    if (value.isEmpty) return;
    startTextConversation(value);
  }

  void sendTextFromChat() {
    final String value = inputController.text.trim();
    if (value.isEmpty) return;

    final int userId = DateTime.now().millisecondsSinceEpoch;
    textMessages.add({
      'id': userId,
      'sender': 'user',
      'type': 'text',
      'primary': value,
      'time': '10:49 AM',
    });

    textMessages.add({
      'id': userId + 1,
      'sender': 'ai',
      'type': 'text',
      'primary': 'Posso aiutarti con questa frase.',
      'english': 'I can help you with this sentence.',
      'bangla': 'আমি আপনাকে এই বাক্যটি নিয়ে সাহায্য করতে পারি।',
      'time': '10:49 AM',
    });

    inputController.clear();
    inputText.value = '';
  }

  void toggleTranscript(int id) {
    if (expandedTranscriptIds.contains(id)) {
      expandedTranscriptIds.remove(id);
    } else {
      expandedTranscriptIds.add(id);
    }
  }

  void toggleTranslations(int id) {
    if (expandedTranslationIds.contains(id)) {
      expandedTranslationIds.remove(id);
    } else {
      expandedTranslationIds.add(id);
    }
  }

  void startRecording() {
    isRecording.value = true;
  }

  void cancelRecording() {
    isRecording.value = false;
  }

  void sendRecording() {
    final int id = DateTime.now().millisecondsSinceEpoch;

    voiceMessages.add({
      'id': id,
      'sender': 'user',
      'type': 'voice',
      'duration': '0:04',
      'time': '10:46 AM',
    });

    voiceMessages.add({
      'id': id + 1,
      'sender': 'ai',
      'type': 'voice',
      'duration': '0:11',
      'time': '10:46 AM',
      'transcriptOriginal': '"Molto bene! La tua pronuncia sta migliorando."',
      'transcriptBangla': 'খুব ভালো! আপনার উচ্চারণ উন্নত হচ্ছে।',
    });

    isRecording.value = false;
  }

  void openLiveVoiceSession() {
    Get.to<void>(
      () => const AiTutorLiveVoiceView(),
      transition: Transition.rightToLeft,
    );
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  void onGuidedLearningTap() {
    Get.to<void>(
      () => const GuidedLearningLevelSelectionView(),
      transition: Transition.rightToLeft,
    );
  }

  void openGuidedTopics(String level) {
    Get.to<void>(
      () => GuidedLearningTopicsView(level: level),
      transition: Transition.rightToLeft,
    );
  }

  void onGuidedTopicTap(String topicTitle) {
    chatMode.value = 'text';
    expandedTranslationIds.clear();

    textMessages.assignAll(<Map<String, dynamic>>[
      {
        'id': 201,
        'sender': 'user',
        'type': 'text',
        'primary': 'Let us practice: $topicTitle',
        'time': '10:50 AM',
      },
      {
        'id': 202,
        'sender': 'ai',
        'type': 'text',
        'primary': 'Certo! Iniziamo questa conversazione insieme.',
        'english': 'Sure! Let us start this conversation together.',
        'bangla': 'অবশ্যই! চলুন এই কথোপকথনটি একসাথে শুরু করি।',
        'time': '10:50 AM',
      },
    ]);

    Get.to<void>(
      () => const AiTutorChatView(),
      transition: Transition.rightToLeft,
    );
  }

  void onLevelTestTap() {
    Get.to<void>(
      () => const AiLevelTestView(),
      transition: Transition.rightToLeft,
    );
  }

  void startLevelTest() {
    Get.to<void>(
      () => const AiLevelTestResultView(),
      transition: Transition.rightToLeft,
    );
  }

  void continueAfterLevelTest() {
    Get.off<void>(
      () => const AiTutorDiscoveryView(),
      transition: Transition.rightToLeft,
    );
  }

  void onWritingHelpTap() {
    Get.snackbar(
      'Writing Help',
      'This feature is coming soon! Stay tuned for updates.',
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onRecentSessionTap() {
    Get.snackbar(
      'Recent Sessions',
      'This feature is coming soon! Stay tuned for updates.',
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
