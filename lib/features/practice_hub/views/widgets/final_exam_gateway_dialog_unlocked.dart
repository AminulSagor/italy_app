import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/widgets.dart';

class FinalExamGatewayDialogUnlocked extends StatelessWidget {
  final VoidCallback? onStartFinalExam;
  final VoidCallback? onBackToChapter;

  const FinalExamGatewayDialogUnlocked({
    super.key,
    this.onStartFinalExam,
    this.onBackToChapter,
  });

  static Future<T?> show<T>({
    VoidCallback? onStartFinalExam,
    VoidCallback? onBackToChapter,
  }) {
    return Get.dialog<T>(
      FinalExamGatewayDialogUnlocked(
        onStartFinalExam: onStartFinalExam,
        onBackToChapter: onBackToChapter,
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.34),
    );
  }

  void _close() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void _handleStartExam() {
    _close();
    onStartFinalExam?.call();
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
              child: Container(
                width: double.infinity,
                color: AppColors.white,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(30.w, 38.h, 30.w, 30.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/heroes/your ready.png', width: 220.w),
                      //const _UnlockedIllustration(),
                      //SizedBox(height: 27.h),
                      Text(
                        "You're Ready!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30.sp,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.9,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 17.h),
                      Text(
                        "You've completed 80% of the lessons. The Final Exam is\nnow unlocked!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font16.sp,
                          height: 1.34,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666A6D),
                        ),
                      ),
                      SizedBox(height: 33.h),
                      const _UnlockedProgressCard(),
                      SizedBox(height: 37.h),
                      CustomButton(
                        onPressed: _handleStartExam,
                        text: 'Start Final Exam',
                        icon: Icons.play_arrow_rounded,
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
                      SizedBox(height: 23.h),
                      _BackToChapterButton(onTap: onBackToChapter ?? _close),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlockedIllustration extends StatelessWidget {
  const _UnlockedIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168.r,
      height: 168.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE9FFE0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7CFF3B).withValues(alpha: 0.38),
            blurRadius: 32.r,
            spreadRadius: 4.r,
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
              size: 98.r,
              color: const Color(0xFF5F7E42),
            ),
          ),
          Positioned(
            right: 28.w,
            bottom: 28.h,
            child: Transform.rotate(
              angle: 0.53,
              child: Icon(
                Icons.edit_rounded,
                size: 62.r,
                color: const Color(0xFF73A95B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedProgressCard extends StatelessWidget {
  const _UnlockedProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 22.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F1),
        borderRadius: BorderRadius.circular(27.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COURSE GOAL REACHED!',
            style: TextStyle(
              fontSize: AppFont.font10.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                '100%',
                style: TextStyle(
                  fontSize: AppFont.font25.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF33383C),
                ),
              ),
              const Spacer(),
              Container(
                width: 24.r,
                height: 24.r,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 17.r,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: Container(
              height: 13.h,
              color: const Color(0xFFD8DADB),
              child: Container(
                height: 13.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF7CFF3B),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
          ),
        ],
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
