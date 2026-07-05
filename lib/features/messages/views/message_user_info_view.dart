import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/message_user_info_controller.dart';
import '../models/message_models.dart';
import '../widgets/profile_safety_action_card.dart';
import '../widgets/profile_stat_card.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class MessageUserInfoView extends GetView<MessageUserInfoController> {
  const MessageUserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Obx(() {
          final MessageUserProfileModel? profile = controller.profile.value;

          if (controller.isLoading.value && profile == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (profile == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 42.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _InfoHeader(),
                SizedBox(height: 24.h),
                Center(child: _ProfileHero(profile: profile)),
                SizedBox(height: 32.h),
                _StatsSection(profile: profile),
                SizedBox(height: 32.h),
                Text(
                  'safety_actions'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.2,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 16.h),
                _SafetyActions(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoHeader extends StatelessWidget {
  const _InfoHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back<void>(),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.homeNeutralShadow,
                      blurRadius: 18.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.homePrimaryText,
                  size: 24.w,
                ),
              ),
            ),
          ),
          Text(
            'user_info'.tr,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final MessageUserProfileModel profile;

  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: kProfileAvatarSize.w,
          height: kProfileAvatarSize.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: kProfileAvatarSize.w,
                height: kProfileAvatarSize.w,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.homeLime,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    profile.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              if (profile.statusLabel == 'ONLINE')
                Positioned(
                  right: 0,
                  bottom: 2.h,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: AppColors.homeLime,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.homeBackground,
                        width: 3.w,
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryGreen,
                      size: 14.w,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font30.sp,
            fontWeight: FontWeight.w800,
            height: 1,
            color: AppColors.primaryGreen,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 90.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: profile.statusLabel == 'online'.tr
                ? AppColors.homeLime
                : AppColors.chatInputBg,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Text(
            profile.statusLabel,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: profile.statusLabel == 'online'.tr
                  ? AppColors.primaryGreen
                  : AppColors.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final MessageUserProfileModel profile;

  const _StatsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ProfileStatCard(
            icon: Icons.local_fire_department_rounded,
            value: profile.streakValue,
            label: 'gen_current_streak'.tr,
            backgroundColor: AppColors.profileOrangeCardBg,
            textColor: AppColors.profileOrangeText,
            iconColor: AppColors.notificationOrange,
          ),
        ),
        SizedBox(width: 22.w),
        Expanded(
          child: ProfileStatCard(
            icon: Icons.flash_on_rounded,
            value: profile.xpValue,
            label: 'gen_total_earned'.tr,
            backgroundColor: AppColors.profileBlueCardBg,
            textColor: AppColors.profileBlueText,
            iconColor: AppColors.profileBlueText,
          ),
        ),
      ],
    );
  }
}

class _SafetyActions extends GetView<MessageUserInfoController> {
  const _SafetyActions();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isBlocked = controller.blockStatus.value == 'blocked_by_me' ||
          controller.blockStatus.value == 'both_blocked';
      return Row(
        children: <Widget>[
          Expanded(
            child: ProfileSafetyActionCard(
              icon: Icons.block_rounded,
              title: isBlocked ? 'unblock_user'.tr : 'block_user'.tr,
              subtitle: 'gen_stop_contact'.tr,
              isBlockedAction: isBlocked,
              onTap: isBlocked
                  ? controller.openUnblockUserSheet
                  : controller.openBlockUserSheet,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: ProfileSafetyActionCard(
              icon: Icons.warning_amber_rounded,
              title: 'gen_report_profile'.tr,
              subtitle: 'gen_notify_admin'.tr,
              isDashed: true,
              onTap: controller.openReportUser,
            ),
          ),
        ],
      );
    });
  }
}
