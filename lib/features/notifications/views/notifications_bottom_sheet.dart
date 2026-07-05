import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_models.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filter_chip.dart';

class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({required this.controller, super.key});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.86,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.homeBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kNotificationSheetRadius.r),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Obx(
                () => _NotificationsHeader(
                  isLoading: controller.isMarkingAllRead.value,
                  canMarkAllRead: controller.hasUnread,
                  onMarkAllRead: controller.markAllAsRead,
                ),
              ),
              SizedBox(height: 30.h),
              _FilterList(controller: controller),
              SizedBox(height: 22.h),
              Expanded(child: _NotificationList(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        );
      }

      if (controller.notifications.isEmpty) {
        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: controller.refreshNotifications,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              SizedBox(height: 100.h),
              Icon(
                Icons.notifications_off_outlined,
                size: 48.w,
                color: AppColors.bodyText,
              ),
              SizedBox(height: 14.h),
              Text(
                'No notifications found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: controller.refreshNotifications,
        child: ListView.separated(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 34.h),
          itemCount: controller.notifications.length +
              (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: 24.h),
          itemBuilder: (BuildContext context, int index) {
            if (index >= controller.notifications.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              );
            }

            final NotificationItemModel notification =
                controller.notifications[index];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.openNotification(notification),
              child: NotificationCard(notification: notification),
            );
          },
        ),
      );
    });
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.isLoading,
    required this.canMarkAllRead,
    required this.onMarkAllRead,
  });

  final bool isLoading;
  final bool canMarkAllRead;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kNotificationHeaderHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      decoration: BoxDecoration(
        color: AppColors.notificationHeaderBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kNotificationSheetRadius.r),
          bottom: Radius.circular(kNotificationSheetRadius.r),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.notifications_none_rounded,
            size: 25.w,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Notifications',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w700,
                height: 1,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          GestureDetector(
            onTap: canMarkAllRead && !isLoading ? onMarkAllRead : null,
            child: isLoading
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : Text(
                    'Mark all as read',
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      fontWeight: FontWeight.w600,
                      color: canMarkAllRead
                          ? AppColors.bodyText
                          : AppColors.bodyText.withValues(alpha: 0.45),
                    ),
                  ),
          ),
          SizedBox(width: 18.w),
          GestureDetector(
            onTap: () => Get.back<void>(),
            child: Container(
              width: kNotificationCloseSize.w,
              height: kNotificationCloseSize.w,
              decoration: const BoxDecoration(
                color: AppColors.notificationCloseBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16.w,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterList extends StatelessWidget {
  const _FilterList({required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kNotificationChipHeight.h,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        scrollDirection: Axis.horizontal,
        itemCount: controller.filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (BuildContext context, int index) {
          final NotificationFilterModel filter = controller.filters[index];
          return Obx(
            () => NotificationFilterChip(
              filter: filter,
              isSelected:
                  controller.selectedCategory.value == filter.category,
              onTap: controller.selectCategory,
            ),
          );
        },
      ),
    );
  }
}
