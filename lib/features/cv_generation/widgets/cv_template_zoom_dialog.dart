import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_template_model.dart';
import '../services/resume_studio_api_service.dart';

class CvTemplateZoomDialog extends StatefulWidget {
  const CvTemplateZoomDialog({super.key, required this.template});

  final CvTemplateModel template;

  static Future<void> show(
    BuildContext context, {
    required CvTemplateModel template,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (_) => CvTemplateZoomDialog(template: template),
    );
  }

  @override
  State<CvTemplateZoomDialog> createState() => _CvTemplateZoomDialogState();
}

class _CvTemplateZoomDialogState extends State<CvTemplateZoomDialog> {
  late final Future<CvTemplatePreviewModel> _previewFuture;

  @override
  void initState() {
    super.initState();
    _previewFuture = Get.find<ResumeStudioApiService>().fetchTemplatePreview(
      widget.template.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF171A18),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 12.w, 8.h),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.template.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'cvb_zoom_help'.tr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 10.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<CvTemplatePreviewModel>(
                future: _previewFuture,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<CvTemplatePreviewModel> snapshot,
                    ) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const _ZoomLoading();
                      }

                      final CvTemplatePreviewModel? preview = snapshot.data;
                      if (snapshot.hasError || preview == null) {
                        return _ImageFallback(template: widget.template);
                      }

                      if (preview.hasPreviewPdf) {
                        return _PdfTemplatePreview(
                          pdfUrl: preview.previewPdfUrl!,
                          fallbackTemplate: widget.template,
                          fallbackImageUrl: preview.previewImageUrl,
                        );
                      }

                      return _ImageFallback(
                        template: widget.template,
                        imageUrl: preview.previewImageUrl,
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfTemplatePreview extends StatefulWidget {
  const _PdfTemplatePreview({
    required this.pdfUrl,
    required this.fallbackTemplate,
    required this.fallbackImageUrl,
  });

  final String pdfUrl;
  final CvTemplateModel fallbackTemplate;
  final String? fallbackImageUrl;

  @override
  State<_PdfTemplatePreview> createState() => _PdfTemplatePreviewState();
}

class _PdfTemplatePreviewState extends State<_PdfTemplatePreview> {
  bool _loadFailed = false;

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return _ImageFallback(
        template: widget.fallbackTemplate,
        imageUrl: widget.fallbackImageUrl,
      );
    }

    return ColoredBox(
      color: const Color(0xFF2A2D2B),
      child: SfPdfViewer.network(
        widget.pdfUrl,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        scrollDirection: PdfScrollDirection.vertical,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPaginationDialog: false,
        onDocumentLoadFailed: (_) {
          if (!mounted) return;
          setState(() => _loadFailed = true);
        },
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.template, this.imageUrl});

  final CvTemplateModel template;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final String? resolvedUrl = imageUrl?.trim().isNotEmpty == true
        ? imageUrl
        : template.previewImageUrl;

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      boundaryMargin: EdgeInsets.all(50.w),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: AspectRatio(
            aspectRatio: 210 / 297,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: ColoredBox(
                color: Colors.white,
                child: resolvedUrl?.trim().isNotEmpty == true
                    ? Image.network(
                        resolvedUrl!,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        frameBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              int? frame,
                              bool wasSynchronouslyLoaded,
                            ) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }
                              return const _ZoomLoading();
                            },
                        errorBuilder: (_, __, ___) => const _ZoomError(),
                      )
                    : const _ZoomError(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoomLoading extends StatelessWidget {
  const _ZoomLoading();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF1F3F2),
      child: Center(
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}

class _ZoomError extends StatelessWidget {
  const _ZoomError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.description_outlined,
            size: 48.w,
            color: AppColors.homeSecondaryText,
          ),
          SizedBox(height: 8.h),
          Text(
            'cvb_preview_unavailable'.tr,
            style: TextStyle(
              color: AppColors.homeSecondaryText,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
