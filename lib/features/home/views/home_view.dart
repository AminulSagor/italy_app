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
import '../widgets/home_dashboard_skeleton.dart';
import '../widgets/home_info_cards.dart';
import '../widgets/learn_for_work_section.dart';
import '../widgets/quick_tools_section.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Obx(() {
          final HomeDashboardModel data =
              controller.dashboard.value;

          final bool isInitialLoading =
              controller.isInitialLoading;

          final bool hasLoadedOnce =
              controller.hasLoadedOnce.value;

          final String errorMessage =
          controller.errorMessage.value.trim();

          /*
           * First application load.
           *
           * The full dashboard is not shown yet because there is
           * no successful dashboard response available.
           */


          /*
           * First request failed.
           *
           * We show a dedicated Retry screen instead of displaying
           * fake zero values and empty Home sections.
           */
          if (!hasLoadedOnce && errorMessage.isNotEmpty) {
            return _HomeInitialErrorView(
              message: errorMessage,
              onRetry: controller.refreshDashboard,
            );
          }

          /*
           * Successfully loaded dashboard.
           *
           * During refresh, the existing dashboard remains visible
           * and a small progress indicator appears at the top.
           */
          return _HomeDashboardContent(
            data: data,
            isInitialLoading: isInitialLoading && !hasLoadedOnce,
            isRefreshing: controller.isRefreshing.value,
            refreshErrorMessage: hasLoadedOnce ? errorMessage : '',
            onRefresh: controller.refreshDashboard,
            onRetryRefresh: controller.refreshDashboard,
            onContinueChapter: controller.openCurrentChapter,
            onOpenQuickTool: controller.openQuickTool,
            onOpenCareerTracks: controller.openCareerTracks,
            onOpenCareerTrack: controller.openCareerTrack,
            onOpenWhatsAppSupport: controller.openWhatsAppSupport,
            onOpenWebinars: controller.openWebinars,
            onOpenAiTutor: controller.openAiTutor,
            onOpenDailyChallenges: controller.openDailyChallenges,
          );
        }),
      ),
    );
  }
}

class _HomeDashboardContent extends StatelessWidget {
  const _HomeDashboardContent({
    required this.data,
    required this.isInitialLoading,
    required this.isRefreshing,
    required this.refreshErrorMessage,
    required this.onRefresh,
    required this.onRetryRefresh,
    required this.onContinueChapter,
    required this.onOpenQuickTool,
    required this.onOpenCareerTracks,
    required this.onOpenCareerTrack,
    required this.onOpenWhatsAppSupport,
    required this.onOpenWebinars,
    required this.onOpenAiTutor,
    required this.onOpenDailyChallenges,
  });

  final HomeDashboardModel data;
  final bool isRefreshing;
  final String refreshErrorMessage;
  final bool isInitialLoading;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetryRefresh;

  final VoidCallback onContinueChapter;
  final ValueChanged<HomeToolModel>
  onOpenQuickTool;
  final VoidCallback onOpenCareerTracks;
  final ValueChanged<HomeWorkItemModel> onOpenCareerTrack;
  final Future<void> Function() onOpenWhatsAppSupport;
  final VoidCallback onOpenWebinars;
  final VoidCallback onOpenAiTutor;
  final VoidCallback onOpenDailyChallenges;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        final double horizontalPadding =
        _horizontalPaddingForWidth(
          constraints.maxWidth,
        );

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          backgroundColor: Colors.white,
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.only(
              bottom: 72.h,
            ),
            child: Column(
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: isRefreshing
                      ? const LinearProgressIndicator(
                    key: ValueKey<String>(
                      'home-refreshing',
                    ),
                    minHeight: 2,
                    color: AppColors.primaryGreen,
                    backgroundColor:
                    AppColors.homeProgressTrack,
                  )
                      : const SizedBox(
                    key: ValueKey<String>(
                      'home-not-refreshing',
                    ),
                    height: 2,
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16.h,
                        horizontalPadding,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          if (refreshErrorMessage.isNotEmpty) ...<
                              Widget>[
                            _HomeRefreshErrorBanner(
                              message: refreshErrorMessage,
                              onRetry: onRetryRefresh,
                            ),
                            SizedBox(height: 16.h),
                          ],

                          if (isInitialLoading)
                            const HomeOverviewSkeleton()
                          else
                            DailyOverviewSection(
                              overview: data.overview,
                            ),

                          if (isInitialLoading) ...<Widget>[
                            SizedBox(height: 20.h),
                            const HomeCurrentChapterSkeleton(),
                          ] else if (data.currentChapter != null) ...<Widget>[
                            SizedBox(height: 20.h),
                            CurrentChapterCard(
                              chapter: data.currentChapter!,
                              onContinueTap: onContinueChapter,
                            ),
                          ],

                          if (data.quickTools.isNotEmpty) ...<
                              Widget>[
                            SizedBox(
                              height:
                              kHomeSectionSpacing.h,
                            ),
                            QuickToolsSection(
                              tools: data.quickTools,
                              onToolTap: onOpenQuickTool,
                            ),
                          ],

                          if (isInitialLoading) ...<Widget>[
                            SizedBox(height: kHomeSectionSpacing.h),
                            const HomeCareerTracksSkeleton(),
                          ] else if (data.workItems.isNotEmpty) ...<Widget>[
                            SizedBox(height: kHomeSectionSpacing.h),
                            LearnForWorkSection(
                              items: data.workItems,
                              onViewAllTap: onOpenCareerTracks,
                              onItemTap: onOpenCareerTrack,
                            ),
                          ],

                          SizedBox(height: 12.h),

                          SupportCommunityCard(
                            support: data.support,
                            onTap: () {
                              onOpenWhatsAppSupport();
                            },
                          ),

                          if (isInitialLoading) ...<Widget>[
                            SizedBox(height: 12.h),
                            const HomeWebinarSkeleton(),
                          ] else if (data.webinar != null) ...<Widget>[
                            SizedBox(height: 12.h),
                            WebinarCard(
                              webinar: data.webinar!,
                              onJoinTap: onOpenWebinars,
                            ),
                          ],

                          SizedBox(height: 12.h),

                          CulturalTipCard(
                            tip: data.culturalTip,
                          ),

                          SizedBox(height: 12.h),

                          StreakCard(
                            streak: data.streak,
                          ),

                          SizedBox(height: 12.h),

                          AiTutorCard(
                            tutor: data.aiTutor,
                            onStartTap: onOpenAiTutor,
                          ),

                          SizedBox(height: 12.h),

                          DailyChallengesCard(
                            challenges:
                            data.dailyChallenges,
                            onTap:
                            onOpenDailyChallenges,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _horizontalPaddingForWidth(
      double width,
      ) {
    if (width >= 900) {
      return 32;
    }

    if (width >= 600) {
      return 24;
    }

    /*
     * Avoid using a large scaled width here because ScreenUtil
     * can produce oversized outer padding on wide devices.
     */
    return 16;
  }
}

class _HomeInitialLoadingView extends StatelessWidget {
  const _HomeInitialLoadingView();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {},
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: SizedBox(
                width: 34.r,
                height: 34.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeInitialErrorView extends StatelessWidget {
  const _HomeInitialErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: onRetry,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 32.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 58.r,
                        height: 58.r,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen
                              .withValues(
                            alpha: 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_off_rounded,
                          size: 28.r,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: const Color(
                            0xFF4E5652,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),
                        label: Text(
                          'retry'.tr,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                          AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(
                            140,
                            46,
                          ),
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeRefreshErrorBanner extends StatelessWidget {
  const _HomeRefreshErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        11,
        8,
        11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF2D5A7),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            size: 21,
            color: Color(0xFF9A6217),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF754A12),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor:
              const Color(0xFF8A5614),
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
            ),
            child: Text(
              'retry'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}