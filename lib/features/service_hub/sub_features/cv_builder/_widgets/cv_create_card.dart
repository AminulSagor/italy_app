import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvCreateCard extends StatelessWidget {
  final VoidCallback onTap;

  const CvCreateCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius26.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.serviceHubGreenStart,
            AppColors.serviceHubGreenEnd,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.24),
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              child: Container(
                height: 44.h,
                constraints: BoxConstraints(minWidth: 170.w),
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.add_rounded,
                      color: AppColors.primaryGreen,
                      size: AppFont.font20.sp,
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      'CREATE NEW CV',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: AppFont.font11.sp,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'You have used 2 out of 3 free CV\ngenerations.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.82),
              fontSize: AppFont.font9.sp,
              fontWeight: FontWeight.w600,
              height: 1.25,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
