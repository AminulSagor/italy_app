import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_constants.dart';
import 'controllers/ai_chat_controller.dart';
import 'models/ai_tutor_models.dart';
import 'views/widgets/ai_chat_home_widgets.dart';
import 'views/widgets/ai_tutor_writing_language_sheet.dart';

class AiChatView extends GetView<AiChatController> {
  const AiChatView({super.key});

  Future<void> _openWritingHelp(BuildContext context) async {
    final AiTutorWritingSourceLanguage? sourceLanguage =
        await showDialog<AiTutorWritingSourceLanguage>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: .35),
          builder: (BuildContext context) {
            return const AiTutorWritingLanguageDialog();
          },
        );

    if (sourceLanguage != null) {
      controller.openWritingHelp(sourceLanguage);
    }
  }

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
            SizedBox(height: 16.h),
            Obx(
              () => AiLevelTestHomeCard(
                subtitle: controller.levelTestSubtitle,
                onTap: controller.onLevelTestTap,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'ai_zone_tools'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 12.h),
            AiSpeakingLabCard(onTap: controller.onEnterLabTap),
            SizedBox(height: 12.h),
            AiGuidedLearningCard(onTap: controller.onGuidedLearningTap),
            SizedBox(height: 12.h),
            AiToolCard(
              title: 'gen_writing_help'.tr,
              subtitle: 'রাইটিং অ্যাসিস্ট্যান্ট'.tr,
              icon: Icons.auto_awesome_rounded,
              backgroundColor: const Color(0xFFE9FFF4),
              iconColor: const Color(0xFF08A77F),
              textColor: const Color(0xFF0D674F),
              onTap: () => _openWritingHelp(context),
            ),
            SizedBox(height: 20.h),
            const AiProTipCard(),
          ],
        ),
      ),
    );
  }
}
