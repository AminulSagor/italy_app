import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class CvZoomablePreview extends StatefulWidget {
  const CvZoomablePreview({
    required this.imageUrl,
    required this.transformationController,
    this.onInteractionEnd,
    this.backgroundColor = Colors.white,
    super.key,
  });

  final String imageUrl;

  final TransformationController
  transformationController;

  final VoidCallback? onInteractionEnd;

  final Color backgroundColor;

  @override
  State<CvZoomablePreview> createState() =>
      _CvZoomablePreviewState();
}

class _CvZoomablePreviewState
    extends State<CvZoomablePreview> {
  Offset? _doubleTapPosition;

  void _handleDoubleTapDown(
      TapDownDetails details,
      ) {
    _doubleTapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    final Matrix4 currentMatrix =
        widget.transformationController.value;

    final double currentScale =
    currentMatrix.getMaxScaleOnAxis();

    if (currentScale > 1.05) {
      widget.transformationController.value =
          Matrix4.identity();
    } else {
      const double targetScale = 2;

      final Offset position =
          _doubleTapPosition ?? Offset.zero;

      final Matrix4 matrix = Matrix4.identity()
        ..translate(
          -position.dx * (targetScale - 1),
          -position.dy * (targetScale - 1),
        )
        ..scale(
          targetScale,
          targetScale,
          1,
        );

      widget.transformationController.value =
          matrix;
    }

    widget.onInteractionEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController:
          widget.transformationController,
          minScale: 1,
          maxScale: 5,
          panEnabled: true,
          scaleEnabled: true,
          boundaryMargin:
          const EdgeInsets.all(80),
          onInteractionEnd: (_) {
            widget.onInteractionEnd?.call();
          },
          child: SizedBox.expand(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              loadingBuilder: (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                  ) {
                if (loadingProgress == null) {
                  return child;
                }

                final int? expectedBytes =
                    loadingProgress
                        .expectedTotalBytes;

                final double? progress =
                expectedBytes == null
                    ? null
                    : loadingProgress
                    .cumulativeBytesLoaded /
                    expectedBytes;

                return Center(
                  child: CircularProgressIndicator(
                    value: progress,
                  ),
                );
              },
              errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                  ) {
                return  Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.broken_image_outlined,
                        size: 52,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'cv_preview_load_failed'.tr,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}