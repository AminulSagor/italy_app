import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/job_sentences_controller.dart';
import '../../models/job_track_models.dart';
import '_widgets/job_track_card_palette.dart';

class JobSentencesView extends GetView<JobSentencesController> {
  const JobSentencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.jobSentences,
      sourceId: 'job_sentences_view',
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: controller.refreshCareerTracks,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 48.h),
              child: Column(
                children: <Widget>[
                  const _JobSentencesTopBar(),
                  SizedBox(height: 28.h),
                  Text(
                    'career_tracks'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.1,
                      color: const Color(0xFF2D3236),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'gen_job_sentences'.tr,

                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8E92),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  const _CareerTrackList(),
                  SizedBox(height: 8.h),
                  const _JobTipCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JobSentencesTopBar extends GetView<JobSentencesController> {
  const _JobSentencesTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: controller.onBackTap,
          child: Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 24.r,
              color: const Color(0xFF2C3034),
            ),
          ),
        ),
      ],
    );
  }
}

class _CareerTrackList extends GetView<JobSentencesController> {
  const _CareerTrackList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isTracksLoading.value && controller.careerTracks.isEmpty) {
        return const _LoadingState();
      }

      if (controller.tracksError.value.isNotEmpty &&
          controller.careerTracks.isEmpty) {
        return _MessageState(
          message: controller.tracksError.value,
          onRetry: () => controller.loadCareerTracks(),
        );
      }

      if (controller.careerTracks.isEmpty) {
        return _MessageState(message: 'no_career_tracks_are_available'.tr);
      }

      return Column(
        children: controller.careerTracks
            .map(
              (JobCareerTrackModel item) => Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: _CareerTrackCard(item: item),
              ),
            )
            .toList(growable: false),
      );
    });
  }
}

class _CareerTrackCard extends GetView<JobSentencesController> {
  const _CareerTrackCard({required this.item});

  final JobCareerTrackModel item;

  @override
  Widget build(BuildContext context) {
    final JobTrackCardPalette palette = jobTrackCardPalette(
      item.cardColor,
      fallback: const Color(0xFFB2D4FF),
    );

    return GestureDetector(
      onTap: () => controller.openCareerTrack(item),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 136.h),
        padding: EdgeInsets.fromLTRB(25.w, 22.h, 20.w, 22.h),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(42.r),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 87.r,
              height: 87.r,
              decoration: BoxDecoration(
                color: palette.iconSurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _careerTrackIcon(item.iconKey),
                  size: 38.r,
                  color: palette.accent,
                ),
              ),
            ),
            SizedBox(width: 30.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font22.sp,
                      height: 1.16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      color: const Color(0xFF33383C),
                    ),
                  ),
                  if (item.subtitleBn.isNotEmpty) ...<Widget>[
                    SizedBox(height: 7.h),
                    Text(
                      item.subtitleBn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.font14.sp,
                        height: 1,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8A8E92),
                      ),
                    ),
                  ],
                  SizedBox(height: 9.h),
                  Text(
                    'sentences_completed'.trParams(<String, String>{
                      'learned': item.learnedSentenceCount.toString(),
                      'total': item.sentenceCount.toString(),
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font11.sp,
                      fontWeight: FontWeight.w800,
                      color: palette.accent,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 31.r,
              color: palette.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6D7276),
            ),
          ),
          if (onRetry != null) ...<Widget>[
            SizedBox(height: 10.h),
            TextButton(onPressed: onRetry, child: Text('retry'.tr)),
          ],
        ],
      ),
    );
  }
}

class _JobTipCard extends StatelessWidget {
  const _JobTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 230.h),
      padding: EdgeInsets.fromLTRB(32.w, 28.h, 32.w, 30.h),
      decoration: BoxDecoration(
        color: const Color(0xFFB2D4FF),
        borderRadius: BorderRadius.circular(42.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 22.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF005A91),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                'tip_of_the_day'.tr,
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 19.h),
          Text(
            'speak_like_a_local'.tr,
            style: TextStyle(
              fontSize: 24.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF075B92),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'practice_workplace_phrases_and_replay_their_native'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D6DA4),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _careerTrackIcon(String iconKey) {
  return switch (iconKey.trim().toLowerCase()) {
    'fork_knife' || 'restaurant' => Icons.restaurant_rounded,
    'kitchen' => Icons.soup_kitchen_rounded,
    'supermarket' || 'store' => Icons.storefront_rounded,
    'logistics' => Icons.local_shipping_rounded,
    'warehouse' => Icons.warehouse_rounded,
    'hotel' => Icons.hotel_rounded,
    'healthcare' => Icons.medical_services_rounded,
    _ => Icons.work_rounded,
  };
}
