import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/job_sentences_controller.dart';
import '../../models/job_track_models.dart';
import '_widgets/job_intro_video_card.dart';
import '_widgets/job_track_card_palette.dart';
import 'job_phrase_details_view.dart';

class JobDetailsView extends GetView<JobSentencesController> {
  const JobDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final JobCareerTrackDetailsModel? details =
              controller.trackDetails.value;
          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () => controller.loadCareerTrackDetails(showError: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 48.h),
              child: Column(
                children: <Widget>[
                  _JobDetailsHeader(
                    title: details?.title ??
                        controller.selectedTrack.value?.title ??
                        'Career Track',
                  ),
                  SizedBox(height: 21.h),
                  if (controller.isTrackDetailsLoading.value && details == null)
                    const _DetailsLoadingState()
                  else if (controller.trackDetailsError.value.isNotEmpty &&
                      details == null)
                    _DetailsMessageState(
                      message: controller.trackDetailsError.value,
                      onRetry: () => controller.loadCareerTrackDetails(),
                    )
                  else if (details != null)
                    _CareerTrackContent(details: details)
                  else
                    const _DetailsMessageState(
                      message: 'Career track details are unavailable.',
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CareerTrackContent extends GetView<JobSentencesController> {
  const _CareerTrackContent({required this.details});

  final JobCareerTrackDetailsModel details;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (details.description.isNotEmpty) ...<Widget>[
          Text(
            details.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF767B7F),
            ),
          ),
          SizedBox(height: 20.h),
        ],
        if (details.introVideo?.isAvailable ?? false) ...<Widget>[
          JobIntroVideoCard(
            videoUrl: details.introVideo!.url,
            initialProgressPercent: details.trackProgress.videoWatchPercent,
            onProgress: (int percent, int seconds) {
              controller.recordVideoProgress(
                watchedPercent: percent,
                timeSpentSeconds: seconds,
              );
            },
          ),
          SizedBox(height: 28.h),
        ],
        _TrackProgressCard(progress: details.progress),
        SizedBox(height: 28.h),
        if (details.modules.isEmpty)
          const _DetailsMessageState(
            message: 'No sentence modules are available for this track.',
          )
        else
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int crossAxisCount = constraints.maxWidth >= 640 ? 3 : 2;
              final double spacing = 17.w;
              final double itemWidth =
                  (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;
              final double itemHeight = itemWidth < 158.w ? 190.h : 184.h;
              final JobTrackCardPalette palette = jobTrackCardPalette(
                details.cardColor,
                fallback: const Color(0xFFB2D4FF),
              );

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: details.modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: itemHeight,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return _JobModuleCard(
                    item: details.modules[index],
                    palette: palette,
                    icon: _moduleIcon(index),
                  );
                },
              );
            },
          ),
        SizedBox(height: 34.h),
        _TheoryBookCard(details: details),
      ],
    );
  }
}

class _JobDetailsHeader extends GetView<JobSentencesController> {
  const _JobDetailsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 61.h,
      child: Row(
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
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          SizedBox(width: 48.r),
        ],
      ),
    );
  }
}

class _TrackProgressCard extends StatelessWidget {
  const _TrackProgressCard({required this.progress});

  final JobLearningSummaryModel progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50.r,
            height: 50.r,
            decoration: const BoxDecoration(
              color: Color(0xFFE5FFD7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up_rounded,
              size: 26.r,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${progress.learnedSentences} of ${progress.totalSentences} sentences learned',
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF303539),
                  ),
                ),
                SizedBox(height: 9.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: progress.completionPercent / 100,
                    minHeight: 6.h,
                    backgroundColor: const Color(0xFFE4E7E6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Text(
            '${progress.completionPercent}%',
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobModuleCard extends GetView<JobSentencesController> {
  const _JobModuleCard({
    required this.item,
    required this.palette,
    required this.icon,
  });

  final JobModuleModel item;
  final JobTrackCardPalette palette;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.openModule(item),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 13.h),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(34.r),
          border: Border.all(color: palette.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: palette.iconSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 25.r, color: palette.accent),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D3236),
                    ),
                  ),
                  if (item.subtitleBn.isNotEmpty) ...<Widget>[
                    SizedBox(height: 4.h),
                    Text(
                      item.subtitleBn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font11.sp,
                        color: const Color(0xFF6F7478),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 6.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${item.learnedSentenceCount}/${item.sentenceCount} learned',
                maxLines: 1,
                style: TextStyle(
                  fontSize: AppFont.font11.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TheoryBookCard extends GetView<JobSentencesController> {
  const _TheoryBookCard({required this.details});

  final JobCareerTrackDetailsModel details;

  @override
  Widget build(BuildContext context) {
    final JobTrackCardPalette palette = jobTrackCardPalette(
      details.cardColor,
      fallback: const Color(0xFFB2D4FF),
    );
    final JobMediaFileModel? resource = details.theoryResource;
    final bool isAvailable = resource?.isAvailable ?? false;

    return GestureDetector(
      onTap: isAvailable ? controller.openTheoryBook : null,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 126.h),
        padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 22.h),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(color: palette.border, width: 2.w),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 28.r,
                color: palette.accent,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Theory Book',
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w900,
                      color: palette.accent,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    isAvailable
                        ? (resource!.originalName.isEmpty
                              ? 'Open supplementary material'
                              : resource.originalName)
                        : 'Theory resource not provided',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w600,
                      color: palette.accent.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isAvailable
                  ? Icons.chevron_right_rounded
                  : Icons.remove_circle_outline_rounded,
              size: 28.r,
              color: palette.accent.withValues(alpha: 0.72),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsLoadingState extends StatelessWidget {
  const _DetailsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 140.h),
      child: const CircularProgressIndicator(color: AppColors.primaryGreen),
    );
  }
}

class _DetailsMessageState extends StatelessWidget {
  const _DetailsMessageState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

IconData _moduleIcon(int index) {
  const List<IconData> icons = <IconData>[
    Icons.record_voice_over_rounded,
    Icons.groups_rounded,
    Icons.receipt_long_rounded,
    Icons.forum_rounded,
    Icons.support_agent_rounded,
    Icons.task_alt_rounded,
  ];
  return icons[index % icons.length];
}
class JobPhraseDetailsView extends StatelessWidget {
  const JobPhraseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const JobPhraseDetailsScreen();
  }
}

