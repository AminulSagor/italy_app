import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_bottom_button.dart';
import '../_widgets/cv_color_bottom_sheet.dart';
import '../_widgets/cv_color_picker_card.dart';
import '../_widgets/cv_template_card.dart';
import '../controllers/cv_template_controller.dart';
import '../models/cv_builder_models.dart';

class ChooseCvTemplateView extends GetView<CvTemplateController> {
  const ChooseCvTemplateView({super.key});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = (1.sw - 38.w) / 2;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTemplates,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _Header(),
                      SizedBox(height: 26.h),
                      Text(
                        'Choose a Template',
                        style: TextStyle(
                          color: AppColors.homePrimaryText,
                          fontSize: AppFont.font22.sp,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -0.7,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Pick an admin-approved template and customize its color.',
                        style: TextStyle(
                          color: AppColors.homeSecondaryText,
                          fontSize: AppFont.font11.sp,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 22.h),
                      const _SearchBox(),
                      SizedBox(height: 18.h),
                      _CategoryChips(controller: controller),
                      SizedBox(height: 18.h),
                      _TemplateGrid(
                        controller: controller,
                        cardWidth: cardWidth,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Choose Color',
                        style: TextStyle(
                          color: AppColors.homePrimaryText,
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      CvColorPickerCard(
                        controller: controller,
                        onCustomTap: () => showCvColorBottomSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
              () => CvBottomButton(
                title: controller.selectedTemplate.value == null
                    ? 'Select a Template'
                    : 'Use This Template',
                onTap: controller.isLoading.value
                    ? () {}
                    : controller.useSelectedTemplate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: AppFont.font13.sp,
              color: AppColors.homeDarkGreen,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            size: AppFont.font17.sp,
            color: AppColors.homeSecondaryText,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Search hospitality templates...',
              style: TextStyle(
                color: AppColors.homeSecondaryText.withOpacity(0.65),
                fontSize: AppFont.font11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.controller});

  final CvTemplateController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27.h,
      child: Obx(() {
        final int selectedIndex = controller.selectedCategoryIndex.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 10.w),
          itemBuilder: (_, int index) {
            final bool isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => controller.selectCategory(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.homePaleGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  controller.categories[index],
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.homeSecondaryText,
                    fontSize: AppFont.font9.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _TemplateGrid extends StatelessWidget {
  const _TemplateGrid({required this.controller, required this.cardWidth});

  final CvTemplateController controller;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const _TemplateMessage(message: 'Loading CV templates...');
      }

      if (controller.templates.isEmpty) {
        return const _TemplateMessage(
          message: 'No CV templates are active yet. Please try again later.',
        );
      }

      return Wrap(
        spacing: 12.w,
        runSpacing: 18.h,
        children: List<Widget>.generate(controller.templates.length, (int index) {
          final CvTemplateModel template = controller.templates[index];
          return CvTemplateCard(
            width: cardWidth,
            title: template.title,
            tag: template.styleType.toUpperCase().replaceAll('_', ' '),
            tagColor: controller.colors[index % controller.colors.length],
            isSelected: controller.selectedTemplateIndex.value == index,
            onTap: () => controller.startWithTemplate(index),
          );
        }),
      );
    });
  }
}

class _TemplateMessage extends StatelessWidget {
  const _TemplateMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius24.r),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.homeSecondaryText,
          fontSize: AppFont.font11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
