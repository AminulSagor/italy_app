import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/simple_appbar.dart';
import '../../../../courses/models/course_models.dart';
import '../../../views/_widgets/practice_hub_course_card.dart';
import '../controllers/course_catalog_controller.dart';

class CourseCatalogView extends GetView<CourseCatalogController> {
  const CourseCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: SimpleAppbar(
        title: 'Courses',
        onBackTap: () => Get.back<void>(),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              kHomeHorizontalPadding.w,
              12.h,
              kHomeHorizontalPadding.w,
              20.h,
            ),
            child: _CourseSearchField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.courses.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }

              if (controller.courses.isEmpty) {
                return _CourseCatalogEmptyState(
                  message: controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : controller.searchQuery.value.isEmpty
                      ? 'No active courses found.'
                      : 'No courses matched your search.',
                  onRefresh: controller.refreshCourses,
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: controller.refreshCourses,
                child: ListView.separated(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    kHomeHorizontalPadding.w,
                    4.h,
                    kHomeHorizontalPadding.w,
                    36.h,
                  ),
                  itemCount:
                      controller.courses.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, _) => SizedBox(height: 22.h),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= controller.courses.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      );
                    }

                    final CourseCardModel course = controller.courses[index];
                    return PracticeHubCourseCard(
                      course: course,
                      fullWidth: true,
                      onTap: () => controller.onCourseTap(course),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CourseSearchField extends StatelessWidget {
  const _CourseSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: AppColors.homeSecondaryText.withValues(alpha: 0.4),
          width: 1.w,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.primaryGreen,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: AppFont.font15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.homePrimaryText,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search courses by name',
          hintStyle: TextStyle(
            fontSize: AppFont.font15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.homeSecondaryText.withValues(alpha: 0.65),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 18.w, right: 8.w),
            child: Icon(
              Icons.search_rounded,
              size: 24.r,
              color: AppColors.homeSecondaryText,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 52.w),
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}

class _CourseCatalogEmptyState extends StatelessWidget {
  const _CourseCatalogEmptyState({
    required this.message,
    required this.onRefresh,
  });

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        children: <Widget>[
          SizedBox(height: 120.h),
          Icon(
            Icons.menu_book_outlined,
            size: 54.r,
            color: AppColors.homeSecondaryText,
          ),
          SizedBox(height: 18.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homeSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
