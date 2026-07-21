import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/widgets.dart';

class FinalExamGatewayDialogUnlocked extends StatelessWidget {
  const FinalExamGatewayDialogUnlocked({super.key, this.onStartFinalExam});

  final VoidCallback? onStartFinalExam;

  static Future<T?> show<T>({VoidCallback? onStartFinalExam}) {
    return Get.dialog<T>(
      FinalExamGatewayDialogUnlocked(onStartFinalExam: onStartFinalExam),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.32),
    );
  }

  void _close() {
    if (Get.isDialogOpen ?? false) {
      Get.back<void>();
    }
  }

  void _handleStartExam() {
    _close();
    onStartFinalExam?.call();
  }

  @override
  Widget build(BuildContext context) {
    final double maximumDialogHeight = MediaQuery.sizeOf(context).height * 0.78;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400.w,
            maxHeight: maximumDialogHeight,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 22.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/heroes/your ready.png',
                    width: 150.w,
                    height: 130.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'you_re_ready'.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'final_exam_unlocked_message'.tr,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF666A6D),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  const _UnlockedProgressCard(),
                  SizedBox(height: 22.h),
                  CustomButton(
                    onPressed: _handleStartExam,
                    text: 'start_final_exam'.tr,
                    icon: Icons.play_arrow_rounded,
                    height: 50,
                    width: double.infinity,
                    showShadow: true,
                    btnColor: AppColors.primaryBtnColor,
                    btnShadowColor: AppColors.primaryBtnShadow,
                    borderColor: AppColors.primaryBtnColor,
                    textColor: AppColors.white,
                    fontSize: AppFont.font16,
                    fontWeight: FontWeight.w900,
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

class _UnlockedProgressCard extends StatelessWidget {
  const _UnlockedProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F1),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'course_goal_reached'.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font10.sp,
              height: 1.2,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: <Widget>[
              Text(
                '100%',
                style: TextStyle(
                  fontSize: AppFont.font22.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF33383C),
                ),
              ),
              const Spacer(),
              Container(
                width: 22.r,
                height: 22.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 15.r,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: LinearProgressIndicator(
              value: 1,
              minHeight: 9.h,
              backgroundColor: const Color(0xFFD8DADB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7CFF3B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
