import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/user_session_controller.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/widgets.dart';

class AiCreditStatusRow extends GetView<UserSessionController> {
  const AiCreditStatusRow();

  @override
  UserSessionController get controller => Get.find<UserSessionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: <Widget>[
          _StatusChip(
            icon: Icons.diamond_rounded,
            iconColor: const Color(0xFF357AFF),
            label: controller.aiTextBalanceLabel,
          ),
          const Spacer(),
          _StatusChip(
            icon: Icons.mic_rounded,
            iconColor: const Color(0xFFFF4C7D),
            label: controller.aiVoiceBalanceLabel,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatusChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15.r, color: iconColor),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF364153),
            ),
          ),
        ],
      ),
    );
  }
}

class AiSpeakingLabCard extends StatelessWidget {
  final VoidCallback onTap;

  const AiSpeakingLabCard({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String languageCode = Get.locale?.languageCode ?? 'en';

    final bool isItalian = languageCode == 'it';
    final bool isBangla = languageCode == 'bn';

    return _GradientFeatureCard(
      // Bangla requires more space because the text wraps more.
      height: isBangla ? 275 : 252,
      borderRadius: 54,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFF1C5C36),
          Color(0xFF3D8500),
          Color(0xFF184E31),
        ],
        stops: <double>[0.05, 0.54, 1],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          32.w,
          32.h,
          32.w,
          24.h, // Guaranteed bottom margin
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  // Prevent the title from going under the microphone.
                  padding: EdgeInsets.only(right: 85.w),
                  child: Text(
                    'ai_speaking_lab'.tr,
                    style: TextStyle(
                      fontSize: isItalian ? 20.sp : 24.sp,
                      height: isItalian ? 1.15 : 1.06,
                      fontWeight: FontWeight.w900,
                      letterSpacing: isItalian ? -0.3 : -0.7,
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Text(
                    'ai_speaking_lab_description'.tr,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.62),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ai_speaking_lab_badge'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9BFF3E),
                  ),
                ),

                // Pushes the button to the bottom.
                const Spacer(),

                CustomButton(
                  text: 'enter_lab',
                  onPressed: onTap,
                  width: (isItalian || isBangla) ? 210 : 157,
                  height: 43,
                  btnColor: AppColors.white,
                  textColor: const Color(0xFF153D35),
                  fontSize: isBangla ? 12 : 14,
                  icon: Icons.play_arrow_rounded,
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF66A61D).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(
                  Icons.mic_none_rounded,
                  size: 35.r,
                  color: const Color(0xFF9DF02E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiGuidedLearningCard extends StatelessWidget {
  final VoidCallback onTap;

  const AiGuidedLearningCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String languageCode = Get.locale?.languageCode ?? 'en';

    final bool isItalian = languageCode == 'it';
    final bool isBangla = languageCode == 'bn';

    final double buttonWidth = isItalian ? 270 : (isBangla ? 235 : 222);

    final double buttonHeight = isItalian ? 48 : (isBangla ? 46 : 43);

    final double buttonFontSize = isItalian ? 12 : (isBangla ? 13 : 14);

    return _GradientFeatureCard(
      height: 309,
      borderRadius: 38,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF087062), Color(0xFF0AA574)],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(32.w, 33.h, 30.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 32.r,
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: Text(
                    'ai_guided_learning_title'.tr,
                    style: TextStyle(
                      fontSize: 29.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.9,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'ai_guided_learning_description'.tr,
              maxLines: isItalian || isBangla ? 4 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isItalian
                    ? 13.sp
                    : isBangla
                    ? 13.5.sp
                    : 15.sp,
                height: isItalian
                    ? 1.45
                    : isBangla
                    ? 1.55
                    : 1.55,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'ai_guided_learning_badge'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(height: 6.h),
            CustomButton(
              // CustomButton already translates the key internally.
              text: 'start_guided_learning',
              onPressed: onTap,
              width: buttonWidth,
              height: buttonHeight,
              btnColor: AppColors.white,
              textColor: const Color(0xFF153D35),
              fontSize: buttonFontSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientFeatureCard extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Gradient gradient;
  final Widget child;

  const _GradientFeatureCard({
    required this.height,
    required this.borderRadius,
    required this.gradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AiToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const AiToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 153.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(34.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 55.r,
              height: 55.r,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28.r, color: iconColor),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: textColor.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiRecentSessionCard extends StatelessWidget {
  final VoidCallback onTap;

  const AiRecentSessionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(48.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 14.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 51.r,
              height: 51.r,
              decoration: const BoxDecoration(
                color: Color(0xFFE9FFD5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 26.r,
                color: const Color(0xFF7DD21D),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'recent_session'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                      color: const Color(0xFFA9B3C6),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '92_pronunciation'.tr,
                    style: TextStyle(
                      fontSize: 19.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: const Color(0xFF242C3E),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.trending_up_rounded,
              size: 30.r,
              color: const Color(0xFF74C90E),
            ),
          ],
        ),
      ),
    );
  }
}

class AiProTipCard extends StatelessWidget {
  const AiProTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F3),
        borderRadius: BorderRadius.circular(42.r),
        border: Border.all(color: const Color(0xFFD8DEDE), width: 1.w),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.lightbulb_rounded,
            size: 25.r,
            color: const Color(0xFF153F35),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF51606E),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'pro_tip'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF153F35),
                    ),
                  ),
                  TextSpan(text: 'ai_pro_tip_speaking_daily'.tr),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
