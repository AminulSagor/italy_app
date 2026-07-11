import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

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

  const ChapterDetailView({
    super.key,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  void _onBottomNavTap(int index) {
    if (index == 1) {
      return;
    }

    if (Get.isRegistered<NavbarAndAppbarWrapperController>()) {
      Get.find<NavbarAndAppbarWrapperController>()
          .onBottomNavTap(index);

      Get.until((Route<dynamic> route) {
        return route.settings.name == AppRoutes.wrapper ||
            route.isFirst;
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
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.lesson,
      sourceId: 'chapter_detail_view',
      child: Scaffold(
        backgroundColor: AppColors.coursesDetailBg,
        bottomNavigationBar: AppHomeBottomNavigationBar(
          selectedIndex: 1,
          items: AppHomeBottomNavigationBar.defaultItems,
          onTap: _onBottomNavTap,
        ),
        body: SafeArea(
          bottom: false,
          child: Obx(() {
            final ChapterDetailModel? detail =
                controller.detail.value;

            if (controller.isLoading.value &&
                detail == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            if (detail == null) {
              return const SizedBox.shrink();
            }

            return SingleChildScrollView(
              controller: controller.scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                kChapterHorizontalPadding.w,
                20.h,
                kChapterHorizontalPadding.w,
                120.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Header(
                    title: detail.title,
                    onBackTap: () => Get.back<void>(),
                  ),
                  SizedBox(height: 20.h),

                  if (detail.hasVideo) ...<Widget>[
                    ChapterVideoCard(
                      detail: detail,
                      playbackCommand:
                      controller.videoPlaybackCommand.value,
                      shouldPlay:
                      controller.shouldPlayVideo.value,
                      loadVideoUrl: controller.loadVideoUrl,
                      onPlaybackChanged:
                      controller.onVideoPlaybackChanged,
                      onProgressChanged: (
                          Duration position,
                          Duration duration,
                          ) {
                        controller.recordVideoProgress(
                          position: position,
                          duration: duration,
                        );
                      },
                    ),
                    SizedBox(height: 24.h),
                  ],

                  if (detail.hasLessonContent) ...<Widget>[
                    LessonContentCard(
                      lesson: detail.lessonContent!,
                      audio: detail.audio,
                      loadAudioUrl: controller.loadAudioUrl,
                      onAudioCompleted:
                      controller.recordAudioCompleted,
                    ),
                    SizedBox(height: 24.h),
                  ],

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ChapterResourceCard(
                          resource: detail.theoryBook,
                          onTap: controller.openTheoryBook,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: ChapterResourceCard(
                          resource: detail.vocabulary,
                          onTap: controller.openVocabulary,
                        ),
                      ),
                    ],
                  ),

                  if (detail.quiz != null) ...<Widget>[
                    SizedBox(height: 26.h),
                    ChapterQuizCard(
                      quiz: detail.quiz!,
                      onStartTap: controller.openQuiz,
                    ),
                    SizedBox(height: 26.h),
                    _BottomActions(
                      status: detail.quiz!.status,
                      hasVideo: detail.hasVideo,
                      isLoading:
                      controller.isResumeSubmitting.value,
                      isVideoPlaying:
                      controller.isVideoPlaying.value,
                      onResumeTap:
                      controller.toggleVideoPlayback,
                      onQuizTap: controller.openQuiz,
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBackTap;

  const _Header({
    required this.title,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onBackTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryGreen,
              size: 22.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
              height: 1.25,
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
  final bool hasVideo;
  final bool isVideoPlaying;
  final VoidCallback onResumeTap;
  final VoidCallback onQuizTap;

  const _BottomActions({
    required this.status,
    required this.isLoading,
    required this.hasVideo,
    required this.isVideoPlaying,
    required this.onResumeTap,
    required this.onQuizTap,
  });

  @override
  Widget build(BuildContext context) {
    if (status == ChapterQuizStatus.disabled) {
      return CustomButton.primary(
        onPressed: hasVideo ? onResumeTap : () {},
        text: hasVideo
            ? isVideoPlaying
            ? 'pause'.tr
            : 'resume_video'.tr
            : 'video_not_given'.tr,
        isLoading: isLoading,
        icon: hasVideo
            ? isVideoPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded
            : Icons.lock_outline_rounded,
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            onPressed: hasVideo ? onResumeTap : () {},
            text: hasVideo
                ? isVideoPlaying
                ? 'pause'.tr
                : 'resume_video'.tr
                : 'video_not_given'.tr,
            icon: hasVideo
                ? isVideoPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded
                : Icons.lock_outline_rounded,
            height: kChapterBottomButtonHeight,
            showShadow: true,
            btnColor: AppColors.white,
            btnShadowColor: AppColors.homeNeutralShadow,
            borderColor: AppColors.white,
            textColor: AppColors.homePrimaryText,
            fontSize: AppFont.font14.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomButton(
            onPressed: onQuizTap,
            text: 'take_quiz'.tr,
            icon: Icons.bolt_rounded,
            height: kChapterBottomButtonHeight,
            showShadow: true,
            btnColor: AppColors.primaryBtnColor,
            btnShadowColor: AppColors.primaryBtnShadow,
            borderColor: AppColors.primaryBtnColor,
            textColor: AppColors.limeTextColor,
            fontSize: AppFont.font14.sp,
          ),
        ),
      ],
    );
  }
}