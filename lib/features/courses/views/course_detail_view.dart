import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/widgets/app_home_bottom_navigation_bar.dart';
import '../../../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/course_detail_controller.dart';
import '../models/course_device_access_models.dart';
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
          final CourseDeviceAccessState accessState =
              controller.deviceAccessState.value;

          if (accessState == CourseDeviceAccessState.checking) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (accessState == CourseDeviceAccessState.blocked) {
            return _DeviceAccessBlocked(
              access: controller.deviceAccess.value,
              isRequesting: controller.isRequestingDeviceAccess.value,
              onBack: () => Get.back<void>(),
              onRequest: controller.requestDeviceAccess,
              onRetry: controller.loadDetail,
            );
          }

          if (accessState == CourseDeviceAccessState.error) {
            return _DeviceAccessError(
              message: controller.deviceAccessError.value,
              onBack: () => Get.back<void>(),
              onRetry: controller.loadDetail,
            );
          }

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
              if (detail.description.trim().isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    kCoursesHorizontalPadding.w,
                    12.h,
                    kCoursesHorizontalPadding.w,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _ExpandableCourseDescription(
                      description: detail.description,
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
                        delegate: SliverChildBuilderDelegate((_, int index) {
                          if (index.isOdd) {
                            return SizedBox(height: 18.h);
                          }

                          final CourseChapterModel chapter =
                              detail.chapters[index ~/ 2];
                          return CourseChapterCard(
                            chapter: chapter,
                            onTap: () => controller.openChapter(chapter),
                          );
                        }, childCount: (detail.chapters.length * 2) - 1),
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
                          detail.finalExam.canStart ||
                              detail.finalExam.canViewResult
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

class _DeviceAccessBlocked extends StatelessWidget {
  const _DeviceAccessBlocked({
    required this.access,
    required this.isRequesting,
    required this.onBack,
    required this.onRequest,
    required this.onRetry,
  });

  final CourseDeviceAccessResult? access;
  final bool isRequesting;
  final VoidCallback onBack;
  final Future<void> Function() onRequest;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final bool pending = access?.isPending ?? false;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Container(
          constraints: BoxConstraints(maxWidth: 520.w),
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF7F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phonelink_lock_rounded,
                  color: AppColors.primaryGreen,
                  size: 34,
                ),
              ),
              SizedBox(height: 20.h),
              const Text(
                'Course access is active on another device',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                pending
                    ? 'Your request is pending admin review.'
                    : 'Current device: ${access?.currentDeviceLabel ?? 'another device'}\n'
                          'Requested device: ${access?.requestedDeviceLabel ?? 'this device'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.homeSecondaryText,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isRequesting
                      ? null
                      : () => pending ? onRetry() : onRequest(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    pending
                        ? 'Check access again'
                        : isRequesting
                        ? 'Submitting…'
                        : 'Request device access',
                  ),
                ),
              ),
              TextButton(
                onPressed: onBack,
                child: const Text('Back to courses'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceAccessError extends StatelessWidget {
  const _DeviceAccessError({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.security_rounded,
              size: 44,
              color: AppColors.primaryGreen,
            ),
            SizedBox(height: 16.h),
            const Text(
              'Unable to verify this device',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 20.h),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('Try again'),
            ),
            TextButton(onPressed: onBack, child: const Text('Back to courses')),
          ],
        ),
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

class _ExpandableCourseDescription extends StatefulWidget {
  const _ExpandableCourseDescription({required this.description});

  final String description;

  @override
  State<_ExpandableCourseDescription> createState() =>
      _ExpandableCourseDescriptionState();
}

class _ExpandableCourseDescriptionState
    extends State<_ExpandableCourseDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (_isExpanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.description,
            style: const TextStyle(
              height: 1.5,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 4.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = false;
              });
            },
            child: const Text(
              'See less',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            widget.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              height: 1.5,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        SizedBox(width: 5.w),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = true;
            });
          },
          child: const Text(
            'See more',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
