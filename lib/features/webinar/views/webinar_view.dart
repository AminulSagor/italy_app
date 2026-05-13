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
        child: Obx(
          () {
            final WebinarModel? data = controller.webinar.value;
            if (controller.isLoading.value && data == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (data == null) {
              return const SizedBox.shrink();
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                kWebinarHorizontalPadding.w,
                18.h,
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
                  SizedBox(height: 22.h),
                  WebinarLiveHeroCard(
                    webinar: data,
                    onJoinTap: controller.openLiveSession,
                  ),
                  SizedBox(height: 42.h),
                  const WebinarSectionHeader(),
                  SizedBox(height: 24.h),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.upcomingSessions.length,
                    separatorBuilder: (_, __) => SizedBox(height: 20.h),
                    itemBuilder: (_, int index) {
                      return WebinarSessionCard(session: data.upcomingSessions[index]);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
