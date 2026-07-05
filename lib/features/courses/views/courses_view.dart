import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/courses_controller.dart';
import '../models/course_models.dart';
import '../widgets/course_level_card.dart';
import '../widgets/skill_builder_card.dart';
import '../widgets/specialized_learning_card.dart';

class CoursesView extends GetView<CoursesController> {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Material(
        color: AppColors.homeBackground,
        child: SafeArea(
          top: false,
          child:
              controller.isLoading.value && controller.dashboard.value == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                )
              : _CoursesLoadedBody(dashboard: controller.dashboard.value),
        ),
      ),
    );
  }
}

class _CoursesLoadedBody extends GetView<CoursesController> {
  final CoursesDashboardModel? dashboard;

  const _CoursesLoadedBody({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final CoursesDashboardModel data = dashboard ?? _emptyDashboard;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 22.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: kCoursesHorizontalPadding.w,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'gen_practice_hub_courses'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homePrimaryText,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'gen_view_all'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 26.h),
          SizedBox(
            height: kCourseCardHeight.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: kCoursesHorizontalPadding.w,
              ),
              itemCount: data.courses.length,
              separatorBuilder: (_, _) => SizedBox(width: 18.w),
              itemBuilder: (BuildContext context, int index) {
                final CourseCardModel course = data.courses[index];
                return CourseLevelCard(
                  course: course,
                  onTap: () => controller.openCourse(course),
                );
              },
            ),
          ),
          SizedBox(height: 58.h),
          _SectionTitle(title: 'gen_skill_builders'.tr),
          SizedBox(height: 26.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: kCoursesHorizontalPadding.w,
            ),
            child: GridView.builder(
              itemCount: data.skillBuilders.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20.w,
                mainAxisSpacing: 26.h,
                childAspectRatio: 1.82,
              ),
              itemBuilder: (_, int index) {
                return SkillBuilderCard(skill: data.skillBuilders[index]);
              },
            ),
          ),
          SizedBox(height: 54.h),
          _SectionTitle(title: 'gen_specialized_learning'.tr),
          SizedBox(height: 28.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: kCoursesHorizontalPadding.w,
            ),
            child: SpecializedLearningCard(item: data.specializedLearning),
          ),
        ],
      ),
    );
  }

  static const CoursesDashboardModel _emptyDashboard = CoursesDashboardModel(
    courses: <CourseCardModel>[],
    skillBuilders: <SkillBuilderModel>[],
    specializedLearning: SpecializedLearningModel(
      title: '',
      subtitle: '',
      requirementLabel: '',
      lockedLabel: '',
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kCoursesHorizontalPadding.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppFont.font24.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.homePrimaryText,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}
