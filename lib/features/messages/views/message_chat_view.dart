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
      floatingActionButton: Obx(() {
        if (controller.showScrollToBottom.value) {
          return Padding(
            padding: EdgeInsets.only(bottom: 100.h),
            child: FloatingActionButton(
              backgroundColor: AppColors.white,
              mini: true,
              onPressed: controller.scrollToBottom,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primaryGreen,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
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
              child: Column(
                children: <Widget>[
                  _ChatHeader(chat: chat),
                  SizedBox(height: 32.h),
                  Expanded(
                    child: CustomScrollView(
                      controller: controller.chatScrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: <Widget>[
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
                              : const SliverToBoxAdapter(
                                  child: SizedBox.shrink(),
                                ),
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
                              final int i = index;
                              final MessageChatItemModel item =
                                  chat.messages[i];

                              // determine if we need a date chip before this message
                              final bool showDate =
                                  i == 0 ||
                                  !_isSameDay(
                                    chat.messages[i - 1].createdAtIso,
                                    item.createdAtIso,
                                  );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  if (showDate) ...<Widget>[
                                    SizedBox(height: 12.h),
                                    _DateChipLabel(
                                      iso:
                                          item.createdAtIso ??
                                          DateTime.now().toIso8601String(),
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                  ChatMessageBubble(message: item),
                                  SizedBox(height: 12.h),
                                ],
                              );
                            }, childCount: chat.messages.length),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: ChatInputBar()),
          ],
        );
      }),
    );
  }
}

bool _isSameDay(String? aIso, String? bIso) {
  try {
    if (aIso == null || bIso == null) return false;
    final DateTime a = DateTime.parse(aIso).toLocal();
    final DateTime b = DateTime.parse(bIso).toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  } catch (_) {
    return false;
  }
}

class _DateChipLabel extends StatelessWidget {
  final String iso;

  const _DateChipLabel({required this.iso});

  String _labelForIso(String iso) {
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      final DateTime now = DateTime.now();
      final Duration diff = DateTime(
        now.year,
        now.month,
        now.day,
      ).difference(DateTime(dt.year, dt.month, dt.day));
      final int days = -diff.inDays;
      if (days == 0) return 'TODAY';
      if (days == 1) return 'YESTERDAY';
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return 'TODAY';
    }
  }

  String _monthName(int m) {
    const List<String> names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[(m - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    final String label = _labelForIso(iso);
    return Center(
      child: Container(
        width: 120.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.chatDateChipBg,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppFont.font10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.bodyText,
          ),
        ),
      ),
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
          Obx(() {
            final bool blocked = controller.blockStatus.value != 'none';
            if (blocked) return const SizedBox.shrink();
            return Row(
              children: <Widget>[
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
              ],
            );
          }),
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
