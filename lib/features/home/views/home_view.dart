import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../controllers/home_controller.dart';
import '../models/home_models.dart';
import '../widgets/current_chapter_card.dart';
import '../widgets/daily_overview_section.dart';
import '../widgets/home_action_cards.dart';
import '../widgets/home_info_cards.dart';
import '../widgets/learn_for_work_section.dart';
import '../widgets/quick_tools_section.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final HomeDashboardModel data = controller.dashboard.value;
      return Material(
        color: AppColors.homeBackground,
        child: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () => controller.loadDashboard(refresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                kHomeHorizontalPadding.w,
                22.h,
                kHomeHorizontalPadding.w,
                80.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (controller.isLoading.value &&
                      data.overview.days.isEmpty)
                    const LinearProgressIndicator(
                      color: AppColors.primaryGreen,
                      backgroundColor: AppColors.homeProgressTrack,
                    ),
                  DailyOverviewSection(overview: data.overview),
                  if (data.currentChapter != null) ...<Widget>[
                    SizedBox(height: 24.h),
                    CurrentChapterCard(
                      chapter: data.currentChapter!,
                      onContinueTap: controller.openCurrentChapter,
                    ),
                  ],
                  SizedBox(height: kHomeSectionSpacing.h),
                  QuickToolsSection(
                    tools: data.quickTools,
                    onToolTap: (_) => controller.openCvBuilder(),
                  ),
                  SizedBox(height: kHomeSectionSpacing.h),
                  LearnForWorkSection(
                    items: data.workItems,
                    onViewAllTap: controller.openCareerTracks,
                    onItemTap: controller.openCareerTrack,
                  ),
                  SizedBox(height: 26.h),
                  SupportCommunityCard(
                    support: data.support,
                    onTap: () => controller.openCommunity(),
                  ),
                  if (data.webinar != null) ...<Widget>[
                    SizedBox(height: 26.h),
                    WebinarCard(
                      webinar: data.webinar!,
                      onJoinTap: controller.openWebinars,
                    ),
                  ],
                  SizedBox(height: 26.h),
                  CulturalTipCard(tip: data.culturalTip),
                  SizedBox(height: 28.h),
                  StreakCard(streak: data.streak),
                  SizedBox(height: 28.h),
                  AiTutorCard(
                    tutor: data.aiTutor,
                    onStartTap: controller.openAiTutor,
                  ),
                  SizedBox(height: 28.h),
                  DailyChallengesCard(
                    challenges: data.dailyChallenges,
                    onTap: controller.openDailyChallenges,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
