import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class GuideBottomActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const GuideBottomActionButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Material(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            child: Container(
              height: 54.h,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppFont.font13.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(
                    Icons.public_rounded,
                    color: AppColors.white,
                    size: AppFont.font16.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}