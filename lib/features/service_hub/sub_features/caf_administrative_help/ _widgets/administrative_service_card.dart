import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_constants.dart';
import '../../../../../../../core/themes/app_font.dart';

class AdministrativeServiceCard extends StatelessWidget {
  final double height;
  final double? width;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String title;
  final Color labelColor;
  final String? trailingText;
  final VoidCallback onTap;

  const AdministrativeServiceCard({
    super.key,
    required this.height,
    this.width,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.title,
    required this.labelColor,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = width != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 13.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(kRadius26.r),
        ),
        child: isWide ? _buildWideContent() : _buildSmallContent(),
      ),
    );
  }

  Widget _buildSmallContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _IconBox(
          icon: icon,
          iconColor: iconColor,
          backgroundColor: iconBackgroundColor,
        ),
        const Spacer(),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: AppFont.font8.sp,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.homePrimaryText,
            fontSize: AppFont.font10.sp,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.15,
          ),
        ),
      ],
    );
  }

  Widget _buildWideContent() {
    return Row(
      children: <Widget>[
        _IconBox(
          icon: icon,
          iconColor: iconColor,
          backgroundColor: iconBackgroundColor,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: AppFont.font8.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font13.sp,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
            ],
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText!,
            style: TextStyle(
              color: AppColors.homeSecondaryText.withValues(alpha: 0.18),
              fontSize: AppFont.font9.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _IconBox({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31.w,
      height: 31.w,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: AppFont.font16.sp),
    );
  }
}
