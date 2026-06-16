import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../controllers/webinar_controller.dart';
import '../models/webinar_models.dart';
import '../widgets/webinar_common_widgets.dart';
import '../widgets/webinar_home_widgets.dart';

class WebinarView extends GetView<WebinarController> {
  const WebinarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.liveWebinars.isEmpty &&
              controller.upcomingWebinars.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: controller.loadWebinars,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                kWebinarHorizontalPadding.w,
                10.h,
                kWebinarHorizontalPadding.w,
                36.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  WebinarPageHeader(
                    title: 'Live Webinars',
                    onBackTap: () => Get.back<void>(),
                  ),
                  SizedBox(height: 20.h),
                  if (controller.liveWebinars.isEmpty)
                    const WebinarEmptyState(
                      message: 'No live webinars are available right now.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.liveWebinars.length,
                      separatorBuilder: (_, _) => SizedBox(height: 18.h),
                      itemBuilder: (_, int index) {
                        final WebinarItemModel webinar =
                            controller.liveWebinars[index];
                        return WebinarLiveHeroCard(
                          webinar: webinar,
                          isJoining:
                              controller.isJoining.value &&
                              controller.selectedWebinar.value?.id ==
                                  webinar.id,
                          onJoinTap: () => controller.openLiveSession(webinar),
                        );
                      },
                    ),
                  SizedBox(height: 30.h),
                  const WebinarSectionHeader(),
                  SizedBox(height: 24.h),
                  _UpcomingList(webinars: controller.upcomingWebinars),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({required this.webinars});

  final List<WebinarItemModel> webinars;

  @override
  Widget build(BuildContext context) {
    if (webinars.isEmpty) {
      return const WebinarEmptyState(message: 'No upcoming webinars found.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: webinars.length,
      separatorBuilder: (_, _) => SizedBox(height: 20.h),
      itemBuilder: (_, int index) {
        return WebinarSessionCard(webinar: webinars[index]);
      },
    );
  }
}
