import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';

class UnlockChapterDialog extends StatelessWidget {
  final String courseName;
  final int lessonCount;
  final VoidCallback onGetProTap;
  final VoidCallback onMaybeLaterTap;

  const UnlockChapterDialog({
    super.key,
    required this.courseName,
    required this.lessonCount,
    required this.onGetProTap,
    required this.onMaybeLaterTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 24.h,
      ),
      backgroundColor: AppColors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: screenSize.height * 0.9,
        ),
        child: LayoutBuilder(
          builder: (
              BuildContext context,
              BoxConstraints constraints,
              ) {
            final bool isCompactHeight =
                screenSize.height < 700;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  22.w,
                  isCompactHeight ? 22.h : 30.h,
                  22.w,
                  isCompactHeight ? 22.h : 28.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    kProUnlockDialogRadius.r,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _UnlockIllustration(
                      isCompactHeight: isCompactHeight,
                    ),
                    SizedBox(
                      height: isCompactHeight ? 18.h : 26.h,
                    ),
                    Text(
                      'unlock_this_course'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.proDialogTitle,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'unlock_course_access_description'.trParams(
                        <String, String>{
                          'coursename': courseName,
                          'lessoncount': lessonCount.toString(),
                        },
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.bodyText,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(
                      height: isCompactHeight ? 20.h : 26.h,
                    ),
                    _DialogBenefitWide(
                      text: 'all_chapters'.tr,
                      icon: Icons.menu_book_rounded,
                      iconBg: AppColors.proFeatureBlueBg,
                      iconColor: AppColors.coursesChapterBlue,
                    ),
                    SizedBox(height: 12.h),
                    _DialogBenefitWide(
                      text: 'gen_certificates'.tr,
                      icon: Icons.school_outlined,
                      iconBg: AppColors.homeLime,
                      iconColor: AppColors.primaryGreen,
                    ),
                    SizedBox(
                      height: isCompactHeight ? 24.h : 32.h,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton.primary(
                        text: 'get_pro_now'.tr,
                        icon: Icons.play_arrow_rounded,
                        onPressed: onGetProTap,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    TextButton(
                      onPressed: onMaybeLaterTap,
                      style: TextButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          44.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        'maybe_later'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UnlockIllustration extends StatelessWidget {
  const _UnlockIllustration({
    required this.isCompactHeight,
  });

  final bool isCompactHeight;

  @override
  Widget build(BuildContext context) {
    final double wrapperWidth =
    isCompactHeight ? 116.w : 132.w;

    final double wrapperHeight =
    isCompactHeight ? 104.h : 120.h;

    final double circleSize =
    isCompactHeight ? 92.w : 108.w;

    return SizedBox(
      width: wrapperWidth,
      height: wrapperHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: AppColors.homePaleGreen,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.homeLime.withValues(
                    alpha: 0.22,
                  ),
                  blurRadius: 34.r,
                  spreadRadius: 12.r,
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_rounded,
            color: AppColors.homeOrange,
            size: isCompactHeight ? 34.w : 40.w,
          ),
          Positioned(
            right: 4.w,
            bottom: 8.h,
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 4.w,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.homeNeutralShadow,
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.white,
                size: 16.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogBenefitWide extends StatelessWidget {
  const _DialogBenefitWide({
    required this.text,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String text;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.proBenefitBg,
        borderRadius: BorderRadius.circular(
          kHomePillRadius.r,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.homePrimaryText,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}