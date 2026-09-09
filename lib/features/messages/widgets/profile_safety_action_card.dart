import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class ProfileSafetyActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDashed;
  final bool isBlockedAction;
  final VoidCallback? onTap;

  final double? cardHeight;
  final double? titleFontSize;

  const ProfileSafetyActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDashed = false,
    this.isBlockedAction = false,
    this.onTap,
    this.cardHeight,
    this.titleFontSize,
  });

  Color get _backgroundColor {
    if (isDashed) {
      return AppColors.white;
    }

    return isBlockedAction
        ? AppColors.safetyBlockedBg
        : AppColors.profileWarningBg;
  }

  Color get _borderColor {
    return isBlockedAction
        ? AppColors.safetyBlockedBorder
        : AppColors.profileWarningBorder;
  }

  Color get _titleColor {
    return isBlockedAction ? AppColors.primaryGreen : AppColors.profileRedText;
  }

  Color get _subtitleColor {
    return isBlockedAction ? AppColors.bodyText : AppColors.notificationRed;
  }

  Color get _iconBgColor {
    return isBlockedAction
        ? AppColors.homePaleGreen
        : AppColors.profileMutedIconBg;
  }

  Color get _iconColor {
    if (isDashed) {
      return AppColors.profileRedText;
    }

    return isBlockedAction ? AppColors.primaryGreen : AppColors.profileRedText;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: isDashed ? _DashedBorderPainter() : null,
        child: Container(
          constraints: BoxConstraints(
            minHeight: (cardHeight ?? kProfileSafetyCardHeight).h,
          ),
          padding: EdgeInsets.fromLTRB(28.w, 32.h, 18.w, 24.h),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(kRadius38.r),
            border: isDashed
                ? null
                : Border.all(color: _borderColor, width: 2.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: kProfileActionIconSize.w,
                height: kProfileActionIconSize.w,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22.w, color: _iconColor),
              ),
              SizedBox(height: 18.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (titleFontSize ?? AppFont.font16).sp,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font10.sp,
                      fontWeight: FontWeight.w500,
                      color: _subtitleColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.profileReportBorder
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final RRect border = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(kRadius38.r),
    );
    final Path path = Path()..addRRect(border);
    final PathMetrics metrics = path.computeMetrics();

    for (final PathMetric metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + 10.w;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + 8.w;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
