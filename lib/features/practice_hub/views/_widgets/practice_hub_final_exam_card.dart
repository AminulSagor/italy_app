import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controllers/practice_hub_controller.dart';
import '../widgets/final_exam_gateway_dialog_locked.dart';
import '../widgets/final_exam_gateway_dialog_unlocked.dart';

class PracticeHubFinalExamCard extends GetView<PracticeHubController> {
  const PracticeHubFinalExamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: controller.isFinalExamReady.value
            ? _ReadyFinalExamCard(
                key: const ValueKey<String>('ready-final-exam'),
                onTap: controller.onFinalExamCardTap,
                onStartTap: () {
                  FinalExamGatewayDialogUnlocked.show(
                    onStartFinalExam: controller.onStartFinalExamTap,
                    onBackToChapter: controller.onBackToChapterFromGateway,
                  );
                },
              )
            : _LockedFinalExamCard(
                key: const ValueKey<String>('locked-final-exam'),
                onTap: controller.onFinalExamCardTap,
                onLockedButtonTap: () {
                  FinalExamGatewayDialogLocked.show(
                    onWatchMoreLessons:
                        controller.onWatchMoreLessonsFromGateway,
                    onBackToChapter: controller.onBackToChapterFromGateway,
                  );
                },
              ),
      ),
    );
  }
}

class _LockedFinalExamCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onLockedButtonTap;

  const _LockedFinalExamCard({
    super.key,
    required this.onTap,
    required this.onLockedButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 216.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF122E16),
              Color(0xFF193B13),
              Color(0xFF102914),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24.r,
              offset: Offset(0, 14.h),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -26.w,
              bottom: -42.h,
              child: Container(
                width: 180.r,
                height: 180.r,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.025),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 26.h),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 55.r,
                      height: 55.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF78FF3E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.desktop_windows_rounded,
                        size: 28.r,
                        color: const Color(0xFF102D16),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Final Exam – Esame finale',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font20.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Complete the course to unlock final exam',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font13.sp,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF85FF43),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const _ExamMiniPill(
                          text: '80% Required',
                          icon: Icons.info_outline_rounded,
                          active: true,
                        ),
                        SizedBox(width: 16.w),
                        _ExamMiniPill(
                          text: 'Locked',
                          icon: Icons.lock_rounded,
                          active: false,
                          onTap: onLockedButtonTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyFinalExamCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onStartTap;

  const _ReadyFinalExamCard({
    super.key,
    required this.onTap,
    required this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 337.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF145300),
              Color(0xFF1F6700),
              Color(0xFF123F00),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 22.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -54.w,
              bottom: -58.h,
              child: Container(
                width: 230.r,
                height: 230.r,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.035),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40.w, 32.h, 32.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 96.r,
                    height: 96.r,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 45.r,
                        height: 45.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF81FF42),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 31.r,
                          color: const Color(0xFF187000),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Text(
                    'Final Certification',
                    style: TextStyle(
                      fontSize: AppFont.font30.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Ready for your final challenge!',
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF86FF45),
                    ),
                  ),
                  const Spacer(),
                  CustomButton(
                    onPressed: onStartTap,
                    text: 'START FINAL EXAM',
                    height: 60,
                    width: double.infinity,
                    showShadow: true,
                    btnColor: AppColors.white,
                    btnShadowColor: AppColors.black,
                    borderColor: AppColors.black,
                    textColor: AppColors.black,
                    fontSize: AppFont.font16,
                    fontWeight: FontWeight.w900,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamMiniPill extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  const _ExamMiniPill({
    required this.text,
    required this.icon,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget pill = Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF153B0A)
            : AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: active
              ? const Color(0xFF2F7C16)
              : AppColors.white.withValues(alpha: 0.12),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 13.r,
            color: active ? const Color(0xFF83FF45) : const Color(0xFFA3A9A0),
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              color: active ? const Color(0xFF83FF45) : const Color(0xFFA3A9A0),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return pill;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: pill,
    );
  }
}
