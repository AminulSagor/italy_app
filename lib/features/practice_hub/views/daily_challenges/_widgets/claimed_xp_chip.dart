import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';

class ClaimedXpChip extends StatelessWidget {
  const ClaimedXpChip({super.key, required this.rewardXp});

  final int rewardXp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        'CLAIMED +$rewardXp XP',
        style: TextStyle(
          fontSize: AppFont.font11.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}
