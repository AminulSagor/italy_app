import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class GuideStepTile extends StatelessWidget {
  final String number;
  final String text;

  const GuideStepTile({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 50.h,
      ),
      padding: EdgeInsets.fromLTRB(10.w, 9.h, 12.w, 9.h),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.homeSecondaryText,
                fontSize: AppFont.font9.sp,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}