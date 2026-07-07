import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_colors.dart';
import '../themes/app_font.dart';

class OtpResendButton extends StatelessWidget {
  const OtpResendButton({
    required this.label,
    required this.isLoading,
    required this.remainingSeconds,
    required this.remainingLabel,
    required this.onTap,
    this.fontSize,
    super.key,
  });

  final String label;
  final bool isLoading;
  final int remainingSeconds;
  final String remainingLabel;
  final VoidCallback onTap;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final bool isCoolingDown = remainingSeconds > 0;
    final bool isDisabled = isLoading || isCoolingDown;

    return TextButton(
      onPressed: isDisabled ? null : onTap,
      child: isLoading
          ? SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGreen,
              ),
            )
          : Text(
              isCoolingDown ? '$label $remainingLabel' : label,
              style: TextStyle(
                color: isCoolingDown
                    ? AppColors.legacyColorFF8A8E92
                    : AppColors.primaryGreen,
                fontSize: (fontSize ?? AppFont.font15).sp,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}
