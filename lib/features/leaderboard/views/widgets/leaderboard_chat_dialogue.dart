import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

class LeaderboardChatDialog extends StatelessWidget {
  final Map<String, dynamic> user;

  const LeaderboardChatDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String name = (user['name'] as String? ?? 'Sofia Rossi').replaceAll(
      '\n',
      ' ',
    );
    final String xp = user['xp'] as String? ?? '1,280';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 37.w),
        backgroundColor: AppColors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(32.w, 28.h, 32.w, 42.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 34.r,
                offset: Offset(0, 22.h),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                right: -4.w,
                child: GestureDetector(
                  onTap: () => Get.back<void>(),
                  child: Icon(
                    Icons.close_rounded,
                    size: 28.r,
                    color: const Color(0xFF555555),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 5.h),
                  const _ChatAvatar(),
                  SizedBox(height: 26.h),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                      letterSpacing: -0.7,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const _InfoPill(
                        bgColor: Color(0xFFFFE9D2),
                        icon: Icons.local_fire_department_rounded,
                        iconColor: Color(0xFFE9511B),
                        text: '12 Day Streak',
                        textColor: Color(0xFFC94D1F),
                      ),
                      SizedBox(width: 10.w),
                      _InfoPill(
                        bgColor: const Color(0xFFD9E9FF),
                        icon: Icons.flash_on_rounded,
                        iconColor: const Color(0xFF2764E8),
                        text: '$xp XP',
                        textColor: const Color(0xFF2764E8),
                      ),
                    ],
                  ),
                  SizedBox(height: 35.h),
                  _DeepGreenButton(
                    text: 'Start Chatting',
                    onTap: () {
                      Get.back<void>();
                      Get.snackbar(
                        'Chat',
                        'Chat screen will open after API integration.',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                  SizedBox(height: 30.h),
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: AppFont.font15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108.r,
      height: 108.r,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE0EBD8),
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(4.r),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF162420),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_rounded,
            size: 58.r,
            color: const Color(0xFFD9E0DE),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;

  const _InfoPill({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17.r, color: iconColor),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeepGreenButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _DeepGreenButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: <BoxShadow>[
            BoxShadow(color: const Color(0xFF174B00), offset: Offset(0, 7.h)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppFont.font20.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
