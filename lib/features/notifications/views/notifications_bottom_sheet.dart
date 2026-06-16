import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/notifications_controller.dart';
import '../models/notification_models.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filter_chip.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

class NotificationsBottomSheet extends GetView<NotificationsController> {
  const NotificationsBottomSheet({super.key});

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
              _NotificationsHeader(onMarkAllRead: controller.markAllAsRead),
              SizedBox(height: 30.h),
              _FilterList(controller: controller),
              SizedBox(height: 22.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  }

                  final List<NotificationItemModel> notifications =
                      controller.filteredNotifications;

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 34.h),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => SizedBox(height: 24.h),
                    itemBuilder: (BuildContext context, int index) {
                      return NotificationCard(
                        notification: notifications[index],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  final VoidCallback onMarkAllRead;

  const _NotificationsHeader({required this.onMarkAllRead});

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
            onTap: onMarkAllRead,
            child: Text(
              'Mark all as read',
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyText,
              ),
            ),
          ),
          SizedBox(width: 18.w),
          GestureDetector(
            onTap: () => Get.back(),
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
  final NotificationsController controller;

  const _FilterList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kNotificationChipHeight.h,
      child: Obx(
        () => ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          scrollDirection: Axis.horizontal,
          itemCount: controller.filters.length,
          separatorBuilder: (_, _) => SizedBox(width: 12.w),
          itemBuilder: (BuildContext context, int index) {
            final NotificationFilterModel filter = controller.filters[index];
            return Obx(() {
              return NotificationFilterChip(
                filter: filter,
                isSelected:
                    controller.selectedCategory.value == filter.category,
                onTap: controller.selectCategory,
              );
            });
          },
        ),
      ),
    );
  }
}
