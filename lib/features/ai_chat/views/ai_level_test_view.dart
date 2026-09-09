import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/native_bottom_inset.dart';
import '../controllers/ai_tutor_level_test_controller.dart';
import 'widgets/ai_tutor_level_test_widgets.dart';

class AiLevelTestView extends GetView<AiTutorLevelTestController> {
  const AiLevelTestView({super.key});

  @override
  AiTutorLevelTestController get controller {
    if (Get.isRegistered<AiTutorLevelTestController>()) {
      return Get.find<AiTutorLevelTestController>();
    }

    return Get.put<AiTutorLevelTestController>(
      AiTutorLevelTestController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.aiTutor,
      sourceId: 'ai_level_test_view',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              _buildContent(context),
              _buildBottomAction(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final double bottomInsetHeight = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20.w,
        16.h,
        20.w,
        // Dynamic bottom padding ensures scrollable content is never obscured by the pinned bottom action
        140.h + bottomInsetHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AiTutorLevelTestHeader(
            title: 'gen_level_test'.tr,
            onBackTap: () => Get.back<void>(),
          ),

          SizedBox(height: 20.h),

          _buildHeroCard(),

          SizedBox(height: 28.h),

          _buildSectionHeader(),

          SizedBox(height: 14.h),

          AiTutorLevelMeasureCard(
            icon: Icons.mic_rounded,
            iconColor: const Color(0xFF2563EB),
            iconBackground: const Color(0xFFEFF6FF),
            title: 'gen_speaking'.tr,
            subtitle: 'gen_communication_fluency'.tr,
          ),

          SizedBox(height: 12.h),

          AiTutorLevelMeasureCard(
            icon: Icons.chat_bubble_rounded,
            iconColor: const Color(0xFFDC2626),
            iconBackground: const Color(0xFFFEF2F2),
            title: 'gen_vocabulary'.tr,
            subtitle: 'gen_word_knowledge_context'.tr,
          ),

          SizedBox(height: 12.h),

          AiTutorLevelMeasureCard(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF16A34A),
            iconBackground: const Color(0xFFF0FDF4),
            title: 'gen_grammar'.tr,
            subtitle: 'gen_sentence_structure_verbs'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    final BorderRadius borderRadius = BorderRadius.circular(28.r);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.20),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF047857),
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              // Decorative background ambient shapes
              Positioned(
                right: -20.r,
                top: -20.r,
                child: Container(
                  width: 130.r,
                  height: 130.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                left: -30.r,
                bottom: -40.r,
                child: Container(
                  width: 110.r,
                  height: 110.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA7F3D0).withValues(alpha: 0.12),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 24.h,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 26.r,
                        color: const Color(0xFFA7F3D0),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      'discover_your_exact_level'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.white,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'ai_level_test_live_description'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'what_we_measure'.tr.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFA7F3D0),
              width: 1,
            ),
          ),
          child: Text(
            '3 ${'skills'.tr}',
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF047857),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFF1F5F9),
              width: 1.h,
            ),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 20.r,
              offset: Offset(0, -8.h),
            ),
          ],
        ),
        // Ensures proper bottom end inset handling across system navigation bars
        child: NativeBottomInset(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              14.h,
              20.w,
              12.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Obx(
                      () => AiTutorLevelPrimaryButton(
                    text: 'start_free_level_test'.tr,
                    onTap: controller.startTest,
                    isEnabled: controller.canAttempt.value,
                  ),
                ),

                SizedBox(height: 10.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 13.r,
                      color: const Color(0xFF94A3B8),
                    ),

                    SizedBox(width: 6.w),

                    Flexible(
                      child: Obx(
                            () => Text(
                          _getAccessText(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAccessText() {
    if (controller.hasPaidAccess.value) {
      return 'level_test_paid_access'.tr;
    }

    if (controller.maxAttempts.value > 0) {
      return 'level_test_attempts_remaining'.trParams(
        <String, String>{
          'remaining': controller.attemptsRemaining.value.toString(),
          'max': controller.maxAttempts.value.toString(),
        },
      );
    }

    return 'takes_about_5_minutes_results_stay_private'.tr;
  }
}