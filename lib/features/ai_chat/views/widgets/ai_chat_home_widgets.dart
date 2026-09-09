import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/user_session_controller.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

// =============================================================================
// AI CREDIT STATUS ROW
// =============================================================================

class AiCreditStatusRow extends GetView<UserSessionController> {
  const AiCreditStatusRow({super.key});

  @override
  UserSessionController get controller => Get.find<UserSessionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Row(
        children: <Widget>[
          Expanded(
            child: _StatusChip(
              icon: Icons.diamond_rounded,
              iconColor: const Color(0xFF3B82F6),
              iconBackgroundColor: const Color(0xFFEFF6FF),
              label: controller.aiTextBalanceLabel,
              categoryName: 'Text Credits',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _StatusChip(
              icon: Icons.mic_rounded,
              iconColor: const Color(0xFFEC4899),
              iconBackgroundColor: const Color(0xFFFDF2F8),
              label: controller.aiVoiceBalanceLabel,
              categoryName: 'Voice Credits',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final String categoryName;

  const _StatusChip({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.r, color: iconColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    height: 1,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// AI LEVEL TEST HOME CARD
// =============================================================================

class AiLevelTestHomeCard extends StatelessWidget {
  final String subtitle;
  final VoidCallback onTap;

  const AiLevelTestHomeCard({
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(28.r);

    return Semantics(
      button: true,
      label: 'gen_level_test'.tr,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.22),
              blurRadius: 24.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF047857),
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              splashColor: AppColors.white.withValues(alpha: 0.12),
              highlightColor: AppColors.white.withValues(alpha: 0.06),
              child: Stack(
                children: <Widget>[
                  // Soft ambient glow background graphics
                  Positioned(
                    right: -20.r,
                    top: -20.r,
                    child: Container(
                      width: 140.r,
                      height: 140.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -40.r,
                    bottom: -50.r,
                    child: Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFA7F3D0).withValues(alpha: 0.12),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 18.w, 18.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 50.r,
                              height: 50.r,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: AppColors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 26.r,
                                color: const Color(0xFFA7F3D0),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'gen_level_test'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      height: 1.1,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      height: 1.1,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.white.withValues(alpha: 0.82),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Container(
                              width: 38.r,
                              height: 38.r,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.20),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 20.r,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.auto_graph_rounded,
                                size: 16.r,
                                color: const Color(0xFFA7F3D0),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'discover_your_exact_level'.tr,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      height: 1,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white.withValues(alpha: 0.95),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// AI FEATURE CARDS (SPEAKING LAB & GUIDED LEARNING)
// =============================================================================

class AiSpeakingLabCard extends StatelessWidget {
  final VoidCallback onTap;

  const AiSpeakingLabCard({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _CompactFeatureCard(
      onTap: onTap,
      semanticLabel: 'enter_lab'.tr,
      gradientColors: const <Color>[
        Color(0xFFF0FDF4),
        Color(0xFFDCFCE7),
      ],
      borderColor: const Color(0xFFBBF7D0),
      accentColor: const Color(0xFF15803D),
      icon: Icons.mic_rounded,
      iconColor: const Color(0xFF166534),
      iconGradientColors: const <Color>[
        Color(0xFFDCFCE7),
        Color(0xFF86EFAC),
      ],
      title: 'ai_speaking_lab'.tr,
      description: 'ai_speaking_lab_description'.tr,
      actionLabel: 'enter_lab'.tr,
    );
  }
}

class AiGuidedLearningCard extends StatelessWidget {
  final VoidCallback onTap;

  const AiGuidedLearningCard({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _CompactFeatureCard(
      onTap: onTap,
      semanticLabel: 'start_guided_learning'.tr,
      gradientColors: const <Color>[
        Color(0xFFEEF2FF),
        Color(0xFFE0E7FF),
      ],
      borderColor: const Color(0xFFC7D2FE),
      accentColor: const Color(0xFF4338CA),
      icon: Icons.menu_book_rounded,
      iconColor: const Color(0xFF3730A3),
      iconGradientColors: const <Color>[
        Color(0xFFE0E7FF),
        Color(0xFFA5B4FC),
      ],
      title: 'ai_guided_learning_title'.tr,
      description: 'ai_guided_learning_description'.tr,
      actionLabel: 'start_guided_learning'.tr,
    );
  }
}

class _CompactFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final List<Color> iconGradientColors;

  final List<Color> gradientColors;
  final Color borderColor;
  final Color accentColor;

  final String title;
  final String description;
  final String actionLabel;
  final String semanticLabel;
  final VoidCallback onTap;

  const _CompactFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconGradientColors,
    required this.gradientColors,
    required this.borderColor,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(24.r);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 20.r,
              spreadRadius: 0,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              splashColor: accentColor.withValues(alpha: 0.1),
              highlightColor: accentColor.withValues(alpha: 0.05),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: -20.r,
                    top: -20.r,
                    child: Container(
                      width: 90.r,
                      height: 90.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: iconGradientColors,
                            ),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.9),
                              width: 1.5,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.12),
                                blurRadius: 10.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            icon,
                            size: 24.r,
                            color: iconColor,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        height: 1.15,
                                        letterSpacing: -0.3,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      'AI',
                                      style: TextStyle(
                                        fontSize: 8.5.sp,
                                        height: 1,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    actionLabel,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: accentColor,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14.r,
                                    color: accentColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// AI TOOL CARD
// =============================================================================

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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(20.r);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: textColor.withValues(alpha: 0.08),
          highlightColor: textColor.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 22.r, color: iconColor),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.r,
                  color: textColor.withValues(alpha: 0.50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// AI RECENT SESSION CARD
// =============================================================================

class AiRecentSessionCard extends StatelessWidget {
  final VoidCallback onTap;

  const AiRecentSessionCard({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(20.r);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: borderRadius,
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: const Color(0xFF10B981).withValues(alpha: 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    size: 24.r,
                    color: const Color(0xFF059669),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'recent_session'.tr.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '92_pronunciation'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: 20.r,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// AI PRO TIP CARD
// =============================================================================

class AiProTipCard extends StatelessWidget {
  const AiProTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              size: 18.r,
              color: const Color(0xFFD97706),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.4,
                  color: const Color(0xFF78350F),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${'pro_tip'.tr} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  TextSpan(
                    text: 'ai_pro_tip_speaking_daily'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
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