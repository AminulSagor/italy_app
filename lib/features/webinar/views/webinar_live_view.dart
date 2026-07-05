import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../controllers/webinar_controller.dart';
import '../models/webinar_models.dart';
import '../widgets/webinar_live_widgets.dart';
import '../widgets/webinar_stage_widgets.dart';

class WebinarLiveView extends GetView<WebinarController> {
  const WebinarLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await controller.onWillPopLive();
        if (shouldPop) Get.back<void>();
      },
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: Obx(() {
            final WebinarItemModel? data = controller.selectedWebinar.value;
            if (data == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                kWebinarHorizontalPadding.w,
                10.h,
                kWebinarHorizontalPadding.w,
                20.h,
              ),
              child: controller.isParticipating.value
                  ? _ParticipationBody(data: data, controller: controller)
                  : _ChatBody(data: data, controller: controller),
            );
          }),
        ),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({required this.data, required this.controller});

  final WebinarItemModel data;
  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WebinarLiveHeader(webinar: data, controller: controller),
        SizedBox(height: 20.h),
        WebinarVideoCard(webinar: data, controller: controller),
        SizedBox(height: 16.h),
        Obx(
          () => WebinarRequestButton(
            text: _requestButtonText(),
            icon: Icons.mic_rounded,
            isDisabled:
                controller.isSpeakerPending || controller.isRequesting.value,
            onTap: controller.requestToParticipate,
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(child: WebinarLiveChatSection(controller: controller)),
        SizedBox(height: 14.h),
        WebinarChatInput(controller: controller),
      ],
    );
  }

  String _requestButtonText() {
    if (controller.isRequesting.value) return 'requesting'.tr;
    if (controller.isSpeakerPending) return 'pending'.tr;
    if (controller.isSpeakerGranted) return 'approved'.tr;
    return 'request_to_participate'.tr;
  }
}

class _ParticipationBody extends StatelessWidget {
  const _ParticipationBody({required this.data, required this.controller});

  final WebinarItemModel data;
  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        WebinarLiveHeader(webinar: data, controller: controller),
        SizedBox(height: 18.h),
        WebinarVideoCard(webinar: data, controller: controller),
        SizedBox(height: 18.h),
        Expanded(child: WebinarStageArea(controller: controller)),
        SizedBox(height: 18.h),
        WebinarStageControls(controller: controller),
        SizedBox(height: 18.h),
        Obx(
          () => CustomButton(
            onPressed:
                controller.isLeaving.value ? () {} : controller.stopParticipation,
            isLoading: controller.isLeaving.value,
            text: controller.isLeaving.value
                ? 'leaving_stage'.tr
                : 'stop_and_leave_the_stage'.tr,
            btnColor: AppColors.white,
            textColor: AppColors.profileRedText,
            borderColor: AppColors.profileRedText,
            fontSize: 16.sp,
            icon: Icons.logout,
          ),
        ),
      ],
    );
  }
}
