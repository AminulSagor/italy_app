import '../models/message_models.dart';
import 'messages_controller.dart';

extension MessagesControllerNavigation on MessagesController {
  Future<bool> openConversationById(String conversationId) async {
    final String normalizedId = conversationId.trim();
    if (normalizedId.isEmpty) return false;

    await loadMessages();
    final int index = threads.indexWhere(
      (MessageThreadModel thread) => thread.id == normalizedId,
    );
    if (index < 0) return false;

    openChat(threads[index]);
    return true;
  }
}
