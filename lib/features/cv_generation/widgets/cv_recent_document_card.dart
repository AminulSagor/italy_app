import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_template_model.dart';

class CvRecentDocumentCard extends StatelessWidget {
  const CvRecentDocumentCard({
    super.key,
    required this.document,
    required this.isOpening,
    required this.isViewing,
    required this.onEdit,
    required this.onView,
  });

  final CvRecentDocumentModel document;
  final bool isOpening;
  final bool isViewing;
  final VoidCallback onEdit;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final bool freeEdit = document.hasConsumedCreationAccess;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE7EAE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: freeEdit
                      ? const Color(0xFFE7F5E4)
                      : const Color(0xFFFFF3DB),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  freeEdit ? Icons.edit_document : Icons.drafts_outlined,
                  color: freeEdit
                      ? AppColors.primaryGreen
                      : const Color(0xFF9A6500),
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      document.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.homePrimaryText,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _updatedLabel(document.updatedAt),
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.homeSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: freeEdit
                        ? const Color(0xFFE5F5E8)
                        : const Color(0xFFFFF2D5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    freeEdit
                        ? 'cvb_status_free_to_edit'.tr
                        : 'cvb_status_draft'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w900,
                      color: freeEdit
                          ? const Color(0xFF176B38)
                          : const Color(0xFF8B5A00),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: <Widget>[
              if (document.hasPdf) ...<Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isViewing ? null : onView,
                    icon: isViewing
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
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
                    ),
                  ),
                ),
                SizedBox(width: 9.w),
              ],
              Expanded(
                flex: document.hasPdf ? 1 : 2,
                child: FilledButton.icon(
                  onPressed: isOpening ? null : onEdit,
                  icon: isOpening
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          freeEdit
                              ? Icons.edit_rounded
                              : Icons.play_arrow_rounded,
                        ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      freeEdit ? 'cvb_edit_free'.tr : 'cvb_continue'.tr,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
