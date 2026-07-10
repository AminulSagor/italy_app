import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/messages_controller.dart';
import '../models/message_models.dart';
import '../widgets/message_avatar.dart';
import '../widgets/message_search_field.dart';
import '../widgets/message_thread_card.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({
    super.key,
    required this.onBackTap,
  });

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.threads.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }

          if (controller.hasError.value &&
              controller.threads.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 40.w,
                      color: AppColors.homePrimaryText,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font14.sp,
                        color: AppColors.bodyText,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                      ),
                      onPressed:
                      controller.refreshMessages,
                      child: Text(
                        'retry'.tr,
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshMessages,
            color: AppColors.primaryGreen,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent:
                AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    kMessageScreenHorizontalPadding.w,
                    16.h,
                    kMessageScreenHorizontalPadding.w,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _MessagesHeader(
                      onBackTap: onBackTap,
                      onSearchChanged:
                      controller.onSearchChanged,
                    ),
                  ),
                ),

                if (controller.searchQuery.value
                    .trim()
                    .isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      kMessageScreenHorizontalPadding.w,
                      10.h,
                      kMessageScreenHorizontalPadding.w,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Obx(() {
                        if (controller
                            .isSearching.value) {
                          return SizedBox(
                            height: 64.h,
                            child: const Center(
                              child:
                              CircularProgressIndicator(
                                color:
                                AppColors.primaryGreen,
                              ),
                            ),
                          );
                        }

                        final List<
                            Map<String, dynamic>
                        > results =
                            controller.searchResults;

                        if (results.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: results
                              .map(
                                (
                                Map<String, dynamic>
                                user,
                                ) =>
                                _SearchUserItem(
                                  user: user,
                                  onTap: () => controller
                                      .startDirectConversation(
                                    user,
                                  ),
                                ),
                          )
                              .toList(
                            growable: false,
                          ),
                        );
                      }),
                    ),
                  ),

                if (controller.threads.isEmpty &&
                    !controller.isLoading.value)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48.w,
                            color: AppColors.bodyText
                                .withValues(
                              alpha: 0.5,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'no_conversations_yet'.tr,
                            style: TextStyle(
                              fontSize:
                              AppFont.font16.sp,
                              color:
                              AppColors.bodyText,
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
                      16.h,
                      kMessageScreenHorizontalPadding.w,
                      20.h,
                    ),
                    sliver: _MessagesList(
                      threads:
                      controller.filteredThreads,
                      onThreadTap:
                      controller.openChat,
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
  const _MessagesHeader({
    required this.onBackTap,
    required this.onSearchChanged,
  });

  final VoidCallback onBackTap;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: onBackTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 42.w,
                height: 42.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22.w,
                  color:
                  AppColors.homePrimaryText,
                ),
              ),
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Text(
                'messages'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.5,
                  color:
                  AppColors.homePrimaryText,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 18.h),

        MessageSearchField(
          onChanged: onSearchChanged,
        ),
      ],
    );
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.threads,
    required this.onThreadTap,
  });

  final List<MessageThreadModel> threads;
  final ValueChanged<MessageThreadModel>
  onThreadTap;

  @override
  Widget build(BuildContext context) {
    final int childCount = threads.isEmpty
        ? 0
        : (threads.length * 2) - 1;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (
            BuildContext context,
            int index,
            ) {
          if (index.isOdd) {
            return SizedBox(height: 12.h);
          }

          final MessageThreadModel thread =
          threads[index ~/ 2];

          return MessageThreadCard(
            thread: thread,
            onTap: () => onThreadTap(thread),
          );
        },
        childCount: childCount,
      ),
    );
  }
}

class _SearchUserItem extends StatelessWidget {
  const _SearchUserItem({
    required this.user,
    required this.onTap,
  });

  final Map<String, dynamic> user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String name =
        user['fullName']?.toString() ??
            user['name']?.toString() ??
            'User';

    final String avatar =
        user['avatarUrl']?.toString() ?? '';

    final bool isOnline =
        user['isOnline'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
        ),
        child: Row(
          children: <Widget>[
            MessageAvatar(
              imageUrl: avatar,
              size: 40,
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                      AppFont.font14.sp,
                      fontWeight:
                      FontWeight.w600,
                      color: AppColors
                          .homePrimaryText,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    isOnline
                        ? 'online'.tr
                        : 'offline'.tr,
                    style: TextStyle(
                      fontSize:
                      AppFont.font12.sp,
                      color:
                      AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 22.w,
              color: AppColors.bodyText,
            ),
          ],
        ),
      ),
    );
  }
}