import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../controllers/ai_tutor_level_test_controller.dart';
import '../models/ai_tutor_level_test_models.dart';
import 'widgets/ai_tutor_level_test_widgets.dart';

class AiTutorLevelTestResultView
    extends GetView<AiTutorLevelTestController> {
  const AiTutorLevelTestResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final AiTutorLearnerProfileModel? profile = controller.latestProfile;
    if (profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFA),
        body: SafeArea(
          child: Center(
            child: AiTutorLevelPrimaryButton(
              text: 'retake_level_test'.tr,
              onTap: controller.retakeTest,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 55.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.back<void>(),
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E3E5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 29.r,
                      color: const Color(0xFF33383C),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              _FinalLevelCard(profile: profile),
              SizedBox(height: 31.h),
              Text(
                'detailed_skill_breakdown'.tr,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.1,
                  color: const Color(0xFF5E6562),
                ),
              ),
              SizedBox(height: 18.h),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                  Expanded(
                    child: _SkillResultCard(
                      color: const Color(0xFFDDF1FF),
                      iconColor: const Color(0xFF09649F),
                      icon: Icons.mic_rounded,
                      label: 'gen_speaking'.tr,
                      level: profile.speakingLevel,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: _SkillResultCard(
                      color: const Color(0xFFFFEFD8),
                      iconColor: const Color(0xFF8A4D00),
                      icon: Icons.chat_bubble_rounded,
                      label: 'gen_vocabulary'.tr,
                      level: profile.vocabularyLevel,
                    ),
                  ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              _GrammarResultCard(level: profile.grammarLevel),
              SizedBox(height: 22.h),
              _SummaryCard(profile: profile),
              if (profile.strengths.isNotEmpty) ...<Widget>[
                SizedBox(height: 22.h),
                _ResultListCard(
                  title: 'gen_your_strengths'.tr,
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.primaryGreen,
                  items: profile.strengths,
                ),
              ],
              if (profile.focusAreas.isNotEmpty) ...<Widget>[
                SizedBox(height: 16.h),
                _ResultListCard(
                  title: 'gen_focus_next'.tr,
                  icon: Icons.track_changes_rounded,
                  iconColor: const Color(0xFFFF8A21),
                  items: profile.focusAreas,
                ),
              ],
              SizedBox(height: 30.h),
              AiTutorLevelPrimaryButton(
                text: 'continue_to_adaptive_ai_chat'.tr,
                onTap: controller.continueToAiChat,
              ),
              SizedBox(height: 13.h),
              Center(
                child: TextButton(
                  onPressed: controller.retakeTest,
                  child: Text(
                    'retake_test'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalLevelCard extends StatelessWidget {
  const _FinalLevelCard({required this.profile});

  final AiTutorLearnerProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 38.h, 24.w, 35.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(46.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.18),
            blurRadius: 25.r,
            offset: Offset(0, 13.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            'your_final_level'.tr,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            profile.finalLevel,
            style: TextStyle(
              fontSize: 58.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.8,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 17.h),
          Text(
            'ai_tutor'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withValues(alpha: 0.84),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillResultCard extends StatelessWidget {
  const _SkillResultCard({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.level,
  });

  final Color color;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 123),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 27.r, color: iconColor),
          SizedBox(height: 10.h),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: iconColor.withValues(alpha: 0.78),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            level,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrammarResultCard extends StatelessWidget {
  const _GrammarResultCard({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(26.w, 22.h, 26.w, 22.h),
      decoration: BoxDecoration(
        color: const Color(0xFFDDFCE7),
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52.r,
            height: 52.r,
            decoration: const BoxDecoration(
              color: Color(0xFFEFFFF0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 28.r,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'gen_grammar_1'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: const Color(0xFF5B9B43),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF25463B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.profile});

  final AiTutorLearnerProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7ED),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: const Color(0xFFD5E8CC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            size: 24.r,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.adaptiveLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF294A3E),
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  profile.summary,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5C6763),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultListCard extends StatelessWidget {
  const _ResultListCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE3E8E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: const Color(0xFF737C78),
            ),
          ),
          SizedBox(height: 12.h),
          ...items.map(
            (String item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(icon, size: 17.r, color: iconColor),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4F5A56),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
