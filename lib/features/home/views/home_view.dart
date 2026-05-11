import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/app_home_bottom_navigation_bar.dart';
import '../../../core/widgets/app_home_top_bar.dart';
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

  static const List<AppBottomNavItem> _navItems = <AppBottomNavItem>[
    AppBottomNavItem(icon: Icons.home_rounded, semanticLabel: 'Home'),
    AppBottomNavItem(icon: Icons.menu_book_outlined, semanticLabel: 'Lessons'),
    AppBottomNavItem(icon: Icons.auto_awesome_rounded, semanticLabel: 'AI Tutor'),
    AppBottomNavItem(icon: Icons.emoji_events_outlined, semanticLabel: 'Progress'),
    AppBottomNavItem(icon: Icons.handyman_outlined, semanticLabel: 'Tools'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppTheme.homeBackground,
        bottomNavigationBar: AppHomeBottomNavigationBar(
          selectedIndex: controller.selectedNavIndex.value,
          items: _navItems,
          onTap: controller.onBottomNavTap,
        ),
        body: SafeArea(
          child: controller.isLoading.value && controller.dashboard.value == null
              ? const _HomeLoadingState()
              : _HomeLoadedBody(dashboard: controller.dashboard.value),
        ),
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: AppTheme.homeLoadingSize.w,
        height: AppTheme.homeLoadingSize.w,
        child: const CircularProgressIndicator(
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }
}

class _HomeLoadedBody extends StatelessWidget {
  final HomeDashboardModel? dashboard;

  const _HomeLoadedBody({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final HomeDashboardModel data = dashboard ?? _emptyDashboard;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppTheme.homeHorizontalPadding.w,
        16.h,
        AppTheme.homeHorizontalPadding.w,
        20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppHomeTopBar(
            greeting: data.user.greeting,
            userName: data.user.displayName,
            streakLabel: data.user.streakLabel,
            notificationCount: data.user.notificationCount,
            messageCount: data.user.messageCount,
          ),
          SizedBox(height: 30.h),
          DailyOverviewSection(overview: data.overview),
          SizedBox(height: 24.h),
          CurrentChapterCard(chapter: data.currentChapter),
          SizedBox(height: AppTheme.homeSectionSpacing.h),
          QuickToolsSection(tools: data.quickTools),
          SizedBox(height: AppTheme.homeSectionSpacing.h),
          LearnForWorkSection(items: data.workItems),
          SizedBox(height: 26.h),
          SupportCommunityCard(support: data.support),
          SizedBox(height: 26.h),
          WebinarCard(webinar: data.webinar),
          SizedBox(height: 26.h),
          CulturalTipCard(tip: data.culturalTip),
          SizedBox(height: 28.h),
          StreakCard(streak: data.streak),
          SizedBox(height: 28.h),
          AiTutorCard(tutor: data.aiTutor),
          SizedBox(height: 28.h),
          DailyChallengesCard(challenges: data.dailyChallenges),
        ],
      ),
    );
  }

  static const HomeDashboardModel _emptyDashboard = HomeDashboardModel(
    user: HomeUserModel(
      greeting: '',
      displayName: '',
      streakLabel: '',
      notificationCount: 0,
      messageCount: 0,
    ),
    overview: HomeOverviewModel(
      title: '',
      subtitle: '',
      totalTime: '',
      totalTimeLabel: '',
      activities: <HomeActivityModel>[],
    ),
    currentChapter: HomeChapterModel(
      eyebrow: '',
      title: '',
      progressLabel: '',
      progress: 0,
      buttonLabel: '',
    ),
    quickTools: <HomeToolModel>[],
    workItems: <HomeWorkItemModel>[],
    support: HomeSupportModel(title: '', subtitle: ''),
    webinar: HomeWebinarModel(
      badgeLabel: '',
      title: '',
      hostName: '',
      timeLabel: '',
      buttonLabel: '',
    ),
    culturalTip: HomeInfoCardModel(
      eyebrow: '',
      title: '',
      body: '',
      actionLabel: '',
    ),
    streak: HomeInfoCardModel(
      eyebrow: '',
      title: '',
      body: '',
      actionLabel: '',
    ),
    aiTutor: HomeInfoCardModel(
      eyebrow: '',
      title: '',
      body: '',
      actionLabel: '',
    ),
    dailyChallenges: HomeDailyChallengesModel(label: '', completed: 0, total: 0),
  );
}
