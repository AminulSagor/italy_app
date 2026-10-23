import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../models/daily_challenge_models.dart';

class DailyChallengeDetailsView extends StatelessWidget {
  const DailyChallengeDetailsView({super.key, required this.task});

  final DailyChallengeTaskModel task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _DetailsHeader(onBack: () => Get.back<void>()),
                        SizedBox(height: 18.h),
                        _ChallengeHero(task: task),
                        SizedBox(height: 16.h),
                        _HowToCompleteCard(task: task),
                        SizedBox(height: 14.h),
                        const _AutomaticProgressNote(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Material(
          color: AppColors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onBack,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 42.r,
              height: 42.r,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22.r,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'challenge_details'.tr,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChallengeHero extends StatelessWidget {
  const _ChallengeHero({required this.task});

  final DailyChallengeTaskModel task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primaryGreen, Color(0xFF174B24)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.20),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _detailsIcon(task.taskKey),
                  size: 27.r,
                  color: AppColors.homeLime,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _StatusPill(task: task),
                    SizedBox(height: 9.h),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: AppFont.font20.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'your_progress'.tr,
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white.withValues(alpha: 0.82),
                ),
              ),
              Text(
                '${task.progressValue}/${task.targetValue}${task.unit}',
                style: TextStyle(
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: task.progress,
              minHeight: 9.h,
              backgroundColor: AppColors.white.withValues(alpha: 0.20),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.homeLime,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: <Widget>[
              Icon(
                Icons.bolt_rounded,
                size: 19.r,
                color: const Color(0xFFFFC15A),
              ),
              SizedBox(width: 4.w),
              Text(
                'challenge_reward'.trParams(<String, String>{
                  'xp': task.rewardXp.toString(),
                }),
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.task});

  final DailyChallengeTaskModel task;

  @override
  Widget build(BuildContext context) {
    final String label = switch (task.status) {
      DailyChallengeTaskStatus.inProgress => 'in_progress'.tr,
      DailyChallengeTaskStatus.completed => 'ready_to_claim'.tr,
      DailyChallengeTaskStatus.claimed => 'completed'.tr,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppFont.font10.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.homeLime,
        ),
      ),
    );
  }
}

class _HowToCompleteCard extends StatelessWidget {
  const _HowToCompleteCard({required this.task});

  final DailyChallengeTaskModel task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE1E8DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.homePaleGreen,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.route_rounded,
                  size: 21.r,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  'how_to_complete'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            task.details.isEmpty
                ? 'challenge_details_unavailable'.tr
                : task.details,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AutomaticProgressNote extends StatelessWidget {
  const _AutomaticProgressNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: AppColors.homePaleGreen.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            size: 20.r,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'challenge_progress_updates_automatically'.tr,
              style: TextStyle(
                fontSize: AppFont.font12.sp,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _detailsIcon(String taskKey) {
  if (taskKey.contains('audio') || taskKey.contains('listen')) {
    return Icons.headphones_rounded;
  }
  if (taskKey.contains('word') || taskKey.contains('flashcard')) {
    return Icons.style_rounded;
  }
  if (taskKey.contains('quiz') || taskKey.contains('answer')) {
    return Icons.quiz_rounded;
  }
  if (taskKey.contains('video')) return Icons.play_circle_fill_rounded;
  if (taskKey.contains('minute')) return Icons.schedule_rounded;
  if (taskKey.contains('xp')) return Icons.bolt_rounded;
  return Icons.flag_rounded;
}
