import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../controllers/leaderboard_controller.dart';
import '../services/leaderboard_service.dart';
import 'widgets/leaderboard_header_widgets.dart';
import 'widgets/leaderboard_list_widgets.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/token_service.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  final bool showPageAppBar;

  const LeaderboardView({super.key, this.showPageAppBar = false});

  @override
  LeaderboardController get controller {
    if (Get.isRegistered<LeaderboardController>()) {
      return Get.find<LeaderboardController>();
    }

    // Ensure LeaderboardService is available before creating the controller.
    if (!Get.isRegistered<LeaderboardService>()) {
      try {
        Get.put<LeaderboardService>(
          LeaderboardService(
            apiClient: Get.find<ApiClient>(),
            tokenService: Get.find<TokenService>(),
          ),
        );
      } catch (_) {}
    }

    return Get.put<LeaderboardController>(
      LeaderboardController(leaderboardService: Get.find<LeaderboardService>()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        top: showPageAppBar,
        bottom: false,
        child: Stack(
          children: <Widget>[
            Obx(
              () => RefreshIndicator(
                onRefresh: controller.refreshLeaderboard,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        kHomeHorizontalPadding.w,
                        showPageAppBar ? 22.h : 20.h,
                        kHomeHorizontalPadding.w,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            LeaderboardHeader(
                              showPageAppBar: showPageAppBar,
                              onHelpTap: controller.onHelpTap,
                            ),
                            SizedBox(height: 24.h),
                            if (controller.hasError.value)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE6E6),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.error_outline,
                                      color: const Color(0xFFB00020),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        controller.errorMessage.value,
                                        style: TextStyle(
                                          color: const Color(0xFFB00020),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            LeaderboardTabBar(
                              selectedIndex: controller.selectedTabIndex.value,
                              onChanged: controller.onTabChanged,
                            ),

                            LeaderboardPodiumSection(
                              users: controller.podiumUsers,
                              isGlobal: controller.isGlobalSelected,
                            ),
                            if (controller.isMyLeagueSelected) ...<Widget>[
                              SizedBox(height: 30.h),
                              LeaderboardMilestoneCard(
                                milestone: controller.milestoneData.value,
                              ),
                            ],
                            SizedBox(height: 18.h),
                            LeaderboardSearchField(
                              controller: controller.searchController,
                              onChanged: controller.onSearchChanged,
                            ),
                            SizedBox(height: 18.h),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        kHomeHorizontalPadding.w,
                        0,
                        kHomeHorizontalPadding.w,
                        245.h,
                      ),
                      sliver: controller.filteredUsers.isEmpty
                          ? const SliverToBoxAdapter(child: EmptyLeaderboard())
                          : LeaderboardList(
                        users: controller.filteredUsers,
                        onMessageTap: (Map<String, dynamic> user) async {
                          await controller.onMessageTap(user);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}





























