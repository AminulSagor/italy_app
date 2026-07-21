import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/widgets.dart';

class FinalExamGatewayDialogLocked extends StatelessWidget {
  const FinalExamGatewayDialogLocked({
    super.key,
    this.onWatchMoreLessons,
  });

  final VoidCallback? onWatchMoreLessons;

  static Future<T?> show<T>({
    VoidCallback? onWatchMoreLessons,
  }) {
    return Get.dialog<T>(
      FinalExamGatewayDialogLocked(
        onWatchMoreLessons: onWatchMoreLessons,
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.32),
    );
  }

  void _close() {
    if (Get.isDialogOpen ?? false) {
      Get.back<void>();
    }
  }

  void _handleWatchMoreLessons() {
    _close();
    onWatchMoreLessons?.call();
  }

  @override
  Widget build(BuildContext context) {
    final double maximumDialogHeight =
        MediaQuery.sizeOf(context).height * 0.78;

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 2.2,
        sigmaY: 2.2,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 24.h,
        ),
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
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    22.w,
                    22.h,
                    22.w,
                    24.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        'assets/heroes/your not ready.png',
                        width: 145.w,
                        height: 120.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'final_exam_not_ready_title'.tr,
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
                        'final_exam_unlock_requirement'.tr,
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
                      const _LockedProgressCard(),
                      SizedBox(height: 22.h),
                      CustomButton(
                        onPressed: _handleWatchMoreLessons,
                        text: 'watch_more_lessons'.tr,
                        icon: Icons.play_circle_outline_rounded,
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
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: IconButton(
                    onPressed: _close,
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22.r,
                      color: const Color(0xFF777777),
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

class _LockedProgressCard extends StatelessWidget {
  const _LockedProgressCard();

  static const int _currentProgress = 60;
  static const int _requiredProgress = 80;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F1),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  'course_progress'.tr,
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
              ),
              SizedBox(width: 10.w),
              Text(
                '$_currentProgress%',
                style: TextStyle(
                  fontSize: AppFont.font22.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const _LockedProgressBar(
            progress: _currentProgress / 100,
            unlockProgress: _requiredProgress / 100,
          ),
          SizedBox(height: 12.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'currently_watched_percent'.trParams(
                    <String, String>{
                      'progress': _currentProgress.toString(),
                    },
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font11.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF676A6D),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE9D6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 13.r,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'unlock_at_percent'.trParams(
                        <String, String>{
                          'progress': _requiredProgress.toString(),
                        },
                      ),
                      style: TextStyle(
                        fontSize: AppFont.font9.sp,
                        height: 1.1,
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
  const _LockedProgressBar({
    required this.progress,
    required this.unlockProgress,
  });

  final double progress;
  final double unlockProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22.h,
      child: LayoutBuilder(
        builder: (
            BuildContext context,
            BoxConstraints constraints,
            ) {
          final double availableWidth = constraints.maxWidth;
          final double progressWidth =
              availableWidth * progress.clamp(0.0, 1.0);
          final double unlockPosition =
              availableWidth * unlockProgress.clamp(0.0, 1.0);

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: 5.h,
                child: Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DADB),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 5.h,
                width: progressWidth,
                child: Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[
                        Color(0xFF237600),
                        Color(0xFF7CFF3B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
              Positioned(
                left: unlockPosition - 1.w,
                top: 0,
                child: Container(
                  width: 2.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BA17E),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}