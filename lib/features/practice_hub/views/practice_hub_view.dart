import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/widgets.dart';
import '../../courses/models/course_models.dart';
import '../../courses/services/courses_api_service.dart';
import '../controllers/practice_hub_controller.dart';
import 'widgets/final_exam_gateway_dialog_locked.dart';
import 'widgets/final_exam_gateway_dialog_unlocked.dart';

class PracticeHubView extends GetView<PracticeHubController> {
  const PracticeHubView({super.key});

  @override
  PracticeHubController get controller {
    if (Get.isRegistered<PracticeHubController>()) {
      return Get.find<PracticeHubController>();
    }
    return Get.put<PracticeHubController>(
      PracticeHubController(coursesApiService: Get.find<CoursesApiService>()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 14.h, bottom: 122.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HorizontalPadding(
              child: _SectionTitleRow(
                title: 'Practice Hub – Courses',
                actionText: 'View All',
                onActionTap: controller.onViewAllCoursesTap,
              ),
            ),
            SizedBox(height: 24.h),
            const _CourseCarousel(),
            SizedBox(height: 47.h),

            const _HorizontalPadding(
              child: _SectionTitleOnly(title: 'Skill Builders'),
            ),
            SizedBox(height: 24.h),
            const _HorizontalPadding(child: _SkillBuilderGrid()),
            SizedBox(height: 46.h),

            const _HorizontalPadding(
              child: _SectionTitleOnly(title: 'Specialized Learning'),
            ),
            SizedBox(height: 24.h),
            const _HorizontalPadding(child: _FinalExamCard()),
            SizedBox(height: 42.h),

            const _HorizontalPadding(
              child: _SectionTitleOnly(title: 'Upcoming Webinars'),
            ),
            SizedBox(height: 20.h),
            const _HorizontalPadding(child: _WebinarCard()),
          ],
        ),
      ),
    );
  }
}

class _HorizontalPadding extends StatelessWidget {
  final Widget child;

  const _HorizontalPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding.w),
      child: child,
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;

  const _SectionTitleRow({
    required this.title,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 23.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: const Color(0xFF2E3337),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        GestureDetector(
          onTap: onActionTap,
          child: Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitleOnly extends StatelessWidget {
  final String title;

  const _SectionTitleOnly({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24.sp,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
        color: const Color(0xFF2E3337),
      ),
    );
  }
}

class _CourseCarousel extends GetView<PracticeHubController> {
  const _CourseCarousel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 252.h,
      child: Obx(() {
        if (controller.isCoursesLoading.value && controller.courses.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (controller.courses.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding.w),
            child: const _EmptyCoursesCard(),
          );
        }

        return ListView.separated(
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: kHomeHorizontalPadding.w,
            right: 24.w,
            bottom: 10.h,
          ),
          itemCount: controller.courses.length,
          separatorBuilder: (_, _) => SizedBox(width: 16.w),
          itemBuilder: (BuildContext context, int index) {
            final CourseCardModel course = controller.courses[index];
            final bool isActive = course.state == CourseCardState.active;

            return _CourseCard(
              title: course.title,
              subtitle: course.subtitle,
              status: course.statusLabel,
              progress: course.progress,
              icon: Icons.menu_book_rounded,
              isActive: isActive,
              isLocked: course.state == CourseCardState.locked,
              onTap: () => controller.onCourseTap(index),
            );
          },
        );
      }),
    );
  }
}

class _EmptyCoursesCard extends StatelessWidget {
  const _EmptyCoursesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 238.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(38.r),
        border: Border.all(color: const Color(0xFFE4E4E4), width: 1.2.w),
      ),
      child: Text(
        'No active courses found.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppFont.font16.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF6B6D70),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final double progress;
  final IconData icon;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const _CourseCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progress,
    required this.icon,
    required this.isActive,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isActive
        ? const Color(0xFF207400)
        : AppColors.white;
    final Color titleColor = isActive
        ? AppColors.white
        : const Color(0xFF6B6D70);
    final Color subtitleColor = isActive
        ? AppColors.white.withValues(alpha: 0.82)
        : const Color(0xFFA4A6A8);
    final Color labelColor = isActive
        ? AppColors.white
        : const Color(0xFF8D9092);
    final Color iconBg = isActive
        ? AppColors.white.withValues(alpha: 0.22)
        : const Color(0xFFE8E9EA);
    final Color iconColor = isActive
        ? AppColors.white
        : const Color(0xFF777B7E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 264.w,
        height: 238.h,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(38.r),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFFE4E4E4),
            width: 1.2.w,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isActive
                  ? const Color(0xFF124D00)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isActive ? 0 : 14.r,
              offset: Offset(0, isActive ? 6.h : 5.h),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 22.h,
              left: 22.w,
              child: Container(
                width: 51.r,
                height: 51.r,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 25.r, color: iconColor),
              ),
            ),
            Positioned(
              top: 22.h,
              right: 22.w,
              child: _CourseStatusChip(
                status: status,
                isActive: isActive,
                isLocked: isLocked,
              ),
            ),
            Positioned(
              left: 22.w,
              right: 22.w,
              bottom: 25.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 23.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                  SizedBox(height: 27.h),
                  Row(
                    children: <Widget>[
                      Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontSize: AppFont.font10.sp,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: labelColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: AppFont.font11.sp,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 9.h),
                  _ProgressLine(progress: progress, isActive: isActive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseStatusChip extends StatelessWidget {
  final String status;
  final bool isActive;
  final bool isLocked;

  const _CourseStatusChip({
    required this.status,
    required this.isActive,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF8BFF4F) : const Color(0xFFE6E7E8),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isLocked) ...<Widget>[
            Icon(
              Icons.lock_outline_rounded,
              size: 10.r,
              color: const Color(0xFF777B7E),
            ),
            SizedBox(width: 3.w),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
              color: isActive
                  ? const Color(0xFF197100)
                  : const Color(0xFF6E7275),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final double progress;
  final bool isActive;

  const _ProgressLine({required this.progress, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        height: 12.h,
        color: isActive
            ? AppColors.white.withValues(alpha: 0.32)
            : const Color(0xFFE6E7E8),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(height: 12.h, color: const Color(0xFF80FF43)),
        ),
      ),
    );
  }
}

class _SkillBuilderGrid extends GetView<PracticeHubController> {
  const _SkillBuilderGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridView.builder(
        itemCount: controller.skillBuilders.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 18.h,
          childAspectRatio: 1.43,
        ),
        itemBuilder: (BuildContext context, int index) {
          final Map<String, dynamic> item = controller.skillBuilders[index];

          return _SkillBuilderCard(
            title: item['title'] as String,
            icon: item['icon'] as IconData,
            background: item['background'] as Color,
            accent: item['accent'] as Color,
            iconColor: item['iconColor'] as Color,
            textColor: item['textColor'] as Color,
            onTap: () => controller.onSkillBuilderTap(item['title'] as String),
          );
        },
      ),
    );
  }
}

class _SkillBuilderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color background;
  final Color accent;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SkillBuilderCard({
    required this.title,
    required this.icon,
    required this.background,
    required this.accent,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            top: 7.h,
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(42.r),
              ),
            ),
          ),
          Positioned.fill(
            bottom: 7.h,
            child: Container(
              padding: EdgeInsets.fromLTRB(10.w, 18.h, 10.w, 18.h),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(42.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 31.r, color: iconColor),
                  SizedBox(height: 18.h),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalExamCard extends GetView<PracticeHubController> {
  const _FinalExamCard();

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
                onTap: controller.toggleFinalExamMockState,
                onStartTap: () {
                  FinalExamGatewayDialogUnlocked.show(
                    onStartFinalExam: controller.onStartFinalExamTap,
                    onBackToChapter: controller.onBackToChapterFromGateway,
                  );
                },
              )
            : _LockedFinalExamCard(
                key: const ValueKey<String>('locked-final-exam'),
                onTap: controller.toggleFinalExamMockState,
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

class _WebinarCard extends GetView<PracticeHubController> {
  const _WebinarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          const _LiveNowPill(),
          SizedBox(height: 15.h),
          Text(
            'Business Italian Masterclass',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.45,
              color: const Color(0xFF2F3337),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Join live sessions with native Italian\nexperts to master professional\nterminology and etiquette.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              height: 1.42,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6A6F73),
            ),
          ),
          SizedBox(height: 19.h),
          CustomButton(
            onPressed: controller.onViewAllSessionsTap,
            text: 'View All Sessions  →',
            height: 43,
            width: double.infinity,
            btnColor: AppColors.primaryGreen,
            borderColor: AppColors.primaryGreen,
            textColor: AppColors.white,
            fontSize: AppFont.font16,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 15.h),
          CustomButton(
            onPressed: controller.onNotifyMeTap,
            text: 'Notify Me',
            prefixIcon: Icons.notifications_none_rounded,
            height: 45,
            width: double.infinity,
            btnColor: AppColors.white,
            borderColor: const Color(0xFFDCDDDE),
            textColor: const Color(0xFF707477),
            fontSize: AppFont.font16,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

class _LiveNowPill extends StatelessWidget {
  const _LiveNowPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31.h,
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF8C9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7.r,
            height: 7.r,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'LIVE NOW',
            style: TextStyle(
              fontSize: AppFont.font15.sp,
              height: 1,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
