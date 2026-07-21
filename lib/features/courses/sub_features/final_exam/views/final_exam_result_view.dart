import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/final_exam_controller.dart';
import '../models/final_exam_models.dart';

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

class FinalExamResultView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamResultView({
    super.key,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.exam,
      sourceId: 'final_exam_result_view',
      child: Scaffold(
        backgroundColor: AppColors.coursesDetailBg,
        bottomNavigationBar: _buildBottomNavigationBar(),
        body: SafeArea(
          bottom: false,
          child: Obx(
                () {
              final FinalExamResultModel? result =
                  controller.result.value;

              if (controller.isLoading.value && result == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }

              if (result == null) {
                return _buildUnavailableState();
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 560,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      _boundedWidth(20, min: 16, max: 24),
                      _boundedHeight(8, min: 6, max: 10),
                      _boundedWidth(20, min: 16, max: 24),
                      _boundedHeight(36, min: 28, max: 44),
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildHeader(),
                        SizedBox(
                          height: _boundedHeight(
                            18,
                            min: 14,
                            max: 20,
                          ),
                        ),
                        _buildScoreCircle(result),
                        SizedBox(
                          height: _boundedHeight(
                            24,
                            min: 20,
                            max: 28,
                          ),
                        ),
                        _buildResultSummary(result),

                        if (result.stats.isNotEmpty) ...<Widget>[
                          SizedBox(
                            height: _boundedHeight(
                              28,
                              min: 22,
                              max: 32,
                            ),
                          ),
                          _buildStatsGrid(result),
                        ],
                        if (result.teacherComment.isNotEmpty ||
                            result
                                .teacherCommentBangla.isNotEmpty) ...<Widget>[
                          SizedBox(
                            height: _boundedHeight(
                              28,
                              min: 22,
                              max: 32,
                            ),
                          ),
                          _TeacherCommentCard(
                            result: result,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() {
      final bool showRetake =
          controller.retakeAvailable.value;

      final bool showCertificate =
          controller.certificateAvailable.value;

      if (!showRetake && !showCertificate) {
        return const SizedBox.shrink();
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
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
              _boundedWidth(
                20,
                min: 16,
                max: 24,
              ),
              _boundedHeight(
                10,
                min: 8,
                max: 12,
              ),
              _boundedWidth(
                20,
                min: 16,
                max: 24,
              ),
              _boundedHeight(
                14,
                min: 12,
                max: 18,
              ),
            ),
            child: Align(
              heightFactor: 1,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 560,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: _boundedHeight(
                    52,
                    min: 48,
                    max: 54,
                  ),
                  child: CustomButton.primary(
                    onPressed: showRetake
                        ? controller.startRetake
                        : controller.openCertificate,
                    isLoading: showRetake &&
                        controller.isSubmitting.value,
                    text: showRetake
                        ? 'give_exam_again'.tr
                        : 'view_official_certificate'
                        .tr,
                    icon: showRetake
                        ? Icons.replay_rounded
                        : Icons.article_outlined,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    final double actionSize = _boundedWidth(
      36,
      min: 32,
      max: 38,
    );

    return Row(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.back<void>(),
            borderRadius: BorderRadius.circular(actionSize),
            child: SizedBox(
              width: actionSize,
              height: actionSize,
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryGreen,
                size: _boundedWidth(
                  22,
                  min: 20,
                  max: 24,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: _boundedWidth(8, min: 6, max: 10),
        ),
        Expanded(
          child: Text(
            'final_exam_results_title'.tr,
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

        // Keeps the title centered after removing the share button.
        SizedBox(
          width: actionSize,
          height: actionSize,
        ),
      ],
    );
  }

  Widget _buildScoreCircle(
      FinalExamResultModel result,
      ) {
    final double circleSize = _boundedWidth(
      154,
      min: 140,
      max: 166,
    );

    return Container(
      width: circleSize,
      height: circleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGreen,
          width: _boundedWidth(
            7,
            min: 6,
            max: 8,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${result.markPercent}%',
            style: TextStyle(
              fontSize: _boundedFont(
                AppFont.font36,
                min: 28,
                max: 34,
              ),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
              height: 1,
            ),
          ),
          SizedBox(
            height: _boundedHeight(
              6,
              min: 4,
              max: 7,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _boundedWidth(
                12,
                min: 10,
                max: 14,
              ),
            ),
            child: Text(
              'final_exam_mark_achieved'.tr,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _boundedFont(
                  AppFont.font12,
                  min: 10.5,
                  max: 12,
                ),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.7,
                height: 1.2,
                color: AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSummary(
      FinalExamResultModel result,
      ) {
    return Column(
      children: <Widget>[
        Text(
          _resultTitle(result),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _boundedFont(
              AppFont.font24,
              min: 20,
              max: 24,
            ),
            fontWeight: FontWeight.w800,
            color: AppColors.primaryGreen,
            height: 1.2,
          ),
        ),
        SizedBox(
          height: _boundedHeight(
            8,
            min: 6,
            max: 10,
          ),
        ),
        Text(
          _resultSubtitle(result),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _boundedFont(
              AppFont.font16,
              min: 13,
              max: 16,
            ),
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }


  Widget _buildStatsGrid(
      FinalExamResultModel result,
      ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: result.stats.length,
      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: _boundedWidth(
          14,
          min: 10,
          max: 16,
        ),
        mainAxisSpacing: _boundedHeight(
          14,
          min: 10,
          max: 16,
        ),
        childAspectRatio: 1.05,
      ),
      itemBuilder: (
          BuildContext context,
          int index,
          ) {
        final FinalExamResultStatModel stat =
        result.stats[index];

        return _ResultStatCard(
          icon: _statIcon(stat.iconName),
          label: stat.label,
          value: stat.value,
          color: _statColor(stat.iconName),
        );
      },
    );
  }

  Widget _buildUnavailableState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          _boundedWidth(24, min: 20, max: 28),
        ),
        child: Text(
          'final_exam_result_unavailable'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _boundedFont(
              AppFont.font16,
              min: 14,
              max: 16,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.bodyText,
          ),
        ),
      ),
    );
  }

  String _resultTitle(
      FinalExamResultModel result,
      ) {
    switch (result.verdict.trim().toLowerCase()) {
      case 'passed':
        return 'final_exam_result_passed'.tr;

      case 'failed':
      case 'retake_required':
        return 'final_exam_retake_required'.tr;

      default:
        return 'final_exam_results_title'.tr;
    }
  }

  String _resultSubtitle(
      FinalExamResultModel result,
      ) {
    final String subtitle = result.subtitle.trim();

    if (subtitle.isEmpty ||
        subtitle == 'Your final evaluation is ready.') {
      return 'final_exam_evaluation_ready'.tr;
    }

    return subtitle;
  }
}

IconData _statIcon(String iconName) {
  switch (iconName) {
    case 'listening':
      return Icons.headphones_rounded;

    case 'writing':
      return Icons.edit_note_rounded;

    case 'speaking':
      return Icons.record_voice_over_rounded;

    case 'quiz':
    default:
      return Icons.description_outlined;
  }
}

Color _statColor(String iconName) {
  switch (iconName) {
    case 'listening':
      return AppColors.coursesChapterBlue;

    case 'writing':
      return AppColors.vocabularyOrangeShadow;

    case 'speaking':
    case 'quiz':
    default:
      return AppColors.primaryGreen;
  }
}

class _ResultStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        _boundedWidth(
          15,
          min: 12,
          max: 17,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          _boundedWidth(
            22,
            min: 18,
            max: 24,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: _boundedWidth(
              40,
              min: 36,
              max: 42,
            ),
            height: _boundedWidth(
              40,
              min: 36,
              max: 42,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(
                _boundedWidth(
                  12,
                  min: 10,
                  max: 13,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: _boundedWidth(
                19,
                min: 17,
                max: 20,
              ),
            ),
          ),
          SizedBox(
            height: _boundedHeight(
              10,
              min: 8,
              max: 11,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _boundedFont(
                AppFont.font14,
                min: 12,
                max: 14,
              ),
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(
            height: _boundedHeight(
              4,
              min: 3,
              max: 5,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _boundedFont(
                AppFont.font20,
                min: 18,
                max: 21,
              ),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherCommentCard extends StatelessWidget {
  final FinalExamResultModel result;

  const _TeacherCommentCard({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final String englishComment =
    result.teacherComment.trim();

    final String banglaComment =
    result.teacherCommentBangla.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        _boundedWidth(
          20,
          min: 16,
          max: 22,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.homeSoftGreen,
        borderRadius: BorderRadius.circular(
          _boundedWidth(
            24,
            min: 20,
            max: 26,
          ),
        ),
        border: Border.all(
          color: AppColors.coursesCertificationBorder
              .withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryGreen,
                size: _boundedWidth(
                  20,
                  min: 18,
                  max: 22,
                ),
              ),
              SizedBox(
                width: _boundedWidth(
                  10,
                  min: 8,
                  max: 12,
                ),
              ),
              Expanded(
                child: Text(
                  'final_exam_teacher_comments'.tr,
                  style: TextStyle(
                    fontSize: _boundedFont(
                      AppFont.font16,
                      min: 14,
                      max: 17,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          if (englishComment.isNotEmpty) ...<Widget>[
            SizedBox(
              height: _boundedHeight(
                18,
                min: 14,
                max: 20,
              ),
            ),
            Text(
              englishComment,
              style: TextStyle(
                fontSize: _boundedFont(
                  AppFont.font16,
                  min: 13,
                  max: 16,
                ),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: AppColors.homePrimaryText,
              ),
            ),
          ],
          if (englishComment.isNotEmpty &&
              banglaComment.isNotEmpty) ...<Widget>[
            SizedBox(
              height: _boundedHeight(
                14,
                min: 12,
                max: 16,
              ),
            ),
            Divider(
              height: 1,
              color: AppColors.coursesCertificationBorder
                  .withValues(alpha: 0.2),
            ),
          ],
          if (banglaComment.isNotEmpty) ...<Widget>[
            SizedBox(
              height: _boundedHeight(
                14,
                min: 12,
                max: 16,
              ),
            ),
            Text(
              banglaComment,
              style: TextStyle(
                fontSize: _boundedFont(
                  AppFont.font14,
                  min: 13,
                  max: 15,
                ),
                height: 1.45,
                color: AppColors.bodyText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}