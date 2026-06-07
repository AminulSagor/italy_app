import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvSelectableChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isAiSuggested;
  final bool isOutline;
  final bool fullWidth;
  final bool showCloseIcon;
  final IconData? icon;
  final VoidCallback onTap;

  const CvSelectableChip({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isAiSuggested = false,
    this.isOutline = false,
    this.fullWidth = false,
    this.showCloseIcon = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isSelected
        ? AppColors.primaryGreen
        : isAiSuggested
        ? AppColors.homePaleGreen
        : AppColors.white;

    final Color textColor = isSelected
        ? AppColors.white
        : isAiSuggested
        ? AppColors.primaryGreen
        : AppColors.homePrimaryText;

    final Widget child = GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: fullWidth ? 14.w : 12.w,
          vertical: fullWidth ? 12.h : 8.h,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          border: Border.all(
            color: isOutline
                ? AppColors.homeSecondaryText.withOpacity(0.22)
                : AppColors.transparent,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment:
          fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: AppFont.font13.sp,
                color: textColor,
              ),
              SizedBox(width: 7.w),
            ],
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: AppFont.font8.sp,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            if (isSelected || isAiSuggested) ...<Widget>[
              SizedBox(width: 6.w),
              Icon(
                showCloseIcon
                    ? Icons.close_rounded
                    : isAiSuggested
                    ? Icons.add_rounded
                    : Icons.check_rounded,
                size: AppFont.font11.sp,
                color: textColor,
              ),
            ],
          ],
        ),
      ),
    );

    if (!isOutline) return child;

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.homeSecondaryText.withOpacity(0.22),
        radius: kButtonDefaultRadius.r,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rRect);

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      const double dashLength = 5;
      const double dashGap = 4;

      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}