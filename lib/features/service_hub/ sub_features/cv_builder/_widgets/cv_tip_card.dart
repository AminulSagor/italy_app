import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvTipCard extends StatelessWidget {
  const CvTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 48.h,
      ),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 9.h, 14.w, 9.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.profileOrangeCardBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: AppColors.homeOrange,
              size: AppFont.font15.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Pro Tip: Create different CVs for different\njobs to increase your hiring chances!',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.homePrimaryText,
                fontSize: AppFont.font8.sp,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}