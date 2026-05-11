import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class ReportReasonChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ReportReasonChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: kReportReasonChipHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.chatDateChipBg,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primaryBtnShadow.withValues(alpha: 0.22),
                    blurRadius: 18.r,
                    offset: Offset(0, 10.h),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppFont.font18.sp,
            fontWeight: FontWeight.w900,
            color: isSelected ? AppColors.white : AppColors.bodyText,
          ),
        ),
      ),
    );
  }
}
