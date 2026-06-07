import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/cv_template_controller.dart';

class CvColorPickerCard extends StatelessWidget {
  final CvTemplateController controller;
  final VoidCallback onCustomTap;

  const CvColorPickerCard({
    super.key,
    required this.controller,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 112.h,
      ),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 32.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.colors.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (_, int index) {
                return Obx(() {
                  final bool isSelected =
                      controller.selectedColorIndex.value == index;

                  return GestureDetector(
                    onTap: () => controller.selectColor(index),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: controller.colors[index],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                          color: AppColors.white,
                          width: 3.w,
                        )
                            : null,
                        boxShadow: isSelected
                            ? <BoxShadow>[
                          BoxShadow(
                            color: controller.colors[index]
                                .withOpacity(0.35),
                            blurRadius: 8.r,
                            spreadRadius: 2.r,
                          ),
                        ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: AppFont.font16.sp,
                      )
                          : null,
                    ),
                  );
                });
              },
            ),
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: onCustomTap,
            child: Column(
              children: <Widget>[
                Container(
                  width: 31.w,
                  height: 31.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 1.w,
                    ),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    color: AppColors.primaryGreen,
                    size: AppFont.font15.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Custom',
                  style: TextStyle(
                    color: AppColors.homeSecondaryText,
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w600,
                    height: 1,
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