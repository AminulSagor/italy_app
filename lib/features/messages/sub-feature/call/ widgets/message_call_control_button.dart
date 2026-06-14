import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';

class MessageCallControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDanger;

  const MessageCallControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDanger
        ? AppColors.blockDangerRed
        : isActive
        ? AppColors.primaryGreen
        : AppColors.white;

    final Color iconColor = isDanger || isActive
        ? AppColors.white
        : AppColors.homePrimaryText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58.w,
        height: 58.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              offset: Offset(0, 8),
              blurRadius: 18,
            ),
          ],
        ),
        child: Icon(icon, size: 26.w, color: iconColor),
      ),
    );
  }
}