import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class StudentsAssistedCard extends StatelessWidget {
  const StudentsAssistedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 122.h,
      padding: EdgeInsets.only(top: 23.h),
      decoration: BoxDecoration(
        color: AppColors.serviceHubStatsBg,
        borderRadius: BorderRadius.circular(kRadius26.r),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '50k+',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: AppFont.font26.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Students Assisted',
            style: TextStyle(
              color: AppColors.homeSecondaryText,
              fontSize: AppFont.font10.sp,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: 62.w,
            height: 24.h,
            child: Stack(
              children: <Widget>[
                _AvatarBubble(
                  left: 0,
                  color: AppColors.legacyColorFFA9CCF0,
                  text: '',
                ),
                _AvatarBubble(
                  left: 17.w,
                  color: AppColors.legacyColorFFC8E8B7,
                  text: '',
                ),
                _AvatarBubble(
                  left: 34.w,
                  color: AppColors.legacyColorFFFFA500,
                  text: '+12',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  final double left;
  final Color color;
  final String text;

  const _AvatarBubble({
    required this.left,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white,
            width: 1.5.w,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: AppFont.font8.sp,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}