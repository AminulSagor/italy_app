import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../routes/app_routes.dart';
import '../controllers/final_exam_controller.dart';

double _boundedWidth(
    double value, {
      required double min,
      required double max,
    }) {
  return value.w.clamp(min, max).toDouble();
}

double _boundedHeight(
    double value, {
      required double min,
      required double max,
    }) {
  return value.h.clamp(min, max).toDouble();
}

double _boundedFont(
    double value, {
      required double min,
      required double max,
    }) {
  return value.sp.clamp(min, max).toDouble();
}

class FinalExamSuccessView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamSuccessView({
    super.key,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.exam,
      sourceId: 'final_exam_success_view',
      child: Scaffold(
        backgroundColor: AppColors.coursesDetailBg,
        bottomNavigationBar: _buildBottomNavigationBar(),
        body: SafeArea(
          bottom: false,
          child: Obx(
                () => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    _boundedWidth(20, min: 16, max: 24),
                    _boundedHeight(10, min: 8, max: 12),
                    _boundedWidth(20, min: 16, max: 24),
                    _boundedHeight(32, min: 24, max: 40),
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildHeader(),
                      SizedBox(
                        height: _boundedHeight(24, min: 20, max: 28),
                      ),
                      _buildAchievementImage(),
                      SizedBox(
                        height: _boundedHeight(22, min: 18, max: 26),
                      ),
                      _buildSuccessMessage(),
                      SizedBox(
                        height: _boundedHeight(26, min: 22, max: 30),
                      ),
                      _ReferenceIdCard(
                        referenceId: controller.referenceId.value,
                      ),
                      SizedBox(
                        height: _boundedHeight(24, min: 20, max: 28),
                      ),
                      _TimelineCard(
                        teacherDone:
                        controller.teacherReviewComplete.value,
                        resultDone: controller.resultComplete.value,
                        writingTaskEnabled:
                            controller.gateway.value?.writingTaskEnabled ??
                                true,
                        estimatedResult:
                        controller.estimatedResult.value,
                        onViewResultTap: controller.openResult,
                      ),
                      SizedBox(
                        height: _boundedHeight(24, min: 20, max: 28),
                      ),
                      const _WaitingTipCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            _boundedWidth(20, min: 16, max: 24),
            _boundedHeight(12, min: 10, max: 14),
            _boundedWidth(20, min: 16, max: 24),
            _boundedHeight(14, min: 12, max: 18),
          ),
          child: Align(
            heightFactor: 1,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SizedBox(
                width: double.infinity,
                height: _boundedHeight(52, min: 48, max: 54),
                child: CustomButton.primary(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.wrapper);
                  },
                  text: 'final_exam_back_to_practice_hub'.tr,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final double actionSize = _boundedWidth(
      28,
      min: 24,
      max: 28,
    );

    return Row(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.offAllNamed(AppRoutes.wrapper);
          },
          child: SizedBox(
            width: actionSize,
            height: actionSize,
            child: Icon(
              Icons.close_rounded,
              color: AppColors.primaryGreen,
              size: _boundedWidth(24, min: 22, max: 26),
            ),
          ),
        ),
        SizedBox(
          width: _boundedWidth(8, min: 6, max: 10),
        ),
        Expanded(
          child: Text(
            'final_exam_success_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _boundedFont(
                AppFont.font16,
                min: 14,
                max: 16,
              ),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        SizedBox(
          width: _boundedWidth(8, min: 6, max: 10),
        ),
        SizedBox(
          width: actionSize,
          height: actionSize,
        ),
      ],
    );
  }

  Widget _buildAchievementImage() {
    final double imageSize = _boundedWidth(
      170,
      min: 135,
      max: 185,
    );

    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: Image.asset(
        'assets/decor_png/achievement_2.png',
        fit: BoxFit.contain,
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
            ) {
          return Icon(
            Icons.emoji_events_rounded,
            color: AppColors.primaryGreen,
            size: imageSize * 0.62,
          );
        },
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: <Widget>[
        Text(
          'final_exam_submitted_title'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _boundedFont(
              AppFont.font34,
              min: 25,
              max: 30,
            ),
            fontWeight: FontWeight.w800,
            height: 1.18,
            color: AppColors.primaryBtnShadow,
          ),
        ),
        SizedBox(
          height: _boundedHeight(10, min: 8, max: 12),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _boundedWidth(8, min: 0, max: 16),
          ),
          child: Text(
            'final_exam_submitted_message'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _boundedFont(
                AppFont.font16,
                min: 14,
                max: 16,
              ),
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: AppColors.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReferenceIdCard extends StatelessWidget {
  final String referenceId;

  const _ReferenceIdCard({
    required this.referenceId,
  });

  @override
  Widget build(BuildContext context) {
    final String normalizedReferenceId = referenceId.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _boundedWidth(16, min: 14, max: 18),
        vertical: _boundedHeight(12, min: 10, max: 14),
      ),
      decoration: BoxDecoration(
        color: AppColors.reportReviewBg,
        borderRadius: BorderRadius.circular(
          _boundedWidth(18, min: 16, max: 20),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: _boundedWidth(32, min: 28, max: 34),
            height: _boundedWidth(32, min: 28, max: 34),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Text(
              '#',
              style: TextStyle(
                fontSize: _boundedFont(
                  AppFont.font16,
                  min: 14,
                  max: 17,
                ),
                fontWeight: FontWeight.w900,
                color: AppColors.reportReviewText,
              ),
            ),
          ),
          SizedBox(
            width: _boundedWidth(10, min: 8, max: 12),
          ),
          Expanded(
            child: Text(
              normalizedReferenceId.isEmpty
                  ? 'final_exam_reference_id_unavailable'.tr
                  : 'final_exam_reference_id'.trParams(
                <String, String>{
                  'value': normalizedReferenceId,
                },
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: _boundedFont(
                  AppFont.font14,
                  min: 12.5,
                  max: 14,
                ),
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.reportReviewText,
              ),
            ),
          ),
          SizedBox(
            width: _boundedWidth(8, min: 6, max: 10),
          ),
          Icon(
            Icons.copy_rounded,
            color: AppColors.reportReviewText,
            size: _boundedWidth(18, min: 16, max: 19),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final bool teacherDone;
  final bool resultDone;
  final bool writingTaskEnabled;
  final String estimatedResult;
  final VoidCallback onViewResultTap;

  const _TimelineCard({
    required this.teacherDone,
    required this.resultDone,
    required this.writingTaskEnabled,
    required this.estimatedResult,
    required this.onViewResultTap,
  });

  @override
  Widget build(BuildContext context) {
    final String normalizedEstimatedResult = estimatedResult.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        _boundedWidth(20, min: 16, max: 24),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          _boundedWidth(28, min: 22, max: 32),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'final_exam_evaluation_timeline'.tr,
            style: TextStyle(
              fontSize: _boundedFont(
                AppFont.font12,
                min: 11,
                max: 12,
              ),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(
            height: _boundedHeight(22, min: 18, max: 24),
          ),
          const _TimelineStep(
            isDone: true,
            isActive: true,
            titleKey: 'final_exam_received',
            subtitleKey: 'final_exam_uploaded_successfully',
            icon: Icons.check_rounded,
          ),
          _TimelineStep(
            isDone: teacherDone,
            isActive: teacherDone,
            titleKey: 'final_exam_teacher_review',
            subtitleKey: teacherDone
                ? 'final_exam_manual_review_completed'
                : writingTaskEnabled
                    ? 'final_exam_reviewing_answers'
                    : 'final_exam_reviewing_speaking_answer',
            icon: teacherDone
                ? Icons.check_rounded
                : Icons.circle,
          ),
          _TimelineStep(
            isDone: resultDone,
            isActive: resultDone,
            titleKey: 'final_exam_result_certificate',
            subtitleKey: resultDone
                ? 'final_exam_result_ready'
                : 'final_exam_unlock_achievement',
            icon: resultDone
                ? Icons.check_rounded
                : Icons.lock_outline_rounded,
            showConnector: false,
          ),
          SizedBox(
            height: _boundedHeight(8, min: 6, max: 10),
          ),
          if (resultDone)
            _ViewResultButton(
              onTap: onViewResultTap,
            )
          else
            _EstimatedResultCard(
              text: normalizedEstimatedResult.isEmpty
                  ? 'final_exam_estimated_result_unavailable'.tr
                  : 'final_exam_estimated_result'.trParams(
                <String, String>{
                  'value': normalizedEstimatedResult,
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final bool isDone;
  final bool isActive;
  final bool showConnector;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;

  const _TimelineStep({
    required this.isDone,
    required this.isActive,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    this.showConnector = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isActive
        ? AppColors.primaryGreen
        : AppColors.quizAnswerShadow;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: _boundedWidth(32, min: 30, max: 34),
                height: _boundedWidth(32, min: 30, max: 34),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: _boundedWidth(18, min: 16, max: 19),
                ),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: _boundedWidth(3, min: 2, max: 3),
                    color: isDone
                        ? AppColors.primaryGreen
                        : AppColors.quizProgressTrack,
                  ),
                ),
            ],
          ),
          SizedBox(
            width: _boundedWidth(16, min: 14, max: 18),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: _boundedHeight(26, min: 22, max: 30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    titleKey.tr,
                    style: TextStyle(
                      fontSize: _boundedFont(
                        AppFont.font16,
                        min: 14,
                        max: 16,
                      ),
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: isActive
                          ? AppColors.homePrimaryText
                          : AppColors.quizAnswerShadow,
                    ),
                  ),
                  SizedBox(
                    height: _boundedHeight(4, min: 3, max: 5),
                  ),
                  Text(
                    subtitleKey.tr,
                    style: TextStyle(
                      fontSize: _boundedFont(
                        AppFont.font14,
                        min: 12.5,
                        max: 14,
                      ),
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      color: isActive
                          ? AppColors.bodyText
                          : AppColors.quizAnswerShadow,
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

class _ViewResultButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewResultButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeSoftGreen,
      borderRadius: BorderRadius.circular(kHomePillRadius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: _boundedHeight(46, min: 44, max: 48),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _boundedWidth(16, min: 14, max: 18),
            vertical: _boundedHeight(11, min: 10, max: 12),
          ),
          alignment: Alignment.center,
          child: Text(
            'final_exam_view_result'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _boundedFont(
                AppFont.font16,
                min: 14,
                max: 16,
              ),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}

class _EstimatedResultCard extends StatelessWidget {
  final String text;

  const _EstimatedResultCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _boundedWidth(16, min: 14, max: 18),
        vertical: _boundedHeight(13, min: 11, max: 15),
      ),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(
          _boundedWidth(18, min: 16, max: 20),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.access_time_rounded,
            color: AppColors.primaryGreen,
            size: _boundedWidth(20, min: 18, max: 21),
          ),
          SizedBox(
            width: _boundedWidth(10, min: 8, max: 12),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: _boundedFont(
                  AppFont.font14,
                  min: 12.5,
                  max: 14,
                ),
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingTipCard extends StatelessWidget {
  const _WaitingTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        _boundedWidth(18, min: 16, max: 20),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          _boundedWidth(22, min: 18, max: 26),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: _boundedWidth(46, min: 42, max: 50),
            height: _boundedWidth(46, min: 42, max: 50),
            decoration: BoxDecoration(
              color: AppColors.coursesCreamLightBg,
              borderRadius: BorderRadius.circular(
                _boundedWidth(14, min: 12, max: 16),
              ),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: AppColors.vocabularyOrangeShadow,
              size: _boundedWidth(24, min: 22, max: 26),
            ),
          ),
          SizedBox(
            width: _boundedWidth(14, min: 12, max: 16),
          ),
          Expanded(
            child: Text(
              'final_exam_waiting_tip'.tr,
              style: TextStyle(
                fontSize: _boundedFont(
                  AppFont.font14,
                  min: 13,
                  max: 15,
                ),
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
