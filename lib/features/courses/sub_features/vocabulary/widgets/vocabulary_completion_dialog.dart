import 'package:get/get.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../models/vocabulary_models.dart';

class VocabularyCompletionDialog extends StatelessWidget {
  final VocabularyCompletionModel complete;
  final VoidCallback onCloseTap;

  const VocabularyCompletionDialog({
    super.key,
    required this.complete,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: AppColors.lessonShareOverlay,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 42.h),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: onCloseTap,
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: 22.w,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Lesson Complete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 40.w),
                    ],
                  ),
                  SizedBox(height: 26.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 38.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        kVocabularyCompletionDialogRadius.r,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.limeTextColor,
                                size: 16.w,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              complete.appName,
                              style: TextStyle(
                                fontSize: AppFont.font18.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.homePrimaryText,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/decor_png/celebration_confetti.png',
                          height: 188.h,
                          width: 188.w,
                        ),
                        Text(
                          'Great Job!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font42.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                            height: 1,
                          ),
                        ),
                        Text(
                          'You reviewed ${complete.reviewedCount} words',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bodyText,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _VocabularyResultPill(
                                icon: Icons.check_circle_rounded,
                                value: '${complete.rightCount} Words',
                                label: 'gen_right'.tr.tr,
                                color: AppColors.vocabularyCompletionRightBg,
                                textColor: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: _VocabularyResultPill(
                                icon: Icons.refresh_rounded,
                                value: '${complete.wrongCount} Words',
                                label: 'gen_wrong'.tr.tr,
                                color: AppColors.vocabularyCompletionWrongBg,
                                textColor: AppColors.vocabularyStreakText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        CustomButton(
                          onPressed: onCloseTap,
                          text: 'Join the Italian journey!',
                          height: 44.h,
                          showShadow: false,
                          fontSize: 14.sp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 26.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(32.w, 14.h, 32.w, 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(9999.r),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'SHARE YOUR VICTORY',
                          style: TextStyle(
                            fontSize: AppFont.font14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.bodyText,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            _VocabularyShareCircle(
                              icon: Icons.file_download_outlined,
                            ),
                            _VocabularyShareCircle(icon: Icons.share_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VocabularyResultPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _VocabularyResultPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9999.r),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: textColor, size: 20.w),
          SizedBox(height: 4.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
              color: textColor.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyShareCircle extends StatelessWidget {
  final IconData icon;

  const _VocabularyShareCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGreen, width: 3.w),
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 24.w),
    );
  }
}
