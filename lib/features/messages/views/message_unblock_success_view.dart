import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/message_user_info_controller.dart';
import '../models/message_models.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';

class MessageUnblockSuccessView extends GetView<MessageUserInfoController> {
  const MessageUnblockSuccessView({super.key});

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
              padding: EdgeInsets.fromLTRB(28.w, 92.h, 28.w, 48.h),
              child: Column(
                children: <Widget>[
                  const _UnblockedHeroIcon(),
                  SizedBox(height: 78.h),
                  Text(
                    'User\nUnblocked',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font52.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                  SizedBox(height: 34.h),
                  Text(
                    '$userName has been successfully unblocked. You can now send messages and view their profile again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                      color: AppColors.modalTextGrey,
                    ),
                  ),
                  SizedBox(height: 64.h),
                  const _CommunicationRestoredCard(),
                  SizedBox(height: 50.h),
                  CustomButton.primary(
                    text: 'Back To Messages',
                    onPressed: controller.backToMessages,
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

class _UnblockedHeroIcon extends StatelessWidget {
  const _UnblockedHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196.w,
      height: 196.w,
      decoration: BoxDecoration(
        color: AppColors.unblockSuccessIconBg,
        borderRadius: BorderRadius.circular(kRadius42.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blockSuccessGlow,
            blurRadius: 60.r,
            spreadRadius: 22.r,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 132.w,
          height: 132.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(kRadius42.r),
          ),
          child: Center(
            child: Container(
              width: 66.w,
              height: 66.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: 46.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunicationRestoredCard extends StatelessWidget {
  const _CommunicationRestoredCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(34.w, 32.h, 34.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.unblockSuccessInfoBg,
        borderRadius: BorderRadius.circular(kSafetySuccessInfoCardRadius.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 74.w,
            height: 74.w,
            decoration: const BoxDecoration(
              color: AppColors.unblockSuccessIconCircle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_open_rounded,
              color: AppColors.primaryGreen,
              size: 38.w,
            ),
          ),
          SizedBox(width: 34.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Communication\nRestored',
                  style: TextStyle(
                    fontSize: AppFont.font28.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Safe learning environment maintained.',
                  style: TextStyle(
                    fontSize: AppFont.font22.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: AppColors.modalTextGrey,
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
