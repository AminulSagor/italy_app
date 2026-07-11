import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';

class VocabularyExitDialog extends StatelessWidget {
  final VoidCallback onKeepGoingTap;
  final VoidCallback onQuitTap;

  const VocabularyExitDialog({
    super.key,
    required this.onKeepGoingTap,
    required this.onQuitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      backgroundColor: AppColors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 22.w,
          vertical: 28.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            kQuizExitDialogRadius.r,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 92.w,
              height: 92.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 92.w,
                    height: 92.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.homeLime,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: AppColors.primaryGreen,
                      size: 46.sp,
                    ),
                  ),
                  Positioned(
                    right: -2.w,
                    bottom: 0,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.homeOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 4.w,
                        ),
                      ),
                      child: Icon(
                        Icons.sentiment_dissatisfied_rounded,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22.h),
            Text(
              'wait_are_you_sure'.tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
                height: 1.2,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'if_you_quit_now_you_ll_lose_your_progress'.tr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 28.h),
            CustomButton.primary(
              onPressed: onKeepGoingTap,
              text: 'keep_going_1'.tr,
              icon: Icons.play_arrow_rounded,
              fontSize: AppFont.font14.sp,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              onPressed: onQuitTap,
              text: 'quit_vocabulary'.tr,
              height: 48.h,
              fontSize: AppFont.font14.sp,
              textColor: AppColors.blockDangerRed,
              btnColor: AppColors.transparent,
              borderColor: AppColors.blockDangerRed,
              showShadow: false,
            ),
          ],
        ),
      ),
    );
  }
}