import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_constants.dart';
import '../../../../core/themes/app_font.dart';
import '../../../courses/models/course_models.dart';
import '../../controllers/practice_hub_controller.dart';
import 'practice_hub_course_card.dart';

class PracticeHubCourseCarousel extends GetView<PracticeHubController> {
  const PracticeHubCourseCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 252,
      child: Obx(() {
        if (controller.isCoursesLoading.value && controller.courses.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (controller.courses.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding.w),
            child: const _EmptyCoursesCard(),
          );
        }

        return ListView.separated(
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: kHomeHorizontalPadding.w,
            right: 24.w,
            bottom: 10.h,
          ),
          itemCount: controller.courses.length,
          separatorBuilder: (_, _) => SizedBox(width: 16.w),
          itemBuilder: (BuildContext context, int index) {
            final CourseCardModel course = controller.courses[index];
            return PracticeHubCourseCard(
              course: course,
              onTap: () => controller.onCourseTap(index),
            );
          },
        );
      }),
    );
  }
}

class _EmptyCoursesCard extends StatelessWidget {
  const _EmptyCoursesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 238,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(38.r),
        border: Border.all(color: const Color(0xFFE4E4E4), width: 1.2.w),
      ),
      child: Text(
        'no_active_courses_found'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppFont.font16.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF6B6D70),
        ),
      ),
    );
  }
}
