import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/ai_chat_controller.dart';
import '../models/ai_tutor_models.dart';
import 'widgets/ai_tutor_common_widgets.dart';
import 'widgets/ai_tutor_message_bubble.dart';

class AiTutorChatContent extends StatefulWidget {
  const AiTutorChatContent({super.key});

  @override
  State<AiTutorChatContent> createState() => _AiTutorChatContentState();
}

class _AiTutorChatContentState extends State<AiTutorChatContent> {
  final ScrollController _scrollController = ScrollController();
  late final AiChatController _controller;
  Worker? _messagesWorker;
  Worker? _loadingWorker;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AiChatController>();
    _messagesWorker = ever<List<AiTutorMessageModel>>(
      _controller.textMessages,
      (_) => _scheduleScrollToBottom(),
    );
    _loadingWorker = ever<bool>(
      _controller.isSendingMessage,
      (_) => _scheduleScrollToBottom(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    _loadingWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<AiTutorMessageModel> messages = _controller.textMessages;
      final bool loading = _controller.isSendingMessage.value;

      return ListView.builder(
        key: const ValueKey<String>('ai-tutor-chat-content'),
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 112.h),
        itemCount: messages.length + (loading ? 1 : 0) + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: const AiTutorDateChip(),
            );
          }

          final int messageIndex = index - 1;
          if (messageIndex < messages.length) {
            return AiTutorMessageBubble(message: messages[messageIndex]);
          }

          return const AiTutorThinkingBubble();
        },
      );
    });
  }
}
