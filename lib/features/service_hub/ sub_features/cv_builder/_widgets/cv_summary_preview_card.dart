import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvSummaryPreviewCard extends StatelessWidget {
  final bool hasGeneratedSummary;
  final String summary;
  final VoidCallback onRegenerateTap;
  final VoidCallback onEditTap;

  const CvSummaryPreviewCard({
    super.key,
    required this.hasGeneratedSummary,
    required this.summary,
    required this.onRegenerateTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasGeneratedSummary) {
      return CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.adminHealthBg,
          radius: kRadius26.r,
        ),
        child: Container(
          height: 132.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(kRadius26.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: AppColors.legacyColorFFF1F2F2,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: AppColors.homeSecondaryText,
                  size: AppFont.font22.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Result Preview',
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Your professional Italian summary will\nappear here once generated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.homeSecondaryText,
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius26.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.homePaleGreen,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            ),
            child: Text(
              'Professional Summary',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: AppFont.font9.sp,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            summary,
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font13.sp,
              fontWeight: FontWeight.w500,
              height: 1.45,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.15,
            ),
          ),
          SizedBox(height: 22.h),
          Row(
            children: <Widget>[
              _SummaryActionButton(
                icon: Icons.refresh_rounded,
                title: 'Regenerate',
                onTap: onRegenerateTap,
              ),
              SizedBox(width: 10.w),
              _SummaryActionButton(
                icon: Icons.edit_rounded,
                title: 'Edit Text',
                onTap: onEditTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SummaryActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          child: Container(
            height: 36.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              border: Border.all(
                color: AppColors.primaryGreen,
                width: 1.w,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: AppFont.font13.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      ..strokeWidth = 1.2
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