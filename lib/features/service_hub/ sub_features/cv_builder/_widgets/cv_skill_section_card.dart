import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/create_cv_education_controller.dart';
import 'cv_selectable_chip.dart';

class CvSkillSectionCard extends StatelessWidget {
  final CreateCvEducationController controller;

  const CvSkillSectionCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius26.r),
      ),
      child: Obx(() {
        final List<String> skills = controller.skills.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: skills
                  .map(
                    (String item) => CvSelectableChip(
                  title: item,
                  isSelected: true,
                  showCloseIcon: true,
                  onTap: () => controller.removeSkill(item),
                ),
              )
                  .toList(),
            ),
            SizedBox(height: 12.h),
            Text(
              'Skills you selected or confirmed appear here.',
              style: TextStyle(
                color: AppColors.homeSecondaryText,
                fontSize: AppFont.font8.sp,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        );
      }),
    );
  }
}