import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../courses/services/courses_api_service.dart';
import '../../controllers/practice_hub_controller.dart';
import '../../models/practice_hub_pdf_model.dart';
import '../../services/practice_hub_api_service.dart';

class PracticeHubPdfViewer extends StatefulWidget {
  const PracticeHubPdfViewer({super.key});

  @override
  State<PracticeHubPdfViewer> createState() => _PracticeHubPdfViewerState();
}

class _PracticeHubPdfViewerState extends State<PracticeHubPdfViewer> {
  late final PdfViewerController _pdfController;

  PracticeHubController get controller {
    if (Get.isRegistered<PracticeHubController>()) {
      return Get.find<PracticeHubController>();
    }

    return Get.put<PracticeHubController>(
      PracticeHubController(
        coursesApiService: Get.find<CoursesApiService>(),
        practiceHubApiService: Get.find<PracticeHubApiService>(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();

    final Object? arguments = Get.arguments;
    if (arguments is PracticeHubPdfDocumentModel) {
      controller.selectedPracticePdf.value = arguments;
      controller.currentSurvivalPdfPage.value = 1;
      controller.currentSurvivalPdfTotalPages.value = 1;
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _goPrevious() {
    if (controller.canGoPreviousSurvivalPdfPage) {
      _pdfController.previousPage();
    }
  }

  void _goNext() {
    if (controller.canGoNextSurvivalPdfPage) {
      _pdfController.nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? arguments = Get.arguments;
    final PracticeHubPdfDocumentModel? document =
        arguments is PracticeHubPdfDocumentModel
        ? arguments
        : controller.currentPracticePdf;

    if (document == null || document.source.trim().isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF10201B),
        body: SafeArea(
          child: Center(
            child: Text(
              'pdf_resource_is_unavailable'.tr,
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      );
    }

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
                  _PdfViewerTopBar(title: document.title),

                  SizedBox(height: 21.h),

                  Expanded(
                    child: _PdfContentCard(
                      document: document,
                      pdfController: _pdfController,
                      onDocumentLoaded: controller.onSurvivalPdfDocumentLoaded,
                      onPageChanged: controller.onSurvivalPdfPageChanged,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  _PdfBottomNavigation(
                    onPreviousTap: _goPrevious,
                    onNextTap: _goNext,
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
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  const Color(0xFF0C1A16),
                  const Color(0xFF182A25),
                  const Color(0xFF07110E),
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
        Positioned(
          bottom: -80.h,
          left: -70.w,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 46, sigmaY: 46),
            child: Container(
              width: 210.r,
              height: 210.r,
              decoration: BoxDecoration(
                color: const Color(0xFF20A64B).withValues(alpha: 0.40),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PdfViewerTopBar extends GetView<PracticeHubController> {
  final String title;

  const _PdfViewerTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: controller.onPdfViewerCloseTap,
            child: Container(
              width: 64.r,
              height: 64.r,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 28.r,
                color: const Color(0xFF2B3034),
              ),
            ),
          ),
          SizedBox(width: 26.w),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1.16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
                color: const Color(0xFF2A2F33),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfContentCard extends StatelessWidget {
  const _PdfContentCard({
    required this.document,
    required this.pdfController,
    required this.onDocumentLoaded,
    required this.onPageChanged,
  });

  final PracticeHubPdfDocumentModel document;
  final PdfViewerController pdfController;
  final ValueChanged<int> onDocumentLoaded;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final Key viewerKey = ValueKey<String>(document.source);
    final void Function(PdfDocumentLoadedDetails) handleLoaded =
        (PdfDocumentLoadedDetails details) {
          onDocumentLoaded(details.document.pages.count);
        };
    final void Function(PdfPageChangedDetails) handlePageChanged =
        (PdfPageChangedDetails details) {
          onPageChanged(details.newPageNumber);
        };

    final Widget viewer = document.sourceType == PracticeHubPdfSourceType.network
        ? SfPdfViewer.network(
            document.source,
            key: viewerKey,
            controller: pdfController,
            pageLayoutMode: PdfPageLayoutMode.single,
            scrollDirection: PdfScrollDirection.vertical,
            canShowScrollHead: false,
            canShowScrollStatus: false,
            canShowPaginationDialog: false,
            onDocumentLoaded: handleLoaded,
            onPageChanged: handlePageChanged,
          )
        : SfPdfViewer.asset(
            document.source,
            key: viewerKey,
            controller: pdfController,
            pageLayoutMode: PdfPageLayoutMode.single,
            scrollDirection: PdfScrollDirection.vertical,
            canShowScrollHead: false,
            canShowScrollStatus: false,
            canShowPaginationDialog: false,
            onDocumentLoaded: handleLoaded,
            onPageChanged: handlePageChanged,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(48.r),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(48.r),
        ),
        child: viewer,
      ),
    );
  }
}

class _PdfBottomNavigation extends GetView<PracticeHubController> {
  final VoidCallback onPreviousTap;
  final VoidCallback onNextTap;

  const _PdfBottomNavigation({
    required this.onPreviousTap,
    required this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Obx(() {
        return Row(
          children: <Widget>[
            _PdfSideNavButton(
              icon: Icons.chevron_left_rounded,
              label: 'gen_previous'.tr,
              enabled: controller.canGoPreviousSurvivalPdfPage,
              onTap: onPreviousTap,
            ),

            const Spacer(),

            Container(
              width: 130.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: const Color(0xFF303234),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.article_rounded,
                    size: 22.r,
                    color: const Color(0xFF75FF36),
                  ),
                  SizedBox(width: 9.w),
                  Text(
                    'controller_currentsurvivalpdfpage_value_controller_currentsurvivalpdftotalpages_value'.trParams(<String, String>{'value': controller.currentSurvivalPdfPage.value.toString(), 'value': controller.currentSurvivalPdfTotalPages.value.toString()}),
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            _PdfSideNavButton(
              icon: Icons.chevron_right_rounded,
              label: 'gen_next'.tr,
              enabled: controller.canGoNextSurvivalPdfPage,
              onTap: onNextTap,
              reversed: true,
            ),
          ],
        );
      }),
    );
  }
}

class _PdfSideNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool reversed;

  const _PdfSideNavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.reversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = enabled
        ? AppColors.primaryGreen
        : AppColors.primaryGreen.withValues(alpha: 0.35);

    final List<Widget> children = <Widget>[
      Icon(icon, size: 25.r, color: color),
      SizedBox(height: 4.h),
      Text(
        label,
        style: TextStyle(
          fontSize: AppFont.font11.sp,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
          color: color,
        ),
      ),
    ];

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 74.w,
        height: 58.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: reversed ? children : children,
        ),
      ),
    );
  }
}
