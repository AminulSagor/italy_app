import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';

class SurvivalItalianView extends GetView<PracticeHubController> {
  const SurvivalItalianView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: Stack(
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 150.h),
              child: Obx(() {
                final Map<String, dynamic> hero = controller.survivalHeroItem;
                final List<Map<String, dynamic>> smallCards =
                    controller.survivalSmallCards;
                final Map<String, dynamic> wideCard =
                    controller.survivalWideItem;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _SurvivalHeader(),
                    SizedBox(height: 26.h),

                    _HeroSituationCard(item: hero),

                    SizedBox(height: 32.h),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _SmallSituationCard(item: smallCards[0]),
                        ),
                        SizedBox(width: 24.w),
                        Expanded(
                          child: _SmallSituationCard(item: smallCards[1]),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _SmallSituationCard(item: smallCards[2]),
                        ),
                        SizedBox(width: 24.w),
                        Expanded(
                          child: _SmallSituationCard(item: smallCards[3]),
                        ),
                      ],
                    ),

                    SizedBox(height: 25.h),

                    _WideSituationCard(item: wideCard),
                  ],
                );
              }),
            ),
          ),

          const _SurvivalProgressBar(),
        ],
      ),
    );
  }
}

class _SurvivalHeader extends GetView<PracticeHubController> {
  const _SurvivalHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: controller.onSurvivalBackTap,
            child: Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24.r,
                color: const Color(0xFF2C3034),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Survival Italian',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: const Color(0xFF376812),
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'ইতালিতে আসার পর পর যা শিখতে হবে',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font11.sp,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF72777B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 62.w),
        ],
      ),
    );
  }
}

class _HeroSituationCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> item;

  const _HeroSituationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.openSurvivalPdf(item),
      child: Container(
        width: double.infinity,
        height: 296.h,
        padding: EdgeInsets.fromLTRB(32.w, 32.h, 26.w, 31.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFFF9F15), Color(0xFFFFB75C)],
          ),
          borderRadius: BorderRadius.circular(44.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFFFA629).withValues(alpha: 0.32),
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
              child: Transform.rotate(
                angle: -0.35,
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  size: 92.r,
                  color: AppColors.white.withValues(alpha: 0.18),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(17.r),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 38.r,
                    color: AppColors.white,
                  ),
                ),

                const Spacer(),

                Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontSize: AppFont.font30.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: AppColors.white,
                  ),
                ),

                SizedBox(height: 11.h),

                Text(
                  item['subtitle'] as String,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),

                SizedBox(height: 26.h),

                Container(
                  height: 48.h,
                  width: 142.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Start Here',
                        style: TextStyle(
                          fontSize: AppFont.font15.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF8C4F05),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 16.r,
                        color: const Color(0xFF8C4F05),
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

class _SmallSituationCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> item;

  const _SmallSituationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color background = item['background'] as Color;
    final Color iconBackground = item['iconBackground'] as Color;
    final Color color = item['color'] as Color;

    return GestureDetector(
      onTap: () => controller.openSurvivalPdf(item),
      child: Container(
        height: 176.h,
        padding: EdgeInsets.fromLTRB(24.w, 25.h, 18.w, 22.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(42.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(item['icon'] as IconData, size: 25.r, color: color),
            ),
            const Spacer(),
            Text(
              item['title'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.45,
                color: color,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              item['bangla'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font12.sp,
                height: 1,
                fontWeight: FontWeight.w800,
                color: color.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideSituationCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> item;

  const _WideSituationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color background = item['background'] as Color;
    final Color iconBackground = item['iconBackground'] as Color;
    final Color color = item['color'] as Color;

    return GestureDetector(
      onTap: () => controller.openSurvivalPdf(item),
      child: Container(
        width: double.infinity,
        height: 153.h,
        padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 25.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(42.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(item['icon'] as IconData, size: 25.r, color: color),
            ),
            const Spacer(),
            Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              item['bangla'] as String,
              style: TextStyle(
                fontSize: AppFont.font12.sp,
                height: 1,
                fontWeight: FontWeight.w800,
                color: color.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurvivalProgressBar extends GetView<PracticeHubController> {
  const _SurvivalProgressBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24.w,
      right: 24.w,
      bottom: 30.h,
      child: SafeArea(
        top: false,
        child: Obx(() {
          final int learned = controller.survivalSituationsLearned;
          final int total = controller.survivalTotalSituations;
          final double progress = controller.survivalLearningProgress;

          return Container(
            height: 81.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: const Color(0xFFCDE7C2), width: 1.2.w),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints _) {
                        return Container(
                          width: 342.w * progress,
                          height: 5.h,
                          color: const Color(0xFF70FF36),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 41.r,
                          height: 41.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF4E6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 27.r,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        RichText(
                          text: TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'Total Situations Learned: ',
                                style: TextStyle(
                                  fontSize: AppFont.font15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF676B6F),
                                ),
                              ),
                              TextSpan(
                                text: '$learned/$total',
                                style: TextStyle(
                                  fontSize: AppFont.font16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryGreen,
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
          );
        }),
      ),
    );
  }
}
