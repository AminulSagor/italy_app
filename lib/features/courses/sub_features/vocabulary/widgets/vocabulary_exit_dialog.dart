import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      insetPadding: EdgeInsets.symmetric(horizontal: 34.w),
      backgroundColor: AppColors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(34.w, 58.h, 34.w, 44.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kQuizExitDialogRadius.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: kQuizExitDialogIconSize.w,
              height: kQuizExitDialogIconSize.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: kQuizExitDialogIconSize.w,
                    height: kQuizExitDialogIconSize.w,
                    decoration: const BoxDecoration(
                      color: AppColors.homeLime,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: AppColors.primaryGreen,
                      size: 76.w,
                    ),
                  ),
                  Positioned(
                    right: -6.w,
                    bottom: 10.h,
                    child: Container(
                      width: 54.w,
                      height: 54.w,
                      decoration: BoxDecoration(
                        color: AppColors.homeOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 6.w),
                      ),
                      child: Icon(
                        Icons.sentiment_dissatisfied_rounded,
                        color: AppColors.white,
                        size: 28.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 48.h),
            Text(
              'Wait! Are you sure?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font38.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              "If you quit now, you'll lose your\nprogress.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font26.sp,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 52.h),
            CustomButton.primary(
              onPressed: onKeepGoingTap,
              text: 'Keep Going',
              icon: Icons.play_arrow_rounded,
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: onQuitTap,
              child: Container(
                height: 68.h,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                  border: Border.all(
                    color: AppColors.profileReportBorder,
                    width: 2.w,
                  ),
                ),
                child: Text(
                  'QUIT VOCABULARY',
                  style: TextStyle(
                    fontSize: AppFont.font22.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                    color: AppColors.blockDangerRed,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
