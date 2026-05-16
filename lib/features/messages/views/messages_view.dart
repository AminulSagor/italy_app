import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/messages_controller.dart';
import '../models/message_models.dart';
import '../widgets/message_avatar.dart';
import '../widgets/message_search_field.dart';
import '../widgets/message_thread_card.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

class MessagesView extends GetView<MessagesController> {
  final VoidCallback onBackTap;

  const MessagesView({super.key, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        bottom: false,
        child: Obx(
          () => controller.isLoading.value && controller.threads.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        kMessageScreenHorizontalPadding.w,
                        28.h,
                        kMessageScreenHorizontalPadding.w,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _MessagesHeader(
                          userName: controller.currentUserName.value,
                          userAvatarUrl: controller.currentUserAvatarUrl.value,
                          onBackTap: onBackTap,
                          onSearchChanged: controller.onSearchChanged,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        kMessageScreenHorizontalPadding.w,
                        40.h,
                        kMessageScreenHorizontalPadding.w,
                        150.h,
                      ),
                      sliver: _MessagesList(
                        threads: controller.filteredThreads,
                        onThreadTap: controller.openChat,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  final String userName;
  final String userAvatarUrl;
  final VoidCallback onBackTap;
  final ValueChanged<String> onSearchChanged;

  const _MessagesHeader({
    required this.userName,
    required this.userAvatarUrl,
    required this.onBackTap,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            MessageAvatar(imageUrl: userAvatarUrl, size: 40),
            SizedBox(width: 14.w),
            Text(
              userName,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.homePrimaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: 46.h),
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: onBackTap,
              child: Container(
                width: kMessageBackButtonSize.w,
                height: kMessageBackButtonSize.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 32.w,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
            SizedBox(width: 24.w),
            Expanded(
              child: Text(
                'Messages',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font48.sp,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -2.4,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
        MessageSearchField(onChanged: onSearchChanged),
      ],
    );
  }
}

class _MessagesList extends StatelessWidget {
  final List<MessageThreadModel> threads;
  final ValueChanged<MessageThreadModel> onThreadTap;

  const _MessagesList({required this.threads, required this.onThreadTap});

  @override
  Widget build(BuildContext context) {
    final int childCount = threads.isEmpty ? 0 : (threads.length * 2) - 1;

    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if (index.isOdd) {
          return SizedBox(height: 28.h);
        }

        final MessageThreadModel thread = threads[index ~/ 2];
        return MessageThreadCard(
          thread: thread,
          onTap: () => onThreadTap(thread),
        );
      }, childCount: childCount),
    );
  }
}
