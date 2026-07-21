import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';

class ReportReasonChip
    extends StatelessWidget {
  const ReportReasonChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(100.r),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 160),
          constraints: BoxConstraints(
            minHeight: 42.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 10.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.chatDateChipBg,
            borderRadius:
            BorderRadius.circular(100.r),
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font13.sp,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: isSelected
                  ? AppColors.white
                  : AppColors.bodyText,
            ),
          ),
        ),
      ),
    );
  }
}