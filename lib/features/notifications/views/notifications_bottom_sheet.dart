import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
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
      heightFactor: 0.78,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.homeBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
              SizedBox(height: 14.h),
              _FilterList(controller: controller),
              SizedBox(height: 14.h),
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
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: <Widget>[
              SizedBox(height: 70.h),
              Icon(
                Icons.notifications_off_outlined,
                size: 40.w,
                color: AppColors.bodyText,
              ),
              SizedBox(height: 10.h),
              Text(
                'no_notifications_found'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
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
          padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
          itemCount:
              controller.notifications.length +
              (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (BuildContext context, int index) {
            if (index >= controller.notifications.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Center(
                  child: SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.primaryGreen,
                    ),
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
      height: 68.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.notificationHeaderBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
          bottom: Radius.circular(18.r),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow.withValues(alpha: 0.55),
            blurRadius: 14.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.notifications_none_rounded,
            size: 22.w,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'notifications'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canMarkAllRead && !isLoading ? onMarkAllRead : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
              child: isLoading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : Text(
                      'mark_all_as_read'.tr,
                      style: TextStyle(
                        fontSize: AppFont.font12.sp,
                        fontWeight: FontWeight.w600,
                        color: canMarkAllRead
                            ? AppColors.bodyText
                            : AppColors.bodyText.withValues(alpha: 0.4),
                      ),
                    ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.back<void>(),
            child: Container(
              width: 32.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.notificationCloseBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 17.w,
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
      height: 38.h,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: controller.filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (BuildContext context, int index) {
          final NotificationFilterModel filter = controller.filters[index];

          return Obx(
            () => NotificationFilterChip(
              filter: filter,
              isSelected: controller.selectedCategory.value == filter.category,
              onTap: controller.selectCategory,
            ),
          );
        },
      ),
    );
  }
}
