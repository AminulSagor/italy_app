import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvDocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPreviewTap;
  final VoidCallback onDownloadTap;
  final VoidCallback onEditTap;

  const CvDocumentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPreviewTap,
    required this.onDownloadTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46.w,
            height: 46.w,
            decoration: const BoxDecoration(
              color: AppColors.legacyColorFFE0E1E1,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_rounded,
              color: AppColors.white,
              size: AppFont.font25.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font11.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.homeSecondaryText,
                    fontSize: AppFont.font8.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          _ActionCircle(icon: Icons.remove_red_eye_outlined, onTap: onPreviewTap),
          SizedBox(width: 6.w),
          _ActionCircle(icon: Icons.download_rounded, onTap: onDownloadTap),
          SizedBox(width: 6.w),
          _ActionCircle(icon: Icons.edit_rounded, onTap: onEditTap),
        ],
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCircle({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.legacyColorFFF1F2F2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: Icon(
            icon,
            color: AppColors.homeSecondaryText,
            size: AppFont.font13.sp,
          ),
        ),
      ),
    );
  }
}