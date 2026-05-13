import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../controllers/webinar_controller.dart';
import '../models/webinar_models.dart';
import '../widgets/webinar_live_widgets.dart';

class WebinarLiveView extends GetView<WebinarController> {
  const WebinarLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await controller.onWillPopLive();
        if (shouldPop) {
          Get.back<void>();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: Obx(
            () {
              final WebinarModel? data = controller.webinar.value;
              if (data == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                );
              }

              return Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      kWebinarHorizontalPadding.w,
                      20.h,
                      kWebinarHorizontalPadding.w,
                      controller.isParticipating.value ? 124.h : 112.h,
                    ),
                    child: controller.isParticipating.value
                        ? _ParticipationBody(data: data, controller: controller)
                        : _ChatBody(data: data, controller: controller),
                  ),
                  if (!controller.isParticipating.value)
                    Positioned(
                      left: kWebinarHorizontalPadding.w,
                      right: kWebinarHorizontalPadding.w,
                      bottom: 24.h,
                      child: WebinarChatInput(controller: controller),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  final WebinarModel data;
  final WebinarController controller;

  const _ChatBody({required this.data, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WebinarLiveHeader(webinar: data, onBackTap: () => Get.back<void>()),
        SizedBox(height: 24.h),
        WebinarVideoCard(
          webinar: data,
          alt: controller.isLiveVideoAlt.value,
          showTopHostChip: !controller.isLiveVideoAlt.value,
        ),
        SizedBox(height: 36.h),
        if (controller.isChatFocused.value) ...<Widget>[
          WebinarRequestButton(
            text: 'Back To Participation',
            onTap: controller.backToParticipation,
          ),
          SizedBox(height: 34.h),
        ] else ...<Widget>[
          WebinarRequestButton(
            text: 'Request To Participate',
            icon: Icons.mic_rounded,
            onTap: controller.requestToParticipate,
          ),
          SizedBox(height: 34.h),
        ],
        WebinarLiveChatSection(controller: controller),
      ],
    );
  }
}

class _ParticipationBody extends StatelessWidget {
  final WebinarModel data;
  final WebinarController controller;

  const _ParticipationBody({required this.data, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        WebinarLiveHeader(webinar: data, onBackTap: () => Get.back<void>()),
        SizedBox(height: 24.h),
        WebinarVideoCard(
          webinar: data,
          alt: true,
          showTopHostChip: false,
        ),
        SizedBox(height: 30.h),
        WebinarStageArea(controller: controller),
        SizedBox(height: 32.h),
        WebinarStageControls(controller: controller),
        SizedBox(height: 38.h),
        WebinarLeaveStageButton(onTap: controller.stopParticipation),
      ],
    );
  }
}
