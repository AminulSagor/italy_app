import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import 'package:get/get.dart';

class ReportEvidencePicker extends StatelessWidget {
  final XFile? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const ReportEvidencePicker({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ReportDashedBorderPainter(),
      child: GestureDetector(
        onTap: onPickImage,
        child: Container(
          width: double.infinity,
          height: kReportEvidenceBoxHeight.h,
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 34.h),
          decoration: BoxDecoration(
            color: AppColors.homeBackground,
            borderRadius: BorderRadius.circular(kRadius38.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 74.w,
                height: 74.w,
                decoration: BoxDecoration(
                  color: AppColors.reportUploadIconBg,
                  borderRadius: BorderRadius.circular(kRadius20.r),
                ),
                child: Icon(
                  Icons.image_rounded,
                  color: AppColors.primaryGreen,
                  size: 34.w,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                'add_screenshot_evidence'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homePrimaryText,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'png_or_jpg_max_5mb'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyText,
                ),
              ),
              if (selectedImage != null) ...<Widget>[
                SizedBox(height: 28.h),
                _SelectedEvidenceImage(
                  image: selectedImage!,
                  onRemoveImage: onRemoveImage,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedEvidenceImage extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemoveImage;

  const _SelectedEvidenceImage({
    required this.image,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kReportEvidencePreviewSize.w + 30.w,
      height: kReportEvidencePreviewSize.w + 30.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kRadius14.r),
              child: Image.file(
                File(image.path),
                width: kReportEvidencePreviewSize.w,
                height: kReportEvidencePreviewSize.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onRemoveImage,
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: const BoxDecoration(
                  color: AppColors.blockDangerRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, color: AppColors.white, size: 26.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportDashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.reportDashedBorder
      ..strokeWidth = 2.4.w
      ..style = PaintingStyle.stroke;

    final RRect border = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(kRadius38.r),
    );
    final Path path = Path()..addRRect(border);

    for (final PathMetric metric in path.computeMetrics()) {
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
