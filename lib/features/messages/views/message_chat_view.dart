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
                  SizedBox(height: 14.h),
                  Expanded(
                    child: Obx(() {
                      final bool isReady = controller.isInitialScrollReady.value;

                      return Stack(
                        children: <Widget>[
                          AnimatedOpacity(
                            opacity: isReady ? 1 : 0,
                            duration: const Duration(milliseconds: 120),
                            child: IgnorePointer(
                              ignoring: !isReady,
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
                                            child: const CircularProgressIndicator(
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
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 6.h),
                                  ),
                                  SliverPadding(
                                    padding: EdgeInsets.fromLTRB(
                                      kChatMessageHorizontalPadding.w,
                                      0,
                                      kChatMessageHorizontalPadding.w,
                                      170.h,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                          final MessageChatItemModel item =
                                          chat.messages[index];

                                          final bool showDate =
                                              index == 0 ||
                                                  !_isSameDay(
                                                    chat.messages[index - 1].createdAtIso,
                                                    item.createdAtIso,
                                                  );

                                          return Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              if (showDate) ...<Widget>[
                                                SizedBox(height: 12.h),
                                                _DateChipLabel(
                                                  iso: item.createdAtIso ??
                                                      DateTime.now()
                                                          .toIso8601String(),
                                                ),
                                                SizedBox(height: 12.h),
                                              ],
                                              ChatMessageBubble(
                                                message: item,
                                                onTap: item.canCallBack
                                                    ? () => controller.callBack(item)
                                                    : null,
                                              ),
                                              SizedBox(height: 12.h),
                                            ],
                                          );
                                        },
                                        childCount: chat.messages.length,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (!isReady)
                            const Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      );
                    }),
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
      if (days == 0) return 'today'.tr;
      if (days == 1) return 'yesterday'.tr;
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return 'today'.tr;
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

  const _ChatHeader({
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          8.w,
          8.h,
          8.w,
          6.h,
        ),
        child: Row(
          children: <Widget>[
            _HeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Get.back<void>(),
              semanticLabel: 'Back',
            ),

            SizedBox(width: 2.w),

            GestureDetector(
              onTap: controller.openUserInfo,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                child: MessageAvatar(
                  imageUrl: chat.contactAvatarUrl,
                  size: 42.w,
                  showStatus: true,
                  isOnline: chat.isOnline,
                ),
              ),
            ),

            SizedBox(width: 7.w),

            // The name section gets all remaining available space.
            Expanded(
              child: GestureDetector(
                onTap: controller.openUserInfo,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chat.contactName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          color: AppColors.homePrimaryText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        chat.contactStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font11.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                          color: chat.isOnline
                              ? AppColors.primaryGreen
                              : AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 2.w),

            Obx(() {
              final bool isBlocked =
                  controller.blockStatus.value != 'none';

              if (isBlocked) {
                return _HeaderIconButton(
                  icon: Icons.info_outline_rounded,
                  onTap: controller.openUserInfo,
                  semanticLabel: 'Conversation information',
                );
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _HeaderIconButton(
                    icon: Icons.call_outlined,
                    onTap: controller.openAudioCall,
                    semanticLabel: 'Audio call',
                  ),
                  _HeaderIconButton(
                    icon: Icons.videocam_outlined,
                    onTap: controller.openVideoCall,
                    semanticLabel: 'Video call',
                  ),
                  _HeaderIconButton(
                    icon: Icons.info_outline_rounded,
                    onTap: controller.openUserInfo,
                    semanticLabel: 'Conversation information',
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: SizedBox(
            width: 42.w,
            height: 42.w,
            child: Icon(
              icon,
              size: 22.w,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
      ),
    );
  }
}
