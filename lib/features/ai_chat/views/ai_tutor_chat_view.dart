import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
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
              child: Column(
                children: <Widget>[
                  const AiTutorDateChip(),
                  SizedBox(height: 12.h),
                  _AdaptiveTutorStatusCard(controller: _controller),
                ],
              ),
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

class _AdaptiveTutorStatusCard extends StatelessWidget {
  const _AdaptiveTutorStatusCard({required this.controller});

  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    final String? level = controller.learnerProfile.value?.finalLevel;
    final int memoryCount = controller.conversationMemoryFacts.length;
    final int mistakeCount = controller.recentMistakeTags.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8ED),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: .12),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_alt_rounded,
              size: 19.r,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  level == null ? 'Adaptive tutor active' : 'Level $level tutor',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF26312E),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  controller.adaptiveModeLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF68736E),
                  ),
                ),
                if (memoryCount > 0 || mistakeCount > 0) ...<Widget>[
                  SizedBox(height: 7.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 5.h,
                    children: <Widget>[
                      if (memoryCount > 0)
                        _StatusPill(
                          icon: Icons.memory_rounded,
                          label: '$memoryCount remembered',
                        ),
                      if (mistakeCount > 0)
                        _StatusPill(
                          icon: Icons.auto_fix_high_rounded,
                          label: '$mistakeCount focus areas',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 11.r, color: AppColors.primaryGreen),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF53615C),
            ),
          ),
        ],
      ),
    );
  }
}

