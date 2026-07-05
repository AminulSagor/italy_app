import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvReadyPreviewCard extends StatelessWidget {
  final VoidCallback onTap;
  final Uint8List? pdfBytes;
  final bool isLoading;

  const CvReadyPreviewCard({
    super.key,
    required this.onTap,
    required this.pdfBytes,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(kRadius26.r),
      child: InkWell(
        onTap: pdfBytes == null || isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(kRadius26.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 292.h),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(kRadius26.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadius20.r),
            child: Container(
              height: 332.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(kRadius20.r),
                border: Border.all(
                  color: AppColors.legacyColorFFF1F2F2,
                  width: 1.w,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: _PreviewContent(pdfBytes: pdfBytes)),
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: AppColors.white.withOpacity(0.72),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14.h,
                    child: Center(
                      child: Container(
                        height: 28.h,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            kButtonDefaultRadius.r,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.homeNeutralShadow,
                              blurRadius: 12.r,
                              offset: Offset(0, 5.h),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.picture_as_pdf_rounded,
                              color: AppColors.primaryGreen,
                              size: AppFont.font11.sp,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              isLoading
                                  ? 'preparing_pdf'.tr
                                  : 'tap_to_open_pdf'.tr,
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: AppFont.font9.sp,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewContent extends StatelessWidget {
  final Uint8List? pdfBytes;

  const _PreviewContent({required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = pdfBytes;
    if (bytes == null || bytes.isEmpty) {
      return const _PreviewPlaceholder();
    }

    return IgnorePointer(
      child: SfPdfViewer.memory(
        bytes,
        key: ValueKey<int>(bytes.length),
        pageLayoutMode: PdfPageLayoutMode.single,
        scrollDirection: PdfScrollDirection.vertical,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPaginationDialog: false,
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: AppColors.legacyColorFFD4DEE8,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.homeBlueIcon,
                  size: AppFont.font26.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _PreviewLine(width: 84.w, height: 8.h),
                    SizedBox(height: 10.h),
                    _PreviewLine(width: 54.w, height: 6.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 26.h),
          _PreviewLine(
            width: 70.w,
            height: 9.h,
            color: AppColors.legacyColorFFCDE6BD,
          ),
          SizedBox(height: 14.h),
          _PreviewLine(width: 150.w, height: 6.h),
          SizedBox(height: 9.h),
          _PreviewLine(width: 120.w, height: 6.h),
          SizedBox(height: 9.h),
          _PreviewLine(width: 92.w, height: 6.h),
          SizedBox(height: 24.h),
          _PreviewLine(
            width: 70.w,
            height: 9.h,
            color: AppColors.legacyColorFFCDE6BD,
          ),
          SizedBox(height: 14.h),
          _PreviewLine(width: 150.w, height: 6.h),
          SizedBox(height: 9.h),
          _PreviewLine(width: 120.w, height: 6.h),
          SizedBox(height: 9.h),
          _PreviewLine(width: 92.w, height: 6.h),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;

  const _PreviewLine({required this.width, required this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      ),
    );
  }
}
