import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
// import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_font.dart';
import '../../courses/services/courses_api_service.dart';
import '../controllers/practice_hub_controller.dart';
import '../models/practice_hub_models.dart';
import 'widgets/final_exam_gateway_dialog_locked.dart';
import 'widgets/final_exam_gateway_dialog_unlocked.dart';
import '../services/practice_hub_api_service.dart';
import '_widgets/practice_hub_course_carousel.dart';
import '_widgets/practice_hub_final_exam_card.dart';
import '_widgets/practice_hub_skill_builder_grid.dart';
import '_widgets/practice_hub_webinar_card.dart';

class PracticeHubView extends GetView<PracticeHubController> {
  const PracticeHubView({super.key});

  @override
  PracticeHubController get controller {
    if (Get.isRegistered<PracticeHubController>()) {
      return Get.find<PracticeHubController>();
    }
    return Get.put<PracticeHubController>(
      PracticeHubController(
        coursesApiService: Get.find<CoursesApiService>(),
        practiceHubApiService: Get.find<PracticeHubApiService>(),
      ),
    );
  }

  Future<void> _handleFinalExamAction(
      PracticeFinalExamCourseModel exam,
      ) async {
    switch (exam.action) {
      case PracticeFinalExamAction.startExam:
      case PracticeFinalExamAction.retakeExam:
        FinalExamGatewayDialogUnlocked.show(
          onStartFinalExam: () async {
            if (Get.isDialogOpen ?? false) {
              Get.back<void>();
            }

            await controller.onFinalExamCardTap(exam);
          },
        );
        return;

      case PracticeFinalExamAction.locked:
        _showLockedFinalExamDialog(exam);
        return;

      case PracticeFinalExamAction.resultPending:
      case PracticeFinalExamAction.viewResult:
      case PracticeFinalExamAction.viewCertificate:
        await controller.onFinalExamCardTap(exam);
        return;
    }
  }

  void _showLockedFinalExamDialog(
      PracticeFinalExamCourseModel exam,
      ) {
    FinalExamGatewayDialogLocked.show<void>(
      onWatchMoreLessons: () async {
        if (Get.isDialogOpen ?? false) {
          Get.back<void>();
        }

        await controller.openCourseFromFinalExam(exam);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: controller.refreshPracticeHub,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.only(top: 14.h, bottom: 122.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _HorizontalPadding(
                child: _SectionTitleRow(
                  title: 'gen_practice_hub_courses'.tr,
                  actionText: 'gen_view_all'.tr,
                  onActionTap: controller.onViewAllCoursesTap,
                ),
              ),
              SizedBox(height: 24.h),
              const PracticeHubCourseCarousel(),
              SizedBox(height: 24.h),

              _HorizontalPadding(
                child: _SectionTitleOnly(title: 'gen_skill_builders'.tr),
              ),
              SizedBox(height: 24.h),
              const _HorizontalPadding(child: PracticeHubSkillBuilderGrid()),
              SizedBox(height: 24.h),

              Obx(() {
                if (controller.isFinalExamsLoading.value &&
                    controller.finalExamCourses.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 22.h),
                    child: const _HorizontalPadding(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  );
                }

                if (controller.finalExamCourses.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _HorizontalPadding(
                      child: _SectionTitleOnly(
                        title: 'gen_specialized_learning'.tr,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ...controller.finalExamCourses.map((
                      PracticeFinalExamCourseModel exam,
                    ) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          kHomeHorizontalPadding.w,
                          0,
                          kHomeHorizontalPadding.w,
                          20.h,
                        ),
                        child: PracticeHubFinalExamCard(
                          exam: exam,
                          onTap: () {
                            _handleFinalExamAction(exam);
                          },
                          onStartTap: () {
                            _handleFinalExamAction(exam);
                          },
                          onWatchMoreLessonsTap: () {
                            _showLockedFinalExamDialog(exam);
                          },
                        ),
                      );
                    }),
                    SizedBox(height: 2.h),
                  ],
                );
              }),

              _HorizontalPadding(
                child: _SectionTitleOnly(title: 'gen_upcoming_webinars'.tr),
              ),
              SizedBox(height: 20.h),
              const _HorizontalPadding(child: PracticeHubWebinarCard()),
            ],
          ),
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
