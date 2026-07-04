import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/final_exam_controller.dart';
import '../models/final_exam_models.dart';
import '../widgets/final_exam_common_widgets.dart';

class FinalExamOverviewView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamOverviewView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.exam,
      sourceId: 'final_exam_overview_view',
      child: Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      bottomNavigationBar: Obx(() {
        final FinalExamOverviewModel? overview = controller.overview.value;
        return FinalExamBottomButton(
          label: overview?.canStart == true
              ? 'Start The Exam'
              : 'Final Exam Locked',
          onTap: controller.startExam,
          isLoading: controller.isSubmitting.value,
        );
      }),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final FinalExamOverviewModel? overview = controller.overview.value;

          if (controller.isLoading.value && overview == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (overview == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 84.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FinalExamTopBar(
                  title: overview.title,
                  onBackTap: () => Get.back<void>(),
                ),
                SizedBox(height: 30.h),
                _HeroCard(overview: overview),
                SizedBox(height: 30.h),
                Text(
                  'EXAM COMPONENTS',
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 14.h),
                ...overview.components.map(
                  (FinalExamComponentModel item) => Padding(
                    padding: EdgeInsets.only(bottom: 18.h),
                    child: FinalExamComponentTile(component: item),
                  ),
                ),
                SizedBox(height: 25.h),
                _ManualReviewNote(
                  bangla: overview.noteBangla,
                  english: overview.noteEnglish,
                ),
              ],
            ),
          );
        }),
      ),
    ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final FinalExamOverviewModel overview;

  const _HeroCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.homeDarkGreen, AppColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(kRadius48.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 22.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Image.asset('assets/decor_png/gown_cap.png'),
          Text(
            overview.heroTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            overview.heroSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w400,
              height: 1.35,
              color: AppColors.homePaleGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualReviewNote extends StatelessWidget {
  final String bangla;
  final String english;

  const _ManualReviewNote({required this.bangla, required this.english});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: AppColors.reportReviewBg,
        borderRadius: BorderRadius.circular(kRadius34.r),
        border: Border.all(
          color: AppColors.reportReviewText.withValues(alpha: 0.35),
          width: 2.w,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.manage_search_rounded,
            color: AppColors.reportReviewText,
            size: 34.w,
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  bangla,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: AppColors.reportReviewText,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  english,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: AppColors.reportReviewText,
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
