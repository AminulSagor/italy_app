import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../controllers/practice_hub_controller.dart';
import '../../../models/survival_italian_models.dart';

class SurvivalHeroSituationCard extends GetView<PracticeHubController> {
  const SurvivalHeroSituationCard({required this.item, super.key});

  final SurvivalSituationModel item;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = parseSurvivalCardColor(item.cardColor);
    final Color foreground = survivalCardForeground(baseColor);

    return GestureDetector(
      onTap: () => controller.openSurvivalPdf(item),
      child: Container(
        width: double.infinity,
        height: 310.h,
        padding: EdgeInsets.fromLTRB(32.w, 32.h, 26.w, 31.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              baseColor,
              Color.lerp(baseColor, AppColors.white, 0.24) ?? baseColor,
            ],
          ),
          borderRadius: BorderRadius.circular(44.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: baseColor.withValues(alpha: 0.28),
              blurRadius: 28.r,
              offset: Offset(0, 18.h),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -5.w,
              bottom: -24.h,
              child: Icon(
                survivalIconFor(item.iconKey),
                size: 92.r,
                color: foreground.withValues(alpha: 0.16),
              ),
            ),
            if (item.isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 30.r,
                  color: foreground,
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(17.r),
                  ),
                  child: Icon(
                    survivalIconFor(item.iconKey),
                    size: 38.r,
                    color: foreground,
                  ),
                ),
                const Spacer(),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font30.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: foreground,
                  ),
                ),
                if (item.subtitleBn?.isNotEmpty == true) ...<Widget>[
                  SizedBox(height: 11.h),
                  Text(
                    item.subtitleBn!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ],
                SizedBox(height: 22.h),
                Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  decoration: BoxDecoration(
                    color: foreground,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        item.isCompleted ? 'review'.tr : 'start_here'.tr,
                        style: TextStyle(
                          fontSize: AppFont.font15.sp,
                          fontWeight: FontWeight.w900,
                          color: baseColor,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 16.r,
                        color: baseColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SurvivalSmallSituationCard extends GetView<PracticeHubController> {
  const SurvivalSmallSituationCard({required this.item, super.key});

  final SurvivalSituationModel item;

  @override
  Widget build(BuildContext context) {
    final Color background = parseSurvivalCardColor(item.cardColor);
    final Color foreground = survivalCardForeground(background);

    return GestureDetector(
      onTap: () => controller.openSurvivalPdf(item),
      child: Container(
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 18.w, 20.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(42.r),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(
                    survivalIconFor(item.iconKey),
                    size: 25.r,
                    color: foreground,
                  ),
                ),
                const Spacer(),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.45,
                    color: foreground,
                  ),
                ),
                if (item.subtitleBn?.isNotEmpty == true) ...<Widget>[
                  SizedBox(height: 7.h),
                  Text(
                    item.subtitleBn!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: foreground.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ],
            ),
            if (item.isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 23.r,
                  color: foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SurvivalWideSituationCard extends GetView<PracticeHubController> {
  const SurvivalWideSituationCard({required this.item, super.key});

  final SurvivalSituationModel item;

  @override
  Widget build(BuildContext context) {
    final Color background = parseSurvivalCardColor(item.cardColor);
    final Color foreground = survivalCardForeground(background);

    return GestureDetector(
      onTap: () => controller.openSurvivalPdf(item),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 145.h),
        padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 22.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(42.r),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(17.r),
              ),
              child: Icon(
                survivalIconFor(item.iconKey),
                size: 28.r,
                color: foreground,
              ),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: foreground,
                    ),
                  ),
                  if (item.subtitleBn?.isNotEmpty == true) ...<Widget>[
                    SizedBox(height: 8.h),
                    Text(
                      item.subtitleBn!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.font12.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: foreground.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.isCompleted)
              Icon(
                Icons.check_circle_rounded,
                size: 25.r,
                color: foreground,
              ),
          ],
        ),
      ),
    );
  }
}

Color parseSurvivalCardColor(String value) {
  final String normalized = value.replaceAll('#', '').trim();
  final String hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  final int? parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? const Color(0xFFE8F7EA) : Color(parsed);
}

Color survivalCardForeground(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? AppColors.white
      : Color.lerp(background, Colors.black, 0.62) ?? const Color(0xFF26332A);
}

IconData survivalIconFor(String iconKey) {
  return switch (iconKey.trim().toLowerCase()) {
    'clock' => Icons.schedule_rounded,
    'bus' => Icons.directions_bus_rounded,
    'grocery' => Icons.local_grocery_store_rounded,
    'pharmacy' => Icons.local_pharmacy_rounded,
    'hospital' => Icons.local_hospital_rounded,
    'police' => Icons.local_police_rounded,
    'home' => Icons.home_rounded,
    'location' => Icons.location_on_rounded,
    _ => Icons.description_rounded,
  };
}
