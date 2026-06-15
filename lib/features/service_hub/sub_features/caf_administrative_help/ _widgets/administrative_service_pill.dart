import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_constants.dart';
import '../../../../../../../core/themes/app_font.dart';

class AdministrativeServicePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final VoidCallback onTap;

  const AdministrativeServicePill({
    super.key,
    required this.icon,
    required this.label,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
        child: Container(
          height: 62.h,
          padding: EdgeInsets.fromLTRB(16.w, 0, 14.w, 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: AppColors.legacyColorFFF1F2F2,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.adminBrown,
                  size: AppFont.font16.sp,
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.homeSecondaryText,
                        fontSize: AppFont.font8.sp,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.homePrimaryText,
                        fontSize: AppFont.font11.sp,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.homeSecondaryText,
                size: AppFont.font20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}