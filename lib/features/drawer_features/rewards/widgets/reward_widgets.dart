import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/reward_models.dart';

class RewardTopBar extends StatelessWidget {
  const RewardTopBar({super.key, required this.title});

  final String title;

  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.045),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_rounded, size: 25.r, color: green),
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: green,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class RewardPrimaryButton extends StatelessWidget {
  const RewardPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.suffixIcon,
    this.height = 62,
    this.color = const Color(0xFF267A05),
    this.shadowColor = const Color(0xFF155200),
    this.textColor = Colors.white,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onTap;
  final IconData? suffixIcon;
  final double height;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null && !isLoading;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: isEnabled || isLoading ? 1 : 0.55,
        duration: const Duration(milliseconds: 180),
        child: Container(
          height: height.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: shadowColor,
                blurRadius: 0,
                offset: Offset(0, 7.h),
              ),
            ],
          ),
          child: isLoading
              ? SizedBox(
                  width: 23.r,
                  height: 23.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.15,
                      ),
                    ),
                    if (suffixIcon != null) ...<Widget>[
                      SizedBox(width: 10.w),
                      Icon(suffixIcon, size: 22.r, color: textColor),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class RewardImage extends StatelessWidget {
  const RewardImage({
    super.key,
    required this.rewardType,
    required this.imageUrl,
    this.size = 120,
    this.fit = BoxFit.contain,
  });

  final RewardType rewardType;
  final String? imageUrl;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final String url = imageUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      return Image.network(
        url,
        width: size.r,
        height: size.r,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Icon(
      RewardVisuals.icon(rewardType),
      size: (size * 0.62).r,
      color: RewardVisuals.accent(rewardType),
    );
  }
}

class RewardStateMessage extends StatelessWidget {
  const RewardStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 58.r,
            height: 58.r,
            decoration: const BoxDecoration(
              color: Color(0xFFE4FFD7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 29.r, color: const Color(0xFF267A05)),
          ),
          SizedBox(height: 18.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3032),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
          if (buttonText != null && onTap != null) ...<Widget>[
            SizedBox(height: 20.h),
            SizedBox(
              width: 150.w,
              child: RewardPrimaryButton(
                text: buttonText!,
                height: 48,
                onTap: onTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RewardVisuals {
  const RewardVisuals._();

  static IconData icon(RewardType type) {
    switch (type) {
      case RewardType.xp:
        return Icons.flash_on_rounded;
      case RewardType.streakFreeze:
        return Icons.ac_unit_rounded;
      case RewardType.cvCredits:
        return Icons.description_outlined;
      case RewardType.aiPackage:
        return Icons.smart_toy_outlined;
      case RewardType.courseAccess:
        return Icons.school_outlined;
      case RewardType.downloadableFile:
        return Icons.file_download_outlined;
      case RewardType.certificate:
        return Icons.workspace_premium_outlined;
      case RewardType.badge:
        return Icons.military_tech_outlined;
      case RewardType.physicalGift:
      case RewardType.physicalPrize:
        return Icons.card_giftcard_rounded;
      case RewardType.unknown:
        return Icons.redeem_rounded;
    }
  }

  static Color background(RewardType type) {
    switch (type) {
      case RewardType.courseAccess:
      case RewardType.xp:
        return const Color(0xFFDDF8D2);
      case RewardType.physicalGift:
      case RewardType.physicalPrize:
      case RewardType.streakFreeze:
        return const Color(0xFFAED2FF);
      case RewardType.downloadableFile:
      case RewardType.cvCredits:
        return const Color(0xFFE9D3FF);
      case RewardType.aiPackage:
        return const Color(0xFFFFE6C7);
      case RewardType.certificate:
      case RewardType.badge:
        return const Color(0xFFFFF0BD);
      case RewardType.unknown:
        return const Color(0xFFEAEAEA);
    }
  }

  static Color accent(RewardType type) {
    switch (type) {
      case RewardType.courseAccess:
      case RewardType.xp:
        return const Color(0xFF267A05);
      case RewardType.physicalGift:
      case RewardType.physicalPrize:
      case RewardType.streakFreeze:
        return const Color(0xFF0065A8);
      case RewardType.downloadableFile:
      case RewardType.cvCredits:
        return const Color(0xFF8728D9);
      case RewardType.aiPackage:
        return const Color(0xFFC76A00);
      case RewardType.certificate:
      case RewardType.badge:
        return const Color(0xFFA76500);
      case RewardType.unknown:
        return const Color(0xFF555555);
    }
  }

  static Color statusBackground(String status) {
    switch (status.trim().toLowerCase()) {
      case 'claimed':
      case 'issued':
      case 'delivered':
        return const Color(0xFFD9F7CB);
      case 'dispatched':
      case 'processing':
      case 'address_received':
        return const Color(0xFFDCEEFF);
      case 'revoked':
      case 'cancelled':
      case 'failed':
        return const Color(0xFFFFD9D9);
      default:
        return const Color(0xFFFFE8C6);
    }
  }

  static Color statusText(String status) {
    switch (status.trim().toLowerCase()) {
      case 'claimed':
      case 'issued':
      case 'delivered':
        return const Color(0xFF267A05);
      case 'dispatched':
      case 'processing':
      case 'address_received':
        return const Color(0xFF0065A8);
      case 'revoked':
      case 'cancelled':
      case 'failed':
        return const Color(0xFFB42318);
      default:
        return const Color(0xFFA76500);
    }
  }
}

String formatRewardDate(DateTime? date) {
  if (date == null) return 'date_unavailable'.tr;
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final DateTime local = date.toLocal();
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}
