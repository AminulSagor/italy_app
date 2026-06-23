import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_constants.dart';
import 'controllers/ai_chat_controller.dart';
import 'views/widgets/ai_chat_home_widgets.dart';

class AiChatView extends GetView<AiChatController> {
  const AiChatView({super.key});

  @override
  AiChatController get controller {
    if (Get.isRegistered<AiChatController>()) {
      return Get.find<AiChatController>();
    }
    return Get.put<AiChatController>(AiChatController());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          kHomeHorizontalPadding.w,
          14.h,
          kHomeHorizontalPadding.w,
          122.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const AiCreditStatusRow(),
            SizedBox(height: 24.h),
            AiSpeakingLabCard(onTap: controller.onEnterLabTap),
            SizedBox(height: 24.h),
            AiGuidedLearningCard(onTap: controller.onGuidedLearningTap),
            SizedBox(height: 48.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: AiToolCard(
                    title: 'Writing Help',
                    subtitle: 'রাইটিং অ্যাসিস্ট্যান্ট',
                    icon: Icons.auto_awesome_rounded,
                    backgroundColor: const Color(0xFFE9FFF4),
                    iconColor: const Color(0xFF08C99B),
                    textColor: const Color(0xFF0D674F),
                    onTap: controller.onWritingHelpTap,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Obx(
                    () => AiToolCard(
                      title: 'Level Test',
                      subtitle: controller.levelTestSubtitle,
                      icon: Icons.settings_suggest_rounded,
                      backgroundColor: const Color(0xFFFFF4E7),
                      iconColor: const Color(0xFFFF6A18),
                      textColor: const Color(0xFF8D270B),
                      onTap: controller.onLevelTestTap,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            AiRecentSessionCard(onTap: controller.onRecentSessionTap),
            SizedBox(height: 25.h),
            const AiProTipCard(),
          ],
        ),
      ),
    );
  }
}
