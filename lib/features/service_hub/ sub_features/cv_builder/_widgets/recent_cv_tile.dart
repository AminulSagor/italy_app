import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class RecentCvTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool isCompleted;
  final VoidCallback onTap;

  const RecentCvTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCompleted ? AppColors.white : AppColors.transparent,
      borderRadius: BorderRadius.circular(kRadius20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadius20.r),
        child: Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.white : AppColors.transparent,
            borderRadius: BorderRadius.circular(kRadius20.r),
            border: isCompleted
                ? null
                : Border.all(
              color: AppColors.homeSecondaryText.withOpacity(0.18),
              width: 1.w,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.legacyColorFFF1F2F2,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.history_rounded
                      : Icons.description_outlined,
                  color: AppColors.homeSecondaryText,
                  size: AppFont.font14.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.homePrimaryText,
                              fontSize: AppFont.font11.sp,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.homePaleGreen
                                : AppColors.legacyColorFFF1F2F2,
                            borderRadius: BorderRadius.circular(
                              kButtonDefaultRadius.r,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isCompleted
                                  ? AppColors.primaryGreen
                                  : AppColors.homeSecondaryText,
                              fontSize: AppFont.font7.sp,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.homeSecondaryText,
                        fontSize: AppFont.font9.sp,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}