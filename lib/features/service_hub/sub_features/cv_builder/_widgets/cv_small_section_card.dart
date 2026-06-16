import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvSmallSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onAddTap;
  final Widget child;
  final String footerText;

  const CvSmallSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.onAddTap,
    required this.child,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius26.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30.w,
                height: 30.w,
                decoration: const BoxDecoration(
                  color: AppColors.homePaleGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: AppFont.font15.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            height: 38.h,
            padding: EdgeInsets.only(left: 14.w, right: 5.w),
            decoration: BoxDecoration(
              color: AppColors.legacyColorFFF1F2F2,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    cursorColor: AppColors.primaryGreen,
                    style: TextStyle(
                      color: AppColors.homePrimaryText,
                      fontSize: AppFont.font10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: AppColors.homeSecondaryText.withValues(
                          alpha: 0.55,
                        ),
                        fontSize: AppFont.font9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                      size: AppFont.font16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          child,
          SizedBox(height: 10.h),
          Text(
            footerText,
            style: TextStyle(
              color: AppColors.homeSecondaryText,
              fontSize: AppFont.font8.sp,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
