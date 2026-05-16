import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvStepProgress extends StatelessWidget {
  final String title;
  final String progressText;
  final double progress;

  const CvStepProgress({
    super.key,
    required this.title,
    required this.progressText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7.h,
            backgroundColor: AppColors.legacyColorFFD0D1D2,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryGreen,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: AppColors.homePrimaryText,
                fontSize: AppFont.font11.sp,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const Spacer(),
            Text(
              progressText,
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: AppFont.font11.sp,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}