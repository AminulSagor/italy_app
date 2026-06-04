import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_routes.dart';
import '../models/webinar_models.dart';
import '../services/webinar_agora_service.dart';
import '../services/webinar_api_service.dart';
import '../services/webinar_socket_service.dart';

class WebinarController extends GetxController {
  WebinarController({
    required WebinarApiService webinarApiService,
    required WebinarAgoraService webinarAgoraService,
    required WebinarSocketService webinarSocketService,
  }) : _webinarApiService = webinarApiService,
       agoraService = webinarAgoraService,
       _webinarSocketService = webinarSocketService;

  final WebinarApiService _webinarApiService;
  final WebinarAgoraService agoraService;
  final WebinarSocketService _webinarSocketService;

  final RxBool isLoading = false.obs;
  final RxBool isJoining = false.obs;
  final RxBool isRequesting = false.obs;
  final RxBool isLeaving = false.obs;
  final RxBool isParticipating = false.obs;
  final RxBool isChatFocused = false.obs;
  final RxBool isTalking = false.obs;

  final RxList<WebinarItemModel> liveWebinars = <WebinarItemModel>[].obs;
  final RxList<WebinarItemModel> upcomingWebinars = <WebinarItemModel>[].obs;
  final RxList<WebinarLiveChatModel> liveMessages =
      <WebinarLiveChatModel>[].obs;
  final Rxn<WebinarItemModel> selectedWebinar = Rxn<WebinarItemModel>();
  final Rxn<WebinarParticipantModel> currentParticipant =
      Rxn<WebinarParticipantModel>();
  final RxInt participantsTotal = 0.obs;
  final RxString speakerRequestStatus = 'none'.obs;

  final TextEditingController chatTextController = TextEditingController();

  List<WebinarLiveChatModel> get latestStageMessages {
    if (liveMessages.length <= 3) return liveMessages.toList(growable: false);
    return liveMessages
        .sublist(liveMessages.length - 3)
        .toList(growable: false);
  }

  bool get isSpeakerPending => speakerRequestStatus.value == 'pending';
  bool get isSpeakerGranted => speakerRequestStatus.value == 'granted';

  @override
  void onInit() {
    super.onInit();
    _seedChatMessages();
    loadWebinars();
  }

  @override
  void onClose() {
    chatTextController.dispose();
    _webinarSocketService.disconnect();
    agoraService.leaveChannel();
    super.onClose();
  }

  Future<void> loadWebinars() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final ApiResult<WebinarListResponseModel> liveResult =
          await ApiErrorHandler.call(
        () => _webinarApiService.getLiveWebinars(),
      );
      if (liveResult.isSuccess && liveResult.data != null) {
        liveWebinars.assignAll(liveResult.data!.webinars);
      }

      final ApiResult<WebinarListResponseModel> upcomingResult =
          await ApiErrorHandler.call(
        () => _webinarApiService.getUpcomingWebinars(),
      );
      if (upcomingResult.isSuccess && upcomingResult.data != null) {
        upcomingWebinars.assignAll(upcomingResult.data!.webinars);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openLiveSession(WebinarItemModel webinar) async {
    if (isJoining.value) return;

    isJoining.value = true;
    try {
      selectedWebinar.value = webinar;
      final ApiResult<WebinarJoinResultModel> result =
          await ApiErrorHandler.call(
        () => _webinarApiService.joinWebinar(webinarId: webinar.id),
      );
      if (!result.isSuccess || result.data == null) return;

      currentParticipant.value = result.data!.participant;
      speakerRequestStatus.value = result.data!.participant.canSpeak
          ? 'granted'
          : 'none';
      await agoraService.joinAsAudience(result.data!.token);
      _connectSocket(webinar.id);
      await loadParticipants(webinar.id);
      Get.toNamed(AppRoutes.webinarLive);
    } finally {
      isJoining.value = false;
    }
  }

  Future<void> loadParticipants(String webinarId) async {
    final ApiResult<WebinarParticipantsResponseModel> result =
        await ApiErrorHandler.call(
      () => _webinarApiService.getParticipants(webinarId: webinarId),
      showError: false,
    );
    if (result.isSuccess && result.data != null) {
      participantsTotal.value = result.data!.pagination.totalItems;
    }
  }

  Future<void> requestToParticipate() async {
    final WebinarItemModel? webinar = selectedWebinar.value;
    if (webinar == null || isRequesting.value || isSpeakerPending) return;

    isRequesting.value = true;
    try {
      final ApiResult<void> result = await ApiErrorHandler.call(
        () => _webinarApiService.requestToSpeak(webinarId: webinar.id),
      );
      if (result.isSuccess) {
        speakerRequestStatus.value = 'pending';
      }
    } finally {
      isRequesting.value = false;
    }
  }

  void backToParticipation() {
    isChatFocused.value = false;
    isParticipating.value = isSpeakerGranted;
  }

  void openChatMode() {
    isChatFocused.value = true;
    isParticipating.value = false;
  }

  Future<void> stopParticipation() async {
    final WebinarItemModel? webinar = selectedWebinar.value;
    if (webinar == null || isLeaving.value) return;

    isLeaving.value = true;
    try {
      final ApiResult<WebinarParticipantModel> result =
          await ApiErrorHandler.call(
        () => _webinarApiService.leaveStage(webinarId: webinar.id),
      );
      if (!result.isSuccess) return;
      currentParticipant.value = result.data;
      speakerRequestStatus.value = 'none';
      isParticipating.value = false;
      isTalking.value = false;
      await agoraService.demoteToAudience();
    } finally {
      isLeaving.value = false;
    }
  }

  Future<void> toggleMic() async {
    await agoraService.toggleMic();
    if (!agoraService.isMicEnabled.value) isTalking.value = false;
  }

  Future<void> toggleCamera() async {
    await agoraService.toggleCamera();
  }

  Future<void> switchCamera() async {
    await agoraService.switchCamera();
  }

  void startTalking() {
    if (!agoraService.isMicEnabled.value || !isParticipating.value) return;
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
        senderName: 'You',
        initials: 'YO',
        message: text,
      ),
    );
    chatTextController.clear();
  }

  Future<bool> onWillPopLive() async {
    final bool? shouldLeave = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Leave webinar?'),
        content: const Text('Are you sure you want to leave this webinar?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return false;
    await leaveLiveWebinar();
    return true;
  }

  Future<void> leaveLiveWebinar() async {
    final WebinarItemModel? webinar = selectedWebinar.value;
    if (webinar == null) return;

    await ApiErrorHandler.call(
      () => _webinarApiService.leaveWebinar(webinarId: webinar.id),
      showError: false,
    );
    _webinarSocketService.leaveRoom(webinar.id);
    _webinarSocketService.disconnect();
    await agoraService.leaveChannel();
    isParticipating.value = false;
    isChatFocused.value = false;
    isTalking.value = false;
    speakerRequestStatus.value = 'none';
    currentParticipant.value = null;
    selectedWebinar.value = null;
    await loadWebinars();
  }

  Future<void> _promoteToSpeaker(String webinarId) async {
    final ApiResult<AgoraTokenModel> tokenResult = await ApiErrorHandler.call(
      () => _webinarApiService.getSpeakerToken(webinarId: webinarId),
    );
    if (!tokenResult.isSuccess || tokenResult.data == null) return;

    await agoraService.promoteToSpeaker(tokenResult.data!);
    speakerRequestStatus.value = 'granted';
    isParticipating.value = true;
    isChatFocused.value = false;
  }

  void _connectSocket(String webinarId) {
    _webinarSocketService.connect(
      webinarId: webinarId,
      onWebinarEnded: () async {
        await leaveLiveWebinar();
        if (Get.currentRoute == AppRoutes.webinarLive) Get.back<void>();
      },
      onParticipantUpdated: (WebinarParticipantModel participant) {
        loadParticipants(webinarId);
        _updateCurrentParticipant(participant);
      },
      onSpeakerApproved: (WebinarParticipantModel participant) {
        if (!_isCurrentUser(participant.userId)) return;
        currentParticipant.value = participant;
        _promoteToSpeaker(webinarId);
      },
      onSpeakerRejected: (WebinarParticipantModel participant) async {
        if (!_isCurrentUser(participant.userId)) return;
        currentParticipant.value = participant;
        speakerRequestStatus.value = 'none';
        isParticipating.value = false;
        await agoraService.demoteToAudience();
      },
    );
  }

  void _updateCurrentParticipant(WebinarParticipantModel participant) {
    if (!_isCurrentUser(participant.userId)) return;
    currentParticipant.value = participant;
    if (participant.canSpeak) speakerRequestStatus.value = 'granted';
  }

  bool _isCurrentUser(String userId) {
    return currentParticipant.value?.userId == userId;
  }

  void _seedChatMessages() {
    liveMessages.assignAll(const <WebinarLiveChatModel>[
      WebinarLiveChatModel(
        senderName: 'Host',
        initials: 'HO',
        message: 'Welcome everyone to the live webinar.',
        isHost: true,
        colorIndex: 1,
      ),
    ]);
  }
}
