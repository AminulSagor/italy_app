import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../../../core/services/screen_protection_service.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';

enum AppPdfSourceType { network, asset }

class AppPdfViewer extends StatefulWidget {
  const AppPdfViewer({
    super.key,
    required this.title,
    required this.source,
    this.sourceType = AppPdfSourceType.network,
    this.sourceId = 'app_pdf_viewer',
    this.initialPageCount = 0,
    this.onDocumentLoaded,
    this.onPageChanged,
  });

  final String title;
  final String source;
  final AppPdfSourceType sourceType;
  final String sourceId;
  final int initialPageCount;
  final ValueChanged<int>? onDocumentLoaded;
  final ValueChanged<int>? onPageChanged;

  @override
  State<AppPdfViewer> createState() => _AppPdfViewerState();
}

class _AppPdfViewerState extends State<AppPdfViewer> {
  PdfViewerController _pdfController = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 0;
  int _reloadVersion = 0;

  bool _isLoading = true;
  bool _hasError = false;
  bool _didNotifyDocumentLoaded = false;

  int get _viewerPageCount {
    if (!_pdfController.isReady) {
      return 0;
    }

    return _pdfController.pageCount;
  }

  bool get _canGoPrevious =>
      !_isLoading && !_hasError && _pdfController.isReady && _currentPage > 1;

  bool get _canGoNext {
    if (_isLoading ||
        _hasError ||
        !_pdfController.isReady ||
        _totalPages <= 0 ||
        _currentPage >= _totalPages) {
      return false;
    }

    final int availablePages = _viewerPageCount;

    if (availablePages <= 0) {
      return false;
    }

    return _currentPage < availablePages;
  }

  String get _pageLabel {
    if (_totalPages <= 0) {
      return '—';
    }

    return '$_currentPage / $_totalPages';
  }

  @override
  void initState() {
    super.initState();

    _totalPages = widget.initialPageCount > 0 ? widget.initialPageCount : 0;

    if (Get.isRegistered<ScreenProtectionService>()) {
      unawaited(Get.find<ScreenProtectionService>().enable());
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<ScreenProtectionService>()) {
      unawaited(Get.find<ScreenProtectionService>().disable());
    }

    super.dispose();
  }

  void _goBack() {
    HapticFeedback.selectionClick();
    Get.back<void>();
  }

  void _goToPreviousPage() {
    if (!_canGoPrevious) {
      return;
    }

    final int targetPage = _currentPage - 1;

    HapticFeedback.selectionClick();

    unawaited(
      _pdfController.goToPage(
        pageNumber: targetPage,
        anchor: PdfPageAnchor.top,
      ),
    );
  }

  void _goToNextPage() {
    if (!_canGoNext) {
      return;
    }

    final int targetPage = _currentPage + 1;

    HapticFeedback.selectionClick();

    unawaited(
      _pdfController.goToPage(
        pageNumber: targetPage,
        anchor: PdfPageAnchor.top,
      ),
    );
  }

  void _retry() {
    HapticFeedback.selectionClick();

    setState(() {

      _pdfController = PdfViewerController();

      _currentPage = 1;

      _totalPages = widget.initialPageCount > 0 ? widget.initialPageCount : 0;

      _isLoading = true;
      _hasError = false;
      _didNotifyDocumentLoaded = false;

      _reloadVersion++;
    });
  }

  void _onViewerReady(PdfDocument document, PdfViewerController controller) {
    if (!mounted) {
      return;
    }

    final int viewerPageCount = controller.pageCount;


    final int totalPages = viewerPageCount > _totalPages
        ? viewerPageCount
        : _totalPages;

    final int pageNumber = controller.pageNumber ?? 1;

    setState(() {
      _totalPages = totalPages;

      _currentPage = pageNumber > 0 ? pageNumber : 1;

      _isLoading = false;
      _hasError = false;
    });

    _notifyDocumentLoaded(totalPages);
  }

  void _onDocumentLoadFinished(PdfDocumentRef documentRef, bool loadSucceeded) {
    if (!mounted) {
      return;
    }

    if (!loadSucceeded) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      return;
    }

    if (!_pdfController.isReady) {
      return;
    }

    final int viewerPageCount = _pdfController.pageCount;

    final int totalPages = viewerPageCount > _totalPages
        ? viewerPageCount
        : _totalPages;

    if (totalPages != _totalPages) {
      setState(() {
        _totalPages = totalPages;
      });
    }

    _notifyDocumentLoaded(totalPages);
  }

  void _notifyDocumentLoaded(int totalPages) {
    if (_didNotifyDocumentLoaded || totalPages <= 0) {
      return;
    }

    _didNotifyDocumentLoaded = true;

    widget.onDocumentLoaded?.call(totalPages);
  }

  void _onPageChanged(int? pageNumber) {
    if (!mounted || pageNumber == null || pageNumber <= 0) {
      return;
    }

    /*
     * Progressive loading can expose additional
     * pages after the viewer initially becomes
     * ready.
     */
    final int viewerPageCount = _viewerPageCount;

    final int totalPages = viewerPageCount > _totalPages
        ? viewerPageCount
        : _totalPages;

    if (_currentPage != pageNumber || _totalPages != totalPages) {
      setState(() {
        _currentPage = pageNumber;
        _totalPages = totalPages;
      });
    }

    widget.onPageChanged?.call(pageNumber);
  }

  void _scheduleViewerError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasError) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    });
  }

  PdfViewerParams _buildViewerParams() {
    return PdfViewerParams(

      margin: 0,
      backgroundColor: AppColors.white,
      pageDropShadow: null,


      loadingBannerBuilder:
          (BuildContext context, int bytesDownloaded, int? totalBytes) {
            return const SizedBox.shrink();
          },


      errorBannerBuilder:
          (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
            PdfDocumentRef documentRef,
          ) {
            _scheduleViewerError();

            return const SizedBox.shrink();
          },

      onViewerReady: _onViewerReady,

      onDocumentLoadFinished: _onDocumentLoadFinished,

      onPageChanged: _onPageChanged,

      pageAnchor: PdfPageAnchor.top,
    );
  }

  Widget _buildPdfViewer() {
    final Key viewerKey = ValueKey<String>(
      '${widget.source}-'
      '${widget.sourceType.name}-'
      '$_reloadVersion',
    );

    final PdfViewerParams params = _buildViewerParams();

    if (widget.sourceType == AppPdfSourceType.asset) {
      return PdfViewer.asset(
        widget.source,
        key: viewerKey,
        controller: _pdfController,
        useProgressiveLoading: true,
        params: params,
      );
    }

    final Uri? uri = Uri.tryParse(widget.source);

    if (uri == null || !uri.hasScheme) {
      _scheduleViewerError();

      return const SizedBox.shrink();
    }

    return PdfViewer.uri(
      uri,
      key: viewerKey,
      controller: _pdfController,



      preferRangeAccess: true,

      params: params,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.pdf,
      sourceId: widget.sourceId,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5F3),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _PdfReaderHeader(
                title: widget.title,
                pageLabel: _pageLabel,
                onCloseTap: _goBack,
              ),

              Expanded(
                child: ColoredBox(
                  color: AppColors.white,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _buildPdfViewer(),

                      if (_isLoading) const _PdfLoadingState(),

                      if (_hasError) _PdfErrorState(onRetry: _retry),
                    ],
                  ),
                ),
              ),

              _PdfReaderNavigation(
                currentPage: _currentPage,
                totalPages: _totalPages,
                canGoPrevious: _canGoPrevious,
                canGoNext: _canGoNext,
                onPreviousTap: _goToPreviousPage,
                onNextTap: _goToNextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfReaderHeader extends StatelessWidget {
  const _PdfReaderHeader({
    required this.title,
    required this.pageLabel,
    required this.onCloseTap,
  });

  final String title;
  final String pageLabel;
  final VoidCallback onCloseTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE3E9E6))),
      ),
      child: Row(
        children: <Widget>[
          _PdfRoundButton(
            icon: Icons.close_rounded,
            tooltip: 'Close',
            isEnabled: true,
            onTap: onCloseTap,
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF252D29),
              ),
            ),
          ),

          SizedBox(width: 10.w),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Container(
              key: ValueKey<String>(pageLabel),
              constraints: BoxConstraints(minWidth: 58.w),
              height: 34.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4ED),
                borderRadius: BorderRadius.circular(17.r),
              ),
              child: Text(
                pageLabel,
                maxLines: 1,
                style: TextStyle(
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfReaderNavigation extends StatelessWidget {
  const _PdfReaderNavigation({
    required this.currentPage,
    required this.totalPages,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPreviousTap,
    required this.onNextTap,
  });

  final int currentPage;
  final int totalPages;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPreviousTap;
  final VoidCallback onNextTap;

  @override
  Widget build(BuildContext context) {
    final double progress = totalPages > 0
        ? (currentPage / totalPages).clamp(0.0, 1.0)
        : 0;

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 9.h, 14.w, 10.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFE3E9E6))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3.h,
              backgroundColor: const Color(0xFFE5EAE7),
              color: AppColors.primaryGreen,
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            children: <Widget>[
              _PdfRoundButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'gen_previous_1'.tr,
                isEnabled: canGoPrevious,
                onTap: onPreviousTap,
              ),

              Expanded(
                child: Text(
                  totalPages > 0 ? '$currentPage / $totalPages' : '—',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4E5954),
                  ),
                ),
              ),

              _PdfRoundButton(
                icon: Icons.arrow_forward_rounded,
                tooltip: 'gen_next_1'.tr,
                isEnabled: canGoNext,
                onTap: onNextTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PdfRoundButton extends StatelessWidget {
  const _PdfRoundButton({
    required this.icon,
    required this.tooltip,
    required this.isEnabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isEnabled ? const Color(0xFFEAF4ED) : const Color(0xFFF0F2F1),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44.r,
            height: 44.r,
            child: Icon(
              icon,
              size: 23.r,
              color: isEnabled
                  ? AppColors.primaryGreen
                  : const Color(0xFFA8AFAB),
            ),
          ),
        ),
      ),
    );
  }
}

class _PdfLoadingState extends StatelessWidget {
  const _PdfLoadingState();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Center(
        child: Container(
          width: 52.r,
          height: 52.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F5F2),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 25.r,
            height: 25.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2.8,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}

class _PdfErrorState extends StatelessWidget {
  const _PdfErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 54.r,
                height: 54.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F5F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 27.r,
                  color: AppColors.primaryGreen,
                ),
              ),

              SizedBox(height: 14.h),

              Text(
                'Unable to open PDF',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF313A36),
                ),
              ),

              SizedBox(height: 12.h),

              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('retry'.tr),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  minimumSize: Size(120.w, 44.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
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
