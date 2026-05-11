import 'package:get/get.dart';

import '../models/message_models.dart';
import '../services/messages_mock_service.dart';
import '../views/message_chat_view.dart';
import 'message_chat_controller.dart';

class MessagesController extends GetxController {
  final MessagesMockService _messagesMockService;

  MessagesController({required MessagesMockService messagesMockService})
    : _messagesMockService = messagesMockService;

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString currentUserName = ''.obs;
  final RxString currentUserAvatarUrl = ''.obs;
  final RxList<MessageThreadModel> threads = <MessageThreadModel>[].obs;

  List<MessageThreadModel> get filteredThreads {
    final String query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return threads;
    }

    return threads
        .where(
          (MessageThreadModel thread) =>
              thread.learnerName.toLowerCase().contains(query) ||
              thread.lastMessage.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  Future<void> loadMessages() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final MessagesResponseModel response = await _messagesMockService
          .fetchMessages();
      currentUserName.value = response.currentUserName;
      currentUserAvatarUrl.value = response.currentUserAvatarUrl;
      threads.assignAll(response.threads);
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void openChat(MessageThreadModel thread) {
    Get.to<void>(
      () => const MessageChatView(),
      binding: BindingsBuilder(() {
        Get.put<MessageChatController>(
          MessageChatController(
            thread: thread,
            messagesMockService: _messagesMockService,
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }
}
