import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../controllers/webinar_controller.dart';
import '../models/webinar_models.dart';
import '../widgets/webinar_common_widgets.dart';
import '../widgets/webinar_home_widgets.dart';

void _showCourseAccessDialog(
  BuildContext context,
  WebinarItemModel webinar,
) {
  showDialog<void>(
    context: context,
    builder: (_) => WebinarCourseAccessDialog(
      courseNames: webinar.audienceSettings.courseNames,
    ),
  );
}

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
                    title: 'gen_live_webinars'.tr,
                    onBackTap: () => Get.back<void>(),
                  ),
                  SizedBox(height: 20.h),
                  if (controller.liveWebinars.isEmpty)
                    WebinarEmptyState(
                      message: 'no_live_webinars_are_available_right_now'.tr,
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
                          onRestrictionTap: () =>
                              _showCourseAccessDialog(context, webinar),
                        );
                      },
                    ),
                  SizedBox(height: 30.h),
                  const WebinarSectionHeader(),
                  SizedBox(height: 24.h),
                  _UpcomingList(
                    webinars: controller.upcomingWebinars,
                    onRestrictionTap: (WebinarItemModel webinar) =>
                        _showCourseAccessDialog(context, webinar),
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

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({
    required this.webinars,
    required this.onRestrictionTap,
  });

  final List<WebinarItemModel> webinars;
  final ValueChanged<WebinarItemModel> onRestrictionTap;

  @override
  Widget build(BuildContext context) {
    if (webinars.isEmpty) {
      return WebinarEmptyState(message: 'no_upcoming_webinars_found'.tr);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: webinars.length,
      separatorBuilder: (_, _) => SizedBox(height: 20.h),
      itemBuilder: (_, int index) {
        final WebinarItemModel webinar = webinars[index];
        return WebinarSessionCard(
          webinar: webinar,
          onRestrictionTap: () => onRestrictionTap(webinar),
        );
      },
    );
  }
}
