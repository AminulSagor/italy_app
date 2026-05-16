import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class WebinarBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;

  const WebinarBackButton({
    super.key,
    required this.onTap,
    this.iconColor = AppColors.primaryGreen,
    this.backgroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: kWebinarBackButtonSize.w,
        height: kWebinarBackButtonSize.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_rounded, color: iconColor, size: 24.w),
      ),
    );
  }
}

class WebinarPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackTap;
  final Widget? trailing;

  const WebinarPageHeader({
    super.key,
    required this.title,
    required this.onBackTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        WebinarBackButton(onTap: onBackTap),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        SizedBox(width: kWebinarBackButtonSize.w, child: trailing),
      ],
    );
  }
}

class WebinarTeacherImage extends StatelessWidget {
  final bool alt;
  final double borderRadius;

  const WebinarTeacherImage({
    super.key,
    this.alt = false,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            alt ? AppColors.webinarVideoAltTop : AppColors.webinarVideoTop,
            alt
                ? AppColors.webinarVideoAltBottom
                : AppColors.webinarVideoBottom,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: alt ? Alignment.center : Alignment.center,
            child: Icon(
              Icons.person_rounded,
              color: AppColors.white.withValues(alpha: 0.62),
              size: alt ? 168.w : 148.w,
            ),
          ),
          Image.asset('assets/decor_png/webinar.png'),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.transparent,
                  AppColors.black.withValues(alpha: 0.58),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebinarLiveBadge extends StatelessWidget {
  const WebinarLiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.webinarLiveRed,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: AppFont.font10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
