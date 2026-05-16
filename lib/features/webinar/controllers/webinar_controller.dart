import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../models/webinar_models.dart';
import '../services/webinar_mock_service.dart';

class WebinarController extends GetxController {
  final WebinarMockService _webinarMockService;

  WebinarController({required WebinarMockService webinarMockService})
    : _webinarMockService = webinarMockService;

  final RxBool isLoading = false.obs;
  final Rxn<WebinarModel> webinar = Rxn<WebinarModel>();
  final RxList<WebinarLiveChatModel> liveMessages =
      <WebinarLiveChatModel>[].obs;
  final RxBool isParticipating = false.obs;
  final RxBool isChatFocused = false.obs;
  final RxBool isTalking = false.obs;
  final RxBool isMicEnabled = true.obs;
  final RxBool isCameraEnabled = true.obs;
  final RxBool isLiveVideoAlt = false.obs;

  final TextEditingController chatTextController = TextEditingController();

  List<WebinarLiveChatModel> get latestStageMessages {
    if (liveMessages.length <= 3) return liveMessages.toList(growable: false);
    return liveMessages
        .sublist(liveMessages.length - 3)
        .toList(growable: false);
  }

  Timer? _chatTimer;
  int _chatIndex = 0;

  @override
  void onInit() {
    super.onInit();
    loadWebinar();
  }

  @override
  void onClose() {
    _chatTimer?.cancel();
    chatTextController.dispose();
    super.onClose();
  }

  Future<void> loadWebinar() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final WebinarModel data = await _webinarMockService.fetchWebinar();
      webinar.value = data;
      liveMessages.assignAll(data.seedMessages);
    } finally {
      isLoading.value = false;
    }
  }

  void openLiveSession() {
    _startLiveChat();
    Get.toNamed(AppRoutes.webinarLive);
  }

  void requestToParticipate() {
    isParticipating.value = true;
    isChatFocused.value = false;
    isLiveVideoAlt.value = true;
  }

  void backToParticipation() {
    isChatFocused.value = false;
    isParticipating.value = true;
  }

  void openChatMode() {
    isChatFocused.value = true;
    isParticipating.value = false;
  }

  void stopParticipation() {
    isParticipating.value = false;
    isChatFocused.value = false;
    isTalking.value = false;
    isLiveVideoAlt.value = false;
  }

  void toggleMic() {
    isMicEnabled.value = !isMicEnabled.value;
    if (!isMicEnabled.value) {
      isTalking.value = false;
    }
  }

  void toggleCamera() {
    isCameraEnabled.value = !isCameraEnabled.value;
  }

  void startTalking() {
    if (!isMicEnabled.value || !isParticipating.value) return;
    isTalking.value = true;
  }

  void stopTalking() {
    isTalking.value = false;
  }

  void sendMessage() {
    final String text = chatTextController.text.trim();
    if (text.isEmpty) return;

    liveMessages.add(
      WebinarLiveChatModel(
        senderName: 'Arif',
        initials: 'AR',
        message: text,
        colorIndex: 0,
      ),
    );
    chatTextController.clear();
  }

  Future<bool> onWillPopLive() async {
    _chatTimer?.cancel();
    isParticipating.value = false;
    isChatFocused.value = false;
    isTalking.value = false;
    return true;
  }

  void _startLiveChat() {
    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _chatIndex++;
      liveMessages.add(_webinarMockService.randomMessage(_chatIndex));
      if (liveMessages.length > 18) {
        liveMessages.removeRange(0, liveMessages.length - 18);
      }
    });
  }
}
