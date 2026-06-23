import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/ai_chat_controller.dart';
import '../models/ai_tutor_guided_learning_models.dart';

class GuidedLearningLevelSelectionView extends GetView<AiChatController> {
  const GuidedLearningLevelSelectionView({super.key});

  @override
  AiChatController get controller {
    if (Get.isRegistered<AiChatController>()) {
      return Get.find<AiChatController>();
    }
    return Get.put<AiChatController>(AiChatController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 27.h, 24.w, 56.h),
          child: Column(
            children: <Widget>[
              const _GuidedHeader(title: 'Guided AI Tour'),
              SizedBox(height: 47.h),
              Text(
                'আপনার লেভেল নির্বাচন করুন',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23.sp,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F3734),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Select a learning level to start your\nconversation practice.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.42,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF686F6C),
                ),
              ),
              SizedBox(height: 45.h),
              _LevelCard(
                icon: Icons.school_rounded,
                title: 'Level A1',
                levelLabel: '(Beginner)',
                description:
                    '10 topics. Listen to short Italian phrases\nand repeat them exactly.',
                buttonText: 'Explore A1 Topics',
                onTap: () => controller.openGuidedTopics(
                  level: 'A1',
                  mode: AiTutorGuidedMode.guided,
                ),
              ),
              SizedBox(height: 24.h),
              _LevelCard(
                icon: Icons.rocket_launch_rounded,
                title: 'Level A2',
                levelLabel: '(Intermediate)',
                description:
                    'Answer topic questions in Italian with\nguidance and simple corrections.',
                buttonText: 'Explore A2 Topics',
                onTap: () => controller.openGuidedTopics(
                  level: 'A2',
                  mode: AiTutorGuidedMode.assisted,
                ),
              ),
              SizedBox(height: 24.h),
              _LevelCard(
                icon: Icons.chat_bubble_rounded,
                title: 'Level B1',
                levelLabel: '(Advanced)',
                description: 'Natural role-play conversations in\nreal-life Italian situations.',
                buttonText: 'Explore B1 Topics',
                onTap: () => controller.openGuidedTopics(
                  level: 'B1',
                  mode: AiTutorGuidedMode.free,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidedHeader extends StatelessWidget {
  final String title;

  const _GuidedHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Get.back<void>(),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 24.r,
              color: AppColors.primaryGreen,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          SizedBox(width: 24.r),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String levelLabel;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const _LevelCard({
    required this.icon,
    required this.title,
    required this.levelLabel,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 35.h, 32.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 22.r,
            offset: Offset(0, 11.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8E8),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(icon, size: 28.r, color: AppColors.primaryGreen),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.7,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      TextSpan(
                        text: levelLabel,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4,
                          color: const Color(0xFF8E96A4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 26.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              description,
              style: TextStyle(
                fontSize: 17.sp,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF566075),
              ),
            ),
          ),
          SizedBox(height: 33.h),
          _GreenPillButton(text: buttonText, onTap: onTap),
        ],
      ),
    );
  }
}

class _GreenPillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GreenPillButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF123F00),
              blurRadius: 0,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(width: 13.w),
            Icon(Icons.play_arrow_rounded, size: 24.r, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
