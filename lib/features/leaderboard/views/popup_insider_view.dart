import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';

class PopupInsiderView extends StatelessWidget {
  const PopupInsiderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 77.h),
                      _LeagueInfoCard(
                        title: 'gen_bronze_league'.tr,
                        xp: '0 – 999 XP',
                        bgColor: Color(0xFFFFEDE2),
                        titleColor: Color(0xFF2B1608),
                        xpColor: Color(0xFF9A4E05),
                        icon: Icons.military_tech_rounded,
                        iconColor: Color(0xFF9A4E05),
                      ),
                      SizedBox(height: 17.h),
                      _LeagueInfoCard(
                        title: 'gen_silver_league'.tr,
                        xp: '1,000 – 4,999 XP',
                        bgColor: Color(0xFFADD0FB),
                        titleColor: Color(0xFF07365D),
                        xpColor: Color(0xFF075F9E),
                        icon: Icons.workspace_premium_rounded,
                        iconColor: Color(0xFF075F9E),
                      ),
                      SizedBox(height: 17.h),
                      _LeagueInfoCard(
                        title: 'gen_gold_league'.tr,
                        xp: '5,000–9,999 XP',
                        bgColor: Color(0xFFFFF7DE),
                        titleColor: Color(0xFF3A2108),
                        xpColor: Color(0xFFFF8700),
                        icon: Icons.star_rounded,
                        iconColor: Color(0xFFFF8A00),
                      ),
                      SizedBox(height: 17.h),
                      _LeagueInfoCard(
                        title: 'gen_diamond_league'.tr,
                        xp: '10,000+ XP',
                        bgColor: Color(0xFFD9F5F8),
                        titleColor: Color(0xFF006273),
                        xpColor: Color(0xFF0091A6),
                        icon: Icons.diamond_rounded,
                        iconColor: Color(0xFF0095A8),
                        showWatermark: true,
                      ),
                      SizedBox(height: 48.h),
                      _DeepGreenButton(
                        text: 'got_it'.tr,
                        onTap: () => Get.back<void>(),
                      ),
                      SizedBox(height: 34.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 42.w),
                        child: Text(
                          'XP increases as you complete lessons, practice\nconversations, and master Italian vocabulary.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font10.sp,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA4A8AE),
                          ),
                        ),
                      ),
                      SizedBox(height: 44.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LeagueInfoCard extends StatelessWidget {
  final String title;
  final String xp;
  final Color bgColor;
  final Color titleColor;
  final Color xpColor;
  final IconData icon;
  final Color iconColor;
  final bool showWatermark;

  const _LeagueInfoCard({
    required this.title,
    required this.xp,
    required this.bgColor,
    required this.titleColor,
    required this.xpColor,
    required this.icon,
    required this.iconColor,
    this.showWatermark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 127.h,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Stack(
        children: <Widget>[
          if (showWatermark)
            Positioned(
              right: -10.w,
              top: 8.h,
              child: Icon(
                Icons.diamond_rounded,
                size: 115.r,
                color: const Color(0xFF8DD4DA).withValues(alpha: 0.22),
              ),
            ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 18.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 45.r, color: iconColor),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: AppFont.font20.sp,
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          xp,
                          style: TextStyle(
                            fontSize: AppFont.font14.sp,
                            fontWeight: FontWeight.w900,
                            color: xpColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        height: 70.h,
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
            fontSize: AppFont.font18.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
