import 'package:get/get.dart';

import '../models/message_models.dart';
import '../services/messages_mock_service.dart';
import '../sub-feature/call/  views/message_call_view.dart';
import '../sub-feature/call/controllers/message_call_controller.dart';
import '../sub-feature/call/models/ message_call_models.dart';
import '../sub-feature/call/service/message_call_mock_service.dart';
import '../views/message_user_info_view.dart';
import 'message_user_info_controller.dart';

class MessageChatController extends GetxController {
  final MessageThreadModel thread;
  final MessagesMockService _messagesMockService;

  MessageChatController({
    required this.thread,
    required MessagesMockService messagesMockService,
  }) : _messagesMockService = messagesMockService;

  final RxBool isLoading = false.obs;
  final Rxn<MessageChatModel> chat = Rxn<MessageChatModel>();

  @override
  void onInit() {
    super.onInit();
    loadChat();
  }

  Future<void> loadChat() async {
    isLoading.value = true;
    try {
      chat.value = await _messagesMockService.fetchChat(thread);
    } finally {
      isLoading.value = false;
    }
  }

  void openAudioCall() {
    _openCall(MessageCallType.audio);
  }

  void openVideoCall() {
    _openCall(MessageCallType.video);
  }

  void _openCall(MessageCallType callType) {
    final MessageChatModel? currentChat = chat.value;

    if (currentChat == null) return;

    Get.to<void>(
          () => const MessageCallView(),
      binding: BindingsBuilder(() {
        Get.put<MessageCallController>(
          MessageCallController(
            conversationId: thread.id,
            callType: callType,
            participant: MessageCallParticipantModel(
              id: thread.id,
              name: currentChat.contactName,
              avatarUrl: currentChat.contactAvatarUrl,
              isOnline: currentChat.isOnline,
            ),
            messageCallService: MessageCallMockService(),
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }

  void openUserInfo() {
    Get.to<void>(
          () => const MessageUserInfoView(),
      binding: BindingsBuilder(() {
        Get.put<MessageUserInfoController>(
          MessageUserInfoController(
            threadId: thread.id,
            messagesMockService: _messagesMockService,
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }
}