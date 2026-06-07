import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_constants.dart';
import '../../../../../../../core/themes/app_font.dart';

class AdministrativeSearchBar extends StatelessWidget {
  const AdministrativeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.adminSearchShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            color: AppColors.homeSecondaryText,
            size: AppFont.font17.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Find specific office or service...',
              style: TextStyle(
                color: AppColors.homeSecondaryText,
                fontSize: AppFont.font9.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}