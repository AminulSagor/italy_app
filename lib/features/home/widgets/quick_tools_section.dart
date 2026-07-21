import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/home_models.dart';

class QuickToolsSection extends StatelessWidget {
  const QuickToolsSection({super.key, required this.tools, this.onToolTap});

  final List<HomeToolModel> tools;
  final void Function(HomeToolModel tool)? onToolTap;

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'quick_tools'.tr,
          style: TextStyle(
            fontSize: AppFont.font20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.homePrimaryText,
          ),
        ),
        SizedBox(height: 16.h),
        ...tools.map(
          (HomeToolModel tool) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _QuickToolCard(
              tool: tool,
              onTap: () => onToolTap?.call(tool),
              // onTap: () => Get.snackbar("In Progress", "Feature coming soon"),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickToolCard extends StatelessWidget {
  const _QuickToolCard({required this.tool, this.onTap});

  final HomeToolModel tool;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kHomeSmallCardRadius.r),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 112.h),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.homeBlueCard,
          borderRadius: BorderRadius.circular(kHomeSmallCardRadius.r),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: kHomeIconCircleSize.w,
              height: kHomeIconCircleSize.w,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.homeBlueIcon,
              ),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tool.title,
                    style: TextStyle(
                      fontSize: AppFont.font17.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    tool.subtitle,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.homeSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.homeBlueIcon,
            ),
          ],
        ),
      ),
    );
  }
}
