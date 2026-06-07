import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvProfilePhotoCard extends StatelessWidget {
  final VoidCallback onUploadTap;

  const CvProfilePhotoCard({
    super.key,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius26.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.legacyColorFFE0E1E1,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white,
                width: 2.w,
              ),
            ),
            child: Icon(
              Icons.account_circle_outlined,
              color: AppColors.homeSecondaryText,
              size: AppFont.font30.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Professional Profile',
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font11.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(height: 9.h),
                Material(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                  child: InkWell(
                    onTap: onUploadTap,
                    borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                    child: Container(
                      height: 34.h,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.white,
                            size: AppFont.font12.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Upload Professional Photo',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: AppFont.font9.sp,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
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