import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/final_exam_controller.dart';
import '../models/final_exam_models.dart';

class FinalExamResultView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamResultView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(28.w, 18.h, 28.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 22.r,
              offset: Offset(0, -8.h),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: CustomButton.primary(
            onPressed: controller.openCertificate,
            text: 'View Official Certificate',
            icon: Icons.article_outlined,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final FinalExamResultModel? result = controller.result.value;

          if (controller.isLoading.value && result == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (result == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 60.h),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primaryGreen,
                        size: 22.w,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Exam Results',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.share_outlined,
                      color: AppColors.primaryGreen,
                      size: 22.w,
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Container(
                  width: 200.w,
                  height: 200.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 10.w,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${result.markPercent}%',
                        style: TextStyle(
                          fontSize: AppFont.font36.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        'MARK ACHIEVED',
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.4,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  result.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  result.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 36.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(kHomePillRadius.r),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.homeNeutralShadow,
                        blurRadius: 30.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Text(
                    '⚡ +${result.xpAwarded} XP Awarded',
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homeOrange,
                    ),
                  ),
                ),
                SizedBox(height: 44.h),
                if (result.stats.isNotEmpty)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 24.w,
                    mainAxisSpacing: 24.h,
                    childAspectRatio: 0.84,
                    children: result.stats.map((FinalExamResultStatModel stat) {
                      return _ResultStatCard(
                        icon: _statIcon(stat.iconName),
                        label: stat.label,
                        value: stat.value,
                        color: _statColor(stat.iconName),
                      );
                    }).toList(growable: false),
                  ),
                if (result.teacherComment.isNotEmpty ||
                    result.teacherCommentBangla.isNotEmpty) ...<Widget>[
                  SizedBox(height: 44.h),
                  _TeacherCommentCard(result: result),
                ],
              ],
            ),
          );
        }),
      ),
    );
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
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius30.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 35.r,
            offset: Offset(0, 15.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(kRadius16.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(height: 14.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFont.font24.sp,
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

  const _TeacherCommentCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: AppColors.homeSoftGreen,
        borderRadius: BorderRadius.circular(kRadius48.r),
        border: Border.all(
          color: AppColors.coursesCertificationBorder.withValues(alpha: 0.35),
          width: 2.w,
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
                size: 22.w,
              ),
              SizedBox(width: 12.w),
              Text(
                "Teacher's Comments",
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Text(
            '"${result.teacherComment}"',
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 16.h),
          Divider(
            color: AppColors.coursesCertificationBorder.withValues(alpha: 0.18),
          ),
          SizedBox(height: 16.h),
          Text(
            result.teacherCommentBangla,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              height: 1.45,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
