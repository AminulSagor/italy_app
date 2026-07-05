import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';

class ChapterPdfViewer extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const ChapterPdfViewer({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<ChapterPdfViewer> createState() => _ChapterPdfViewerState();
}

class _ChapterPdfViewerState extends State<ChapterPdfViewer> {
  late final PdfViewerController _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;

  bool get _canGoPrevious => _currentPage > 1;
  bool get _canGoNext => _totalPages > 0 && _currentPage < _totalPages;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10201B),
      body: Stack(
        children: <Widget>[
          const _PdfDarkBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                children: <Widget>[
                  _PdfViewerTopBar(
                    title: widget.title,
                    pageLabel: _totalPages == 0
                        ? ''
                        : '$_currentPage / $_totalPages',
                    onCloseTap: () => Get.back<void>(),
                  ),
                  SizedBox(height: 21.h),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48.r),
                      child: Container(
                        color: AppColors.white,
                        child: SfPdfViewer.network(
                          widget.pdfUrl,
                          key: ValueKey<String>(widget.pdfUrl),
                          controller: _pdfController,
                          pageLayoutMode: PdfPageLayoutMode.single,
                          scrollDirection: PdfScrollDirection.vertical,
                          canShowScrollHead: false,
                          canShowScrollStatus: false,
                          canShowPaginationDialog: false,
                          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                            setState(() {
                              _totalPages = details.document.pages.count;
                            });
                          },
                          onPageChanged: (PdfPageChangedDetails details) {
                            setState(() {
                              _currentPage = details.newPageNumber;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _PdfBottomNavigation(
                    canGoPrevious: _canGoPrevious,
                    canGoNext: _canGoNext,
                    onPreviousTap: () {
                      if (_canGoPrevious) _pdfController.previousPage();
                    },
                    onNextTap: () {
                      if (_canGoNext) _pdfController.nextPage();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfDarkBackground extends StatelessWidget {
  const _PdfDarkBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF0C1A16),
                  Color(0xFF182A25),
                  Color(0xFF07110E),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -65.h,
          right: -75.w,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
            child: Container(
              width: 240.r,
              height: 240.r,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF0).withValues(alpha: 0.42),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PdfViewerTopBar extends StatelessWidget {
  final String title;
  final String pageLabel;
  final VoidCallback onCloseTap;

  const _PdfViewerTopBar({
    required this.title,
    required this.pageLabel,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 80.h),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: onCloseTap,
            child: Container(
              width: 56.r,
              height: 56.r,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 26.r,
                color: const Color(0xFF2B3034),
              ),
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1.16,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2A2F33),
              ),
            ),
          ),
          if (pageLabel.isNotEmpty) ...<Widget>[
            SizedBox(width: 12.w),
            Text(
              pageLabel,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PdfBottomNavigation extends StatelessWidget {
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPreviousTap;
  final VoidCallback onNextTap;

  const _PdfBottomNavigation({
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPreviousTap,
    required this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _PdfNavButton(
            label: 'gen_previous_1'.tr,
            icon: Icons.arrow_back_rounded,
            isEnabled: canGoPrevious,
            onTap: onPreviousTap,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: _PdfNavButton(
            label: 'gen_next_1'.tr,
            icon: Icons.arrow_forward_rounded,
            isEnabled: canGoNext,
            onTap: onNextTap,
            isTrailing: true,
          ),
        ),
      ],
    );
  }
}

class _PdfNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isEnabled;
  final bool isTrailing;
  final VoidCallback onTap;

  const _PdfNavButton({
    required this.label,
    required this.icon,
    required this.isEnabled,
    required this.onTap,
    this.isTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.45,
        child: Container(
          height: 58.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!isTrailing) Icon(icon, color: AppColors.primaryGreen),
              if (!isTrailing) SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                ),
              ),
              if (isTrailing) SizedBox(width: 8.w),
              if (isTrailing) Icon(icon, color: AppColors.primaryGreen),
            ],
          ),
        ),
      ),
    );
  }
}
