import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/user_session_controller.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

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

  const AiSpeakingLabCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final String languageCode = Get.locale?.languageCode ?? 'en';

    final bool isItalian = languageCode == 'it';
    final bool isBangla = languageCode == 'bn';

    final double cardHeight = isBangla
        ? 270
        : isItalian
        ? 255
        : 242;

    return _GradientFeatureCard(
      onTap: onTap,
      semanticLabel: 'enter_lab'.tr,
      height: cardHeight,
      borderRadius: 42,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFF155B3B),
          Color(0xFF348900),
          Color(0xFF124D37),
        ],
        stops: <double>[0, 0.55, 1],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(28.w, 28.h, 26.w, 24.h),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 82.w),
                  child: Text(
                    'ai_speaking_lab'.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isItalian ? 20.sp : 24.sp,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: isItalian ? -0.3 : -0.7,
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(height: 11.h),
                Padding(
                  padding: EdgeInsets.only(right: 24.w),
                  child: Text(
                    'ai_speaking_lab_description'.tr,
                    maxLines: isBangla || isItalian ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isBangla ? 13.5.sp : 15.sp,
                      height: isBangla ? 1.5 : 1.48,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                _FeatureBadge(
                  label: 'ai_speaking_lab_badge'.tr,
                  foregroundColor: const Color(0xFFB7FF62),
                  backgroundColor: const Color(
                    0xFFB7FF62,
                  ).withValues(alpha: 0.12),
                ),
                const Spacer(),
                _InlineCardAction(
                  label: 'enter_lab'.tr,
                  color: const Color(0xFFB7FF62),
                  icon: Icons.arrow_forward_rounded,
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 62.r,
                height: 62.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFB7FF62).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(21.r),
                  border: Border.all(
                    color: const Color(0xFFB7FF62).withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  Icons.mic_none_rounded,
                  size: 34.r,
                  color: const Color(0xFFB7FF62),
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

  const AiGuidedLearningCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final String languageCode = Get.locale?.languageCode ?? 'en';

    final bool isItalian = languageCode == 'it';
    final bool isBangla = languageCode == 'bn';

    final double cardHeight = isBangla
        ? 300
        : isItalian
        ? 292
        : 278;

    return _GradientFeatureCard(
      onTap: onTap,
      semanticLabel: 'start_guided_learning'.tr,
      height: cardHeight,
      borderRadius: 38,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF08776A), Color(0xFF0AA574)],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(28.w, 28.h, 27.w, 24.h),
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
                    color: AppColors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(17.r),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 31.r,
                    color: AppColors.white.withValues(alpha: 0.95),
                  ),
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Text(
                      'ai_guided_learning_title'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isItalian
                            ? 23.sp
                            : isBangla
                            ? 25.sp
                            : 28.sp,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: isItalian ? -0.4 : -0.8,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
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
                    ? 1.52
                    : 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withValues(alpha: 0.78),
              ),
            ),
            SizedBox(height: 10.h),
            _FeatureBadge(
              label: 'ai_guided_learning_badge'.tr,
              foregroundColor: const Color(0xFFD7FFF1),
              backgroundColor: AppColors.white.withValues(alpha: 0.10),
            ),
            const Spacer(),
            _InlineCardAction(
              label: 'start_guided_learning'.tr,
              color: const Color(0xFFD7FFF1),
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  const _FeatureBadge({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.sp,
          height: 1,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _InlineCardAction extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _InlineCardAction({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Icon(icon, size: 20.r, color: color),
        ),
      ],
    );
  }
}

class _GradientFeatureCard extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Gradient gradient;
  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;

  const _GradientFeatureCard({
    required this.height,
    required this.borderRadius,
    required this.gradient,
    required this.child,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius resolvedBorderRadius = BorderRadius.circular(
      borderRadius.r,
    );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Container(
        height: height.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: resolvedBorderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: resolvedBorderRadius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: resolvedBorderRadius,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: resolvedBorderRadius,
              splashColor: AppColors.white.withValues(alpha: 0.12),
              highlightColor: AppColors.white.withValues(alpha: 0.06),
              child: child,
            ),
          ),
        ),
      ),
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
