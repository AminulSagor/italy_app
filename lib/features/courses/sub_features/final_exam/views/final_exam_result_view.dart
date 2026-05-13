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
            padding: EdgeInsets.fromLTRB(28.w, 38.h, 28.w, 132.h),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      child: Icon(Icons.arrow_back_rounded, color: AppColors.primaryGreen, size: 26.w),
                    ),
                    Expanded(
                      child: Text(
                        'Exam Results',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    Icon(Icons.share_outlined, color: AppColors.primaryGreen, size: 24.w),
                  ],
                ),
                SizedBox(height: 34.h),
                Container(
                  width: 210.w,
                  height: 210.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 12.w),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${result.markPercent}%',
                        style: TextStyle(
                          fontSize: AppFont.font42.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        'MARK ACHIEVED',
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 46.h),
                Text(
                  result.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font28.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(kHomePillRadius.r),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.homeNeutralShadow,
                        blurRadius: 18.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Text(
                    '⚡ +${result.xpAwarded} XP Awarded',
                    style: TextStyle(
                      fontSize: AppFont.font20.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homeOrange,
                    ),
                  ),
                ),
                SizedBox(height: 44.h),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 28.w,
                  mainAxisSpacing: 28.h,
                  childAspectRatio: 0.92,
                  children: const <Widget>[
                    _ResultStatCard(
                      icon: Icons.description_outlined,
                      label: 'Quiz &\nGrammar',
                      value: '28/30',
                      color: AppColors.primaryGreen,
                    ),
                    _ResultStatCard(
                      icon: Icons.headphones_rounded,
                      label: 'Listening',
                      value: '9/10',
                      color: AppColors.coursesChapterBlue,
                    ),
                    _ResultStatCard(
                      icon: Icons.edit_note_rounded,
                      label: 'Writing',
                      value: '8.5/10',
                      color: AppColors.vocabularyOrangeShadow,
                    ),
                    _ResultStatCard(
                      icon: Icons.record_voice_over_rounded,
                      label: 'Fluency &\nSpeaking',
                      value: '9/10',
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
                SizedBox(height: 44.h),
                _TeacherCommentCard(result: result),
              ],
            ),
          );
        }),
      ),
    );
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
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(kRadius14.r),
            ),
            child: Icon(icon, color: color, size: 28.w),
          ),
          SizedBox(height: 20.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFont.font26.sp,
              fontWeight: FontWeight.w900,
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
        borderRadius: BorderRadius.circular(kRadius34.r),
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
              Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryGreen, size: 26.w),
              SizedBox(width: 12.w),
              Text(
                "Teacher's Comments",
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Text(
            '"${result.teacherComment}"',
            style: TextStyle(
              fontSize: AppFont.font19.sp,
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 22.h),
          Divider(color: AppColors.coursesCertificationBorder.withValues(alpha: 0.18)),
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
