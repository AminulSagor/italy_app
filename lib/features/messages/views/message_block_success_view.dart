import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/message_user_info_controller.dart';
import '../models/message_models.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';

class MessageBlockSuccessView extends GetView<MessageUserInfoController> {
  const MessageBlockSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Obx(
          () {
            final MessageUserProfileModel? profile = controller.profile.value;
            final String userName = profile?.name ?? 'User';

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(30.w, 96.h, 30.w, 48.h),
              child: Column(
                children: <Widget>[
                  const _BlockedHeroIcon(),
                  SizedBox(height: 64.h),
                  Text(
                    'User Blocked',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font40.sp,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Text(
                    'Safe learning environment restored',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.modalTextGrey,
                    ),
                  ),
                  SizedBox(height: 54.h),
                  _PrivacyInfoCard(userName: userName),
                  SizedBox(height: 38.h),
                  const _SafetyStatusCards(),
                  SizedBox(height: 64.h),
                  CustomButton.primary(
                    text: 'BACK TO MESSAGE',
                    onPressed: controller.backToMessage,
                  ),
                  SizedBox(height: 28.h),
                  CustomButton(
                    text: 'UNBLOCK USER',
                    width: double.infinity,
                    height: kButtonDefaultHeight,
                    btnColor: AppColors.white,
                    borderColor: AppColors.primaryGreen,
                    textColor: AppColors.primaryGreen,
                    showShadow: false,
                    onPressed: controller.openUnblockUserSheet,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BlockedHeroIcon extends StatelessWidget {
  const _BlockedHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kSafetySuccessHeroSize.w,
      height: kSafetySuccessHeroSize.w,
      decoration: BoxDecoration(
        color: AppColors.blockSuccessIconBg,
        borderRadius: BorderRadius.circular(kRadius42.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blockSuccessGlow,
            blurRadius: 58.r,
            spreadRadius: 26.r,
          ),
        ],
      ),
      child: Icon(
        Icons.verified_user_rounded,
        color: AppColors.homePaleGreen,
        size: 88.w,
      ),
    );
  }
}

class _PrivacyInfoCard extends StatelessWidget {
  final String userName;

  const _PrivacyInfoCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: kSafetySuccessInfoCardMinHeight.h),
      padding: EdgeInsets.fromLTRB(34.w, 28.h, 28.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.blockSuccessBlueBg,
        borderRadius: BorderRadius.circular(kSafetySuccessInfoCardRadius.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 58.w,
            height: 58.w,
            decoration: const BoxDecoration(
              color: AppColors.blockSuccessBlueIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.visibility_off_outlined,
              color: AppColors.profileBlueText,
              size: 34.w,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$userName has been hidden from your app.',
                  style: TextStyle(
                    fontSize: AppFont.font22.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                    color: AppColors.blockSuccessBlueText,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'They will not be notified that you blocked them. Your privacy is our priority.',
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: AppColors.blockSuccessBlueText.withValues(alpha: 0.74),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyStatusCards extends StatelessWidget {
  const _SafetyStatusCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: _SafetyStatusCard(
            icon: Icons.lock_outline_rounded,
            title: 'SECURE',
          ),
        ),
        SizedBox(width: 26.w),
        const Expanded(
          child: _SafetyStatusCard(
            icon: Icons.shield_outlined,
            title: 'PRIVATE',
          ),
        ),
      ],
    );
  }
}

class _SafetyStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SafetyStatusCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kSafetySuccessSmallCardHeight.h,
      decoration: BoxDecoration(
        color: AppColors.messageTileInactiveBg,
        borderRadius: BorderRadius.circular(kRadius36.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: AppColors.primaryGreen, size: 34.w),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.6,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
