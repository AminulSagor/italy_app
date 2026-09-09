import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_library_model.dart';

class CvLibraryCard extends StatelessWidget {
  const CvLibraryCard({
    super.key,
    required this.item,
    required this.isOpening,
    required this.isViewing,
    required this.onEdit,
    required this.onView,
  });

  final CvLibraryItemModel item;
  final bool isOpening;
  final bool isViewing;
  final VoidCallback onEdit;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final _LibraryStatus status = _statusFor(item);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE1E7E3)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 78.w,
            child: AspectRatio(
              aspectRatio: 210 / 297,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: ColoredBox(
                  color: const Color(0xFFF0F3F1),
                  child: item.previewImageUrl?.trim().isNotEmpty == true
                      ? Image.network(
                          item.previewImageUrl!,
                          fit: BoxFit.contain,
                          cacheWidth: 420,
                          filterQuality: FilterQuality.medium,
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
                                return const _PreviewSkeleton();
                              },
                          errorBuilder: (_, __, ___) =>
                              const _PreviewFallback(),
                        )
                      : const _PreviewFallback(),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.templateName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.homePrimaryText,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: AppColors.homeSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: status.background,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          status.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w900,
                            color: status.foreground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.h),
                Text(
                  status.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.3.sp,
                    height: 1.35,
                    color: status.foreground,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _updatedLabel(item.updatedAt),
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: AppColors.homeSecondaryText,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: <Widget>[
                    if (item.hasPdf) ...<Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isViewing ? null : onView,
                          icon: isViewing
                              ? SizedBox(
                                  width: 15.w,
                                  height: 15.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.visibility_outlined),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('cvb_view'.tr),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.homePrimaryText,
                            side: const BorderSide(color: Color(0xFFD8DFDB)),
                            padding: EdgeInsets.symmetric(vertical: 7.h),
                            minimumSize: Size(0, 36.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      flex: item.hasPdf ? 1 : 2,
                      child: FilledButton.icon(
                        onPressed: item.templateAvailable && !isOpening
                            ? onEdit
                            : null,
                        icon: isOpening
                            ? SizedBox(
                                width: 15.w,
                                height: 15.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                item.hasPdf
                                    ? Icons.edit_outlined
                                    : Icons.play_arrow_rounded,
                              ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.hasPdf
                                ? 'cvb_edit_free'.tr
                                : 'cvb_continue'.tr,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFD9DEDB),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _LibraryStatus _statusFor(CvLibraryItemModel item) {
    if (!item.templateAvailable) {
      return _LibraryStatus(
        label: 'cvb_status_unavailable'.tr,
        message: 'cvb_status_unavailable_message'.tr,
        background: Color(0xFFF1F2F2),
        foreground: Color(0xFF626A66),
      );
    }

    if (!item.hasPdf) {
      return _LibraryStatus(
        label: 'cvb_status_draft'.tr,
        message: 'cvb_status_draft_message'.tr,
        background: Color(0xFFFFF1D6),
        foreground: Color(0xFF8A5A00),
      );
    }

    if (item.hasDraftChanges) {
      return _LibraryStatus(
        label: 'cvb_status_changes'.tr,
        message: 'cvb_status_changes_message'.tr,
        background: Color(0xFFFFF1D6),
        foreground: Color(0xFF8A5A00),
      );
    }

    return _LibraryStatus(
      label: 'cvb_status_up_to_date'.tr,
      message: 'cvb_status_up_to_date_message'.tr,
      background: Color(0xFFE6F4E8),
      foreground: Color(0xFF176B38),
    );
  }

  String _updatedLabel(DateTime? value) {
    if (value == null) return 'cvb_saved_recently'.tr;
    final Duration age = DateTime.now().difference(value.toLocal());
    if (age.inMinutes < 1) return 'cvb_saved_just_now'.tr;
    if (age.inMinutes < 60) {
      return 'cvb_saved_minutes'.trParams(<String, String>{
        'count': '${age.inMinutes}',
      });
    }
    if (age.inHours < 24) {
      return 'cvb_saved_hours'.trParams(<String, String>{
        'count': '${age.inHours}',
      });
    }
    if (age.inDays < 7) {
      return 'cvb_saved_days'.trParams(<String, String>{
        'count': '${age.inDays}',
      });
    }
    final DateTime local = value.toLocal();
    return 'cvb_saved_date'.trParams(<String, String>{
      'date': '${local.day}/${local.month}/${local.year}',
    });
  }
}

class _LibraryStatus {
  const _LibraryStatus({
    required this.label,
    required this.message,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String message;
  final Color background;
  final Color foreground;
}

class _PreviewSkeleton extends StatelessWidget {
  const _PreviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: Color(0xFFE5E9E7));
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.description_outlined,
        color: AppColors.homeSecondaryText,
        size: 30.w,
      ),
    );
  }
}
