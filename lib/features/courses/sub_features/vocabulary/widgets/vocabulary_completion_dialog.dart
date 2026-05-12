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
              padding: EdgeInsets.fromLTRB(22.w, 48.h, 22.w, 42.h),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: onCloseTap,
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: 40.w,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Lesson Complete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font30.sp,
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
                              width: 34.w,
                              height: 34.w,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.limeTextColor,
                                size: 20.w,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              complete.appName,
                              style: TextStyle(
                                fontSize: AppFont.font28.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.homePrimaryText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 46.h),
                        Text('🎉', style: TextStyle(fontSize: 150.sp)),
                        SizedBox(height: 42.h),
                        Text(
                          'Great Job!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font56.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'You reviewed ${complete.reviewedCount} words',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font26.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bodyText,
                          ),
                        ),
                        SizedBox(height: 38.h),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _VocabularyResultPill(
                                icon: Icons.check_circle_rounded,
                                value: '${complete.rightCount} Words',
                                label: 'RIGHT',
                                color: AppColors.vocabularyCompletionRightBg,
                                textColor: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: _VocabularyResultPill(
                                icon: Icons.refresh_rounded,
                                value: '${complete.wrongCount} Words',
                                label: 'WRONG',
                                color: AppColors.vocabularyCompletionWrongBg,
                                textColor: AppColors.vocabularyStreakText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 34.h),
                        SizedBox(
                          width: 296.w,
                          child: CustomButton(
                            onPressed: onCloseTap,
                            text: 'Join the Italian journey!',
                            height: 58,
                            width: double.infinity,
                            showShadow: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 46.h),
                  Container(
                    width: double.infinity,
                    height: kVocabularyCompletionShareCardHeight.h,
                    padding: EdgeInsets.fromLTRB(36.w, 34.h, 36.w, 38.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        kVocabularyCompletionDialogRadius.r,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'SHARE YOUR VICTORY',
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.bodyText,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            _VocabularyShareCircle(icon: Icons.file_download_outlined),
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
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(kRadius38.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: textColor, size: 34.w),
          SizedBox(height: 8.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
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
      width: 78.w,
      height: 78.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGreen, width: 4.w),
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 34.w),
    );
  }
}
