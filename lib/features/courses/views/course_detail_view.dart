import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/widgets/app_home_bottom_navigation_bar.dart';
import '../../../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/course_detail_controller.dart';
import '../models/course_models.dart';
import '../sub_features/pro_checkout/widgets/unlock_chapter_dialog.dart';
import '../widgets/course_chapter_card.dart';
import '../widgets/course_detail_header.dart';
import '../widgets/course_final_exam_card.dart';
import '../widgets/course_pro_banner.dart';

class CourseDetailView extends GetView<CourseDetailController> {
  final String controllerTag;

  const CourseDetailView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  void _showUnlockChapterDialog() {
    Get.dialog<void>(
      UnlockChapterDialog(
        courseName: controller.detail.value?.title ?? controller.course.title,
        lessonCount: controller.detail.value?.lessonCount ?? 0,
        onGetProTap: () {
          if (Get.isDialogOpen ?? false) {
            Get.back<void>();
          }
          Future<void>.delayed(
            const Duration(milliseconds: 100),
            controller.openProOrderSummary,
          );
        },
        onMaybeLaterTap: () => Get.back<void>(),
      ),
      barrierColor: AppColors.black.withValues(alpha: 0.34),
    );
  }

  void _onBottomNavTap(int index) {
    if (Get.isRegistered<NavbarAndAppbarWrapperController>()) {
      Get.find<NavbarAndAppbarWrapperController>().onBottomNavTap(index);
    }

    Get.until((Route<dynamic> route) {
      return route.settings.name == AppRoutes.wrapper || route.isFirst;
    });

    if (Get.currentRoute != AppRoutes.wrapper) {
      Get.offAllNamed(AppRoutes.wrapper);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      bottomNavigationBar: AppHomeBottomNavigationBar(
        selectedIndex: 1,
        items: AppHomeBottomNavigationBar.defaultItems,
        onTap: _onBottomNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final CourseDetailModel? detail = controller.detail.value;

          if (controller.isLoading.value && detail == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (detail == null) {
            return const SizedBox.shrink();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  kCoursesHorizontalPadding.w,
                  32.h,
                  kCoursesHorizontalPadding.w,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: CourseDetailHeader(
                    title: detail.title,
                    progressLabel: detail.progressLabel,
                    onBackTap: () => Get.back<void>(),
                  ),
                ),
              ),
              if (!detail.isFree && !detail.isProEnabled)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    kCoursesHorizontalPadding.w,
                    30.h,
                    kCoursesHorizontalPadding.w,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: CourseProBanner(
                      isLoading: controller.isProSubmitting.value,
                      courseName: detail.title,
                      lessonCount: detail.lessonCount,
                      onGetProTap: _showUnlockChapterDialog,
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  kCoursesHorizontalPadding.w,
                  30.h,
                  kCoursesHorizontalPadding.w,
                  0,
                ),
                sliver: detail.chapters.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyLessonsCard())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, int index) {
                            if (index.isOdd) {
                              return SizedBox(height: 18.h);
                            }

                            final CourseChapterModel chapter =
                                detail.chapters[index ~/ 2];
                            return CourseChapterCard(
                              chapter: chapter,
                              onTap: () => controller.openChapter(chapter),
                            );
                          },
                          childCount: (detail.chapters.length * 2) - 1,
                        ),
                      ),
              ),
              if (detail.finalExam.isConfigured)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    kCoursesHorizontalPadding.w,
                    30.h,
                    kCoursesHorizontalPadding.w,
                    130.h,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: CourseFinalExamCard(
                      finalExam: detail.finalExam,
                      onTap:
                      detail.finalExam.canStart || detail.finalExam.hasCertificate
                          ? controller.handleFinalExamTap
                          : null,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(child: SizedBox(height: 130.h)),
            ],
          );
        }),
      ),
    );
  }
}
class _EmptyLessonsCard extends StatelessWidget {
  const _EmptyLessonsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
      ),
      child: Text(
        'no_published_lessons_found_for_this_course_yet'.tr,
        textAlign: TextAlign.center,
      ),
    );
  }
}
