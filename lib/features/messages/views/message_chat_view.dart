import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/message_chat_controller.dart';
import '../models/message_models.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/message_avatar.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class MessageChatView extends GetView<MessageChatController> {
  const MessageChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: Obx(() {
        final MessageChatModel? chat = controller.chat.value;

        if (controller.isLoading.value && chat == null) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (chat == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: controller.refreshChat,
                child: CustomScrollView(
                  controller: controller.chatScrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(child: _ChatHeader(chat: chat)),
                    SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                    Obx(
                      () => controller.isLoadingMore.value
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 12.h,
                                  bottom: 8.h,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SliverToBoxAdapter(child: _DateChip()),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        kChatMessageHorizontalPadding.w,
                        0,
                        kChatMessageHorizontalPadding.w,
                        170.h,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((
                          BuildContext context,
                          int index,
                        ) {
                          if (index.isOdd) {
                            return SizedBox(height: 32.h);
                          }

                          return ChatMessageBubble(
                            message: chat.messages[index ~/ 2],
                          );
                        }, childCount: (chat.messages.length * 2) - 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: ChatInputBar()),
          ],
        );
      }),
    );
  }
}

class _ChatHeader extends GetView<MessageChatController> {
  final MessageChatModel chat;

  const _ChatHeader({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 36.h, 24.w, 0),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Get.back<void>(),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 18.w,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(width: 22.w),
          GestureDetector(
            onTap: controller.openUserInfo,
            child: MessageAvatar(
              imageUrl: chat.contactAvatarUrl,
              size: 48.w,
              showStatus: true,
              isOnline: chat.isOnline,
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: GestureDetector(
              onTap: controller.openUserInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    chat.contactName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    chat.contactStatus,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _HeaderAction(
            icon: Icons.call_outlined,
            onTap: controller.openAudioCall,
          ),
          SizedBox(width: 20.w),
          _HeaderAction(
            icon: Icons.videocam_outlined,
            onTap: controller.openVideoCall,
          ),
          SizedBox(width: 20.w),
          _HeaderAction(
            icon: Icons.info_outline_rounded,
            onTap: controller.openUserInfo,
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderAction({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: AppColors.primaryGreen, size: 26.w),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.chatDateChipBg,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
        ),
        child: Text(
          'TODAY',
          style: TextStyle(
            fontSize: AppFont.font10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.bodyText,
          ),
        ),
      ),
    );
  }
}
