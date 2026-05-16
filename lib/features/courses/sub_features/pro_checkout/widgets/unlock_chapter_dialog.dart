import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';

class UnlockChapterDialog extends StatelessWidget {
  final VoidCallback onGetProTap;
  final VoidCallback onMaybeLaterTap;

  const UnlockChapterDialog({
    super.key,
    required this.onGetProTap,
    required this.onMaybeLaterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      backgroundColor: AppColors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(22.w, 34.h, 22.w, 34.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(kProUnlockDialogRadius.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 142.w,
                  height: 128.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 116.w,
                        height: 116.w,
                        decoration: BoxDecoration(
                          color: AppColors.homePaleGreen,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.homeLime.withValues(alpha: 0.22),
                              blurRadius: 42.r,
                              spreadRadius: 20.r,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.lock_rounded,
                        color: AppColors.homeOrange,
                        size: 40.w,
                      ),
                      Positioned(
                        right: 6.w,
                        bottom: 14.h,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 5.w,
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
                ),
                SizedBox(height: 34.h),
                Text(
                  'Unlock this\nChapter!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.proDialogTitle,
                    height: 1.08,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Upgrade to Pro to access all 30+\nchapters and premium features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 26.h),
                const _DialogBenefitWide(),
                SizedBox(height: 16.h),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: _DialogBenefitSmall(
                        icon: Icons.psychology_outlined,
                        label: 'AI\nPractice',
                      ),
                    ),
                    SizedBox(width: 16.w),
                    const Expanded(
                      child: _DialogBenefitSmall(
                        icon: Icons.school_outlined,
                        label: 'Certificates',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 36.h),
                CustomButton.primary(
                  text: 'Get Pro Now',
                  icon: Icons.play_arrow_rounded,
                  onPressed: onGetProTap,
                ),
                SizedBox(height: 28.h),
                GestureDetector(
                  onTap: onMaybeLaterTap,
                  child: Text(
                    'Maybe later',
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
        ),
      ),
    );
  }
}

class _DialogBenefitWide extends StatelessWidget {
  const _DialogBenefitWide();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.proBenefitBg,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.proFeatureBlueBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.coursesChapterBlue,
              size: 20.w,
            ),
          ),
          SizedBox(width: 14.w),
          Text(
            'All Chapters',
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogBenefitSmall extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DialogBenefitSmall({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.proBenefitBg,
        borderRadius: BorderRadius.circular(kRadius28.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.homeLime,
              borderRadius: BorderRadius.circular(kRadius32.r),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 18.w),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.homePrimaryText,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
