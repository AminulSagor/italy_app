import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CafPathCard extends StatelessWidget {
  final double minHeight;
  final List<Color> gradientColors;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final String title;
  final String description;
  final String buttonText;
  final int descriptionMaxLines;
  final VoidCallback onTap;

  const CafPathCard({
    super.key,
    required this.minHeight,
    required this.gradientColors,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.title,
    required this.description,
    required this.buttonText,
    this.descriptionMaxLines = 2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius26.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.24),
            blurRadius: 22.r,
            offset: Offset(0, 14.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _IconCircle(icon: leadingIcon),
              _IconCircle(icon: trailingIcon),
            ],
          ),
          SizedBox(height: 26.h),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              height: 1.08,
              letterSpacing: -0.45,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            description,
            maxLines: descriptionMaxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.78),
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w500,
              height: 1.18,
              letterSpacing: -0.15,
            ),
          ),
          SizedBox(height: 18.h),
          _CardButton(
            text: buttonText,
            color: gradientColors.last,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;

  const _IconCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.serviceHubLightGreen,
        size: AppFont.font19.sp,
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _CardButton({
    required this.text,
    required this.color,
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
          height: 34.h,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Text(
            '$text  ›',
            style: TextStyle(
              color: color,
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}
