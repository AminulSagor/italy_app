import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/widgets.dart';

class FinalExamGatewayDialogLocked extends StatelessWidget {
  final VoidCallback? onWatchMoreLessons;
  final VoidCallback? onBackToChapter;

  const FinalExamGatewayDialogLocked({
    super.key,
    this.onWatchMoreLessons,
    this.onBackToChapter,
  });

  static Future<T?> show<T>({
    VoidCallback? onWatchMoreLessons,
    VoidCallback? onBackToChapter,
  }) {
    return Get.dialog<T>(
      FinalExamGatewayDialogLocked(
        onWatchMoreLessons: onWatchMoreLessons,
        onBackToChapter: onBackToChapter,
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.34),
    );
  }

  void _close() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.6, sigmaY: 2.6),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 38.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.36),
                blurRadius: 30.r,
                offset: Offset(0, 22.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(42.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.84,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.white,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(30.w, 34.h, 30.w, 30.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/heroes/your not ready.png',
                            width: 180.w,
                          ),
                          // const _LockedIllustration(),
                          // SizedBox(height: 28.h),
                          Text(
                            'Wait! Not quite\nready.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 27.sp,
                              height: 1.12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            'You need to finish 80% of the video lessons to unlock the final exam.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppFont.font16.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF666A6D),
                            ),
                          ),
                          SizedBox(height: 34.h),
                          const _LockedProgressCard(),
                          SizedBox(height: 38.h),
                          CustomButton(
                            onPressed: onWatchMoreLessons ?? _close,
                            text: 'Watch More Lessons',
                            icon: Icons.play_circle_outline_rounded,
                            height: 58,
                            width: double.infinity,
                            showShadow: true,
                            btnColor: AppColors.primaryBtnColor,
                            btnShadowColor: AppColors.primaryBtnShadow,
                            borderColor: AppColors.primaryBtnColor,
                            textColor: AppColors.white,
                            fontSize: AppFont.font18,
                            fontWeight: FontWeight.w900,
                          ),
                          SizedBox(height: 22.h),
                          _BackToChapterButton(
                            onTap: onBackToChapter ?? _close,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 22.h,
                    right: 22.w,
                    child: GestureDetector(
                      onTap: _close,
                      child: Icon(
                        Icons.close_rounded,
                        size: 29.r,
                        color: const Color(0xFF777777),
                      ),
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

class _LockedIllustration extends StatelessWidget {
  const _LockedIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164.r,
      height: 164.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFFF9900), width: 9.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7CFF3B).withValues(alpha: 0.38),
            blurRadius: 30.r,
            spreadRadius: 3.r,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.07,
            child: Icon(
              Icons.fact_check_rounded,
              size: 90.r,
              color: const Color(0xFF5F7E42),
            ),
          ),
          Positioned(
            right: 34.w,
            bottom: 34.h,
            child: Transform.rotate(
              angle: 0.53,
              child: Icon(
                Icons.edit_rounded,
                size: 58.r,
                color: const Color(0xFF73A95B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedProgressCard extends StatelessWidget {
  const _LockedProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22.w, 21.h, 22.w, 18.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F1),
        borderRadius: BorderRadius.circular(27.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'COURSE PROGRESS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font10.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '60%',
                style: TextStyle(
                  fontSize: AppFont.font24.sp,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          const _LockedProgressBar(),
          SizedBox(height: 17.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Currently at\n60%\nwatched.',
                  style: TextStyle(
                    fontSize: AppFont.font11.sp,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF676A6D),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE9D6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 13.r,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '80% TO\nUNLOCK',
                      style: TextStyle(
                        fontSize: AppFont.font9.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockedProgressBar extends StatelessWidget {
  const _LockedProgressBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 5.h,
                child: Container(
                  height: 13.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DADB),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 5.h,
                width: width * 0.60,
                child: Container(
                  height: 13.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF237600), Color(0xFF7CFF3B)],
                    ),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              Positioned(
                top: -2.h,
                left: width * 0.80,
                child: const _DottedVerticalLine(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DottedVerticalLine extends StatelessWidget {
  const _DottedVerticalLine();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (_) => Container(
          width: 2.w,
          height: 3.h,
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFF8BA17E),
            borderRadius: BorderRadius.circular(99.r),
          ),
        ),
      ),
    );
  }
}

class _BackToChapterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackToChapterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_rounded,
            size: 18.r,
            color: const Color(0xFF62666A),
          ),
          SizedBox(width: 7.w),
          Text(
            'Back to Chapter',
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              height: 1,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF62666A),
            ),
          ),
        ],
      ),
    );
  }
}
