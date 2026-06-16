import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_bottom_button.dart';
import '../controllers/create_cv_theme_controller.dart';

class CreateCvThemeView extends GetView<CreateCvThemeController> {
  const CreateCvThemeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _Header(),
                    SizedBox(height: 22.h),
                    Text(
                      'Choose Theme Colors',
                      style: TextStyle(
                        color: AppColors.homePrimaryText,
                        fontSize: AppFont.font23.sp,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Only template colors marked as Primary or Accent will change. Custom colors from the admin template will stay fixed.',
                      style: TextStyle(
                        color: AppColors.homeSecondaryText,
                        fontSize: AppFont.font11.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    Obx(
                      () => _ThemePreview(
                        primaryColor: controller.colorFromHex(
                          controller.selectedPrimaryColor.value,
                        ),
                        accentColor: controller.colorFromHex(
                          controller.selectedAccentColor.value,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    _ColorSelector(
                      title: 'Primary Color',
                      selectedHex: controller.selectedPrimaryColor,
                      onSelected: controller.selectPrimaryColor,
                    ),
                    SizedBox(height: 16.h),
                    _ColorSelector(
                      title: 'Accent Color',
                      selectedHex: controller.selectedAccentColor,
                      onSelected: controller.selectAccentColor,
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => CvBottomButton(
                title: controller.isSaving.value ? 'Saving...' : 'Create CV',
                onTap: controller.isSaving.value
                    ? () {}
                    : controller.saveCvDocument,
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

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.primaryColor, required this.accentColor});

  final Color primaryColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius24.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 74.w,
            height: 94.h,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(kRadius16.r),
            ),
            child: Center(
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.w),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Final CV Theme',
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 8.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 8.h,
                  width: 86.w,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(99.r),
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

class _ColorSelector extends GetView<CreateCvThemeController> {
  const _ColorSelector({
    required this.title,
    required this.selectedHex,
    required this.onSelected,
  });

  final String title;
  final RxString selectedHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14.h),
          Obx(
            () => Wrap(
              spacing: 14.w,
              runSpacing: 14.h,
              children: controller.colorOptions.map((String colorHex) {
                final bool isSelected = selectedHex.value == colorHex;
                final Color color = controller.colorFromHex(colorHex);

                return GestureDetector(
                  onTap: () => onSelected(colorHex),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.homePrimaryText
                            : AppColors.white,
                        width: isSelected ? 3.w : 1.w,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: color.withOpacity(0.22),
                          blurRadius: 9.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: AppColors.white,
                            size: AppFont.font17.sp,
                          )
                        : null,
                  ),
                );
              }).toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}
