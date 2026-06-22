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
        child: Obx(() {
          if (controller.isLoading.value && controller.threads.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (controller.hasError.value && controller.threads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 48.w,
                    color: AppColors.homePrimaryText,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      color: AppColors.bodyText,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: controller.refreshMessages,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshMessages,
            color: AppColors.primaryGreen,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
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
                      onBackTap: onBackTap,
                      onSearchChanged: controller.onSearchChanged,
                    ),
                  ),
                ),
                if (controller.searchQuery.value.trim().isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      kMessageScreenHorizontalPadding.w,
                      12.h,
                      kMessageScreenHorizontalPadding.w,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Obx(() {
                        if (controller.isSearching.value) {
                          return SizedBox(
                            height: 80.h,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          );
                        }

                        final List<Map<String, dynamic>> results =
                            controller.searchResults;
                        if (results.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: results
                              .map(
                                (Map<String, dynamic> u) => _SearchUserItem(
                                  user: u,
                                  onTap: () =>
                                      controller.startDirectConversation(u),
                                ),
                              )
                              .toList(growable: false),
                        );
                      }),
                    ),
                  ),
                if (controller.threads.isEmpty && !controller.isLoading.value)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64.w,
                            color: AppColors.bodyText.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              fontSize: AppFont.font18.sp,
                              color: AppColors.bodyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      kMessageScreenHorizontalPadding.w,
                      24.h,
                      kMessageScreenHorizontalPadding.w,
                      24.h,
                    ),
                    sliver: _MessagesList(
                      threads: controller.filteredThreads,
                      onThreadTap: controller.openChat,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final ValueChanged<String> onSearchChanged;

  const _MessagesHeader({
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
          return SizedBox(height: 20.h);
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

class _SearchUserItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const _SearchUserItem({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String name =
        user['fullName']?.toString() ?? user['name']?.toString() ?? 'User';
    final String avatar =
        user['avatarUrl']?.toString() ?? 'https://i.pravatar.cc/120?img=12';
    final bool isOnline = user['isOnline'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: <Widget>[
            MessageAvatar(imageUrl: avatar, size: 44),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.bodyText),
          ],
        ),
      ),
    );
  }
}
