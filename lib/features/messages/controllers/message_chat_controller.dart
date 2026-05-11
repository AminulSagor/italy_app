import 'package:get/get.dart';

import '../models/message_models.dart';
import '../services/messages_mock_service.dart';
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
