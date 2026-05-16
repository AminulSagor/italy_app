import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/app_home_bottom_navigation_bar.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../../../../../routes/app_routes.dart';
import '../controllers/chapter_detail_controller.dart';
import '../models/chapter_detail_models.dart';
import '../widgets/chapter_quiz_card.dart';
import '../widgets/chapter_resource_card.dart';
import '../widgets/chapter_video_card.dart';
import '../widgets/lesson_content_card.dart';

class ChapterDetailView extends GetView<ChapterDetailController> {
  final String controllerTag;

  const ChapterDetailView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  void _onBottomNavTap(int index) {
    if (index == 1) {
      return;
    }

    if (Get.isRegistered<NavbarAndAppbarWrapperController>()) {
      Get.find<NavbarAndAppbarWrapperController>().onBottomNavTap(index);
      Get.until((Route<dynamic> route) {
        return route.settings.name == AppRoutes.wrapper || route.isFirst;
      });

      if (Get.currentRoute != AppRoutes.wrapper) {
        Get.offAllNamed(AppRoutes.wrapper);
      }
      return;
    }

    Get.offAllNamed(AppRoutes.wrapper);
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
          final ChapterDetailModel? detail = controller.detail.value;

          if (controller.isLoading.value && detail == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (detail == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              kChapterHorizontalPadding.w,
              34.h,
              kChapterHorizontalPadding.w,
              160.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Header(title: detail.title, onBackTap: () => Get.back<void>()),
                SizedBox(height: 26.h),
                ChapterVideoCard(detail: detail),
                SizedBox(height: 38.h),
                LessonContentCard(lesson: detail.lessonContent),
                SizedBox(height: 38.h),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ChapterResourceCard(
                        resource: detail.resources.first,
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: ChapterResourceCard(
                        resource: detail.resources.last,
                        onTap: controller.openVocabulary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                ChapterQuizCard(
                  quiz: detail.quiz,
                  onStartTap: controller.openQuiz,
                ),
                SizedBox(height: 40.h),
                _BottomActions(
                  status: detail.quiz.status,
                  isLoading: controller.isResumeSubmitting.value,
                  onResumeTap: controller.resumeVideo,
                  onQuizTap: controller.openQuiz,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBackTap;

  const _Header({required this.title, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onBackTap,
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primaryGreen,
            size: 22.w,
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  final ChapterQuizStatus status;
  final bool isLoading;
  final VoidCallback onResumeTap;
  final VoidCallback onQuizTap;

  const _BottomActions({
    required this.status,
    required this.isLoading,
    required this.onResumeTap,
    required this.onQuizTap,
  });

  @override
  Widget build(BuildContext context) {
    if (status == ChapterQuizStatus.disabled) {
      return CustomButton.primary(
        onPressed: onResumeTap,
        text: 'Resume Video',
        isLoading: isLoading,
        icon: Icons.play_arrow_rounded,
      );
    }

    return Row(
      children: <Widget>[
        CustomButton(
          onPressed: onResumeTap,
          text: '▶  Resume',
          height: kChapterBottomButtonHeight,
          showShadow: true,
          btnColor: AppColors.white,
          btnShadowColor: AppColors.homeNeutralShadow,
          borderColor: AppColors.white,
          textColor: AppColors.homePrimaryText,
          textSize: AppFont.font16.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomButton(
            onPressed: onQuizTap,
            text: 'Take Quiz',
            icon: Icons.bolt_rounded,
            height: kChapterBottomButtonHeight,
            showShadow: true,
            btnColor: AppColors.primaryBtnColor,
            btnShadowColor: AppColors.primaryBtnShadow,
            borderColor: AppColors.primaryBtnColor,
            textColor: AppColors.limeTextColor,
            textSize: AppFont.font16.sp,
          ),
        ),
      ],
    );
  }
}
