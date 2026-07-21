import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';

class ReportEvidencePicker
    extends StatelessWidget {
  const ReportEvidencePicker({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final XFile? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final XFile? image = selectedImage;

    return AnimatedSwitcher(
      duration:
      const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: image == null
          ? _EmptyEvidencePicker(
        key: const ValueKey<String>(
          'empty-evidence',
        ),
        onTap: onPickImage,
      )
          : _SelectedEvidencePreview(
        key: ValueKey<String>(
          image.path,
        ),
        image: image,
        onReplace: onPickImage,
        onRemove: onRemoveImage,
      ),
    );
  }
}

class _EmptyEvidencePicker
    extends StatelessWidget {
  const _EmptyEvidencePicker({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter:
      const _ReportDashedBorderPainter(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(18.r),
          child: Container(
            width: double.infinity,
            height: 144.h,
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white
                  .withValues(alpha: 0.55),
              borderRadius:
              BorderRadius.circular(18.r),
            ),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors
                        .reportUploadIconBg,
                    borderRadius:
                    BorderRadius.circular(
                      14.r,
                    ),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color:
                    AppColors.primaryGreen,
                    size: 25.w,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'add_screenshot_evidence'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                    AppFont.font14.sp,
                    fontWeight:
                    FontWeight.w700,
                    color: AppColors
                        .homePrimaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'png_or_jpg_max_5mb'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                    AppFont.font12.sp,
                    fontWeight:
                    FontWeight.w400,
                    color:
                    AppColors.bodyText,
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

class _SelectedEvidencePreview
    extends StatelessWidget {
  const _SelectedEvidencePreview({
    super.key,
    required this.image,
    required this.onReplace,
    required this.onRemove,
  });

  final XFile image;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius:
      BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onReplace,
        borderRadius:
        BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          height: 128.h,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(18.r),
            border: Border.all(
              color:
              AppColors.reportDashedBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius:
                BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 108.w,
                  height: 108.h,
                  child: Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                    errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                        ) {
                      return ColoredBox(
                        color: AppColors
                            .reportUploadIconBg,
                        child: Icon(
                          Icons
                              .broken_image_outlined,
                          color: AppColors
                              .primaryGreen,
                          size: 30.w,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      image.name,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize:
                        AppFont.font13.sp,
                        fontWeight:
                        FontWeight.w700,
                        height: 1.3,
                        color: AppColors
                            .homePrimaryText,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'png_or_jpg_max_5mb'.tr,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize:
                        AppFont.font11.sp,
                        height: 1.3,
                        color:
                        AppColors.bodyText,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Icon(
                      Icons.edit_outlined,
                      size: 20.w,
                      color:
                      AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              GestureDetector(
                onTap: onRemove,
                behavior:
                HitTestBehavior.opaque,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors
                        .blockDangerRed
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors
                        .blockDangerRed,
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportDashedBorderPainter
    extends CustomPainter {
  const _ReportDashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color =
          AppColors.reportDashedBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect border =
    RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(18.r),
    );

    final Path path =
    Path()..addRRect(border);

    for (final PathMetric metric
    in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final double end =
            distance + 7.w;

        canvas.drawPath(
          metric.extractPath(
            distance,
            end,
          ),
          paint,
        );

        distance = end + 5.w;
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}