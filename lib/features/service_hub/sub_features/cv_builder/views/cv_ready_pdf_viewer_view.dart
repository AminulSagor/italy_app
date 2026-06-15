import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';

class CvReadyPdfViewerView extends StatefulWidget {
  final String title;
  final Uint8List pdfBytes;

  const CvReadyPdfViewerView({
    super.key,
    required this.title,
    required this.pdfBytes,
  });

  @override
  State<CvReadyPdfViewerView> createState() => _CvReadyPdfViewerViewState();
}

class _CvReadyPdfViewerViewState extends State<CvReadyPdfViewerView> {
  late final PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _ViewerHeader(title: widget.title),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.homeNeutralShadow,
                      blurRadius: 18.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SfPdfViewer.memory(
                  widget.pdfBytes,
                  controller: _pdfViewerController,
                  pageLayoutMode: PdfPageLayoutMode.single,
                  scrollDirection: PdfScrollDirection.vertical,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  canShowPaginationDialog: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerHeader extends StatelessWidget {
  final String title;

  const _ViewerHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryGreen,
                size: AppFont.font19.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.homePrimaryText,
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
