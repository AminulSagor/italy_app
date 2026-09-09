import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_template_model.dart';

class CvTemplateThumbnail extends StatelessWidget {
  const CvTemplateThumbnail({
    super.key,
    required this.template,
    this.borderRadius,
    this.fit = BoxFit.contain,
  });

  final CvTemplateModel template;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12.r),
      child: ColoredBox(
        color: const Color(0xFFF0F2F1),
        child: template.hasPreviewImage
            ? Image.network(
                template.previewImageUrl!,
                fit: fit,
                filterQuality: FilterQuality.medium,
                cacheWidth: 900,
                frameBuilder: (
                  BuildContext context,
                  Widget child,
                  int? frame,
                  bool wasSynchronouslyLoaded,
                ) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return const _ThumbnailSkeleton();
                },
                errorBuilder: (_, __, ___) => const _PreviewFallback(),
              )
            : const _PreviewFallback(),
      ),
    );
  }
}

class _ThumbnailSkeleton extends StatelessWidget {
  const _ThumbnailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE3E7E5),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 44.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD4DAD7),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 70.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DDDB),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 5.h),
            Container(
              width: 58.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DDDB),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.description_outlined,
        size: 36.w,
        color: AppColors.homeSecondaryText,
      ),
    );
  }
}
