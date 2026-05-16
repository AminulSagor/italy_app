import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';

class JobSentencesView extends GetView<PracticeHubController> {
  const JobSentencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 48.h),
          child: Column(
            children: <Widget>[
              const _JobSentencesTopBar(),
              SizedBox(height: 28.h),
              Text(
                'Career Tracks',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.1,
                  color: const Color(0xFF2D3236),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'ইতালিতে আপনার পছন্দের কর্মজীবন শুরু করুন',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A8E92),
                ),
              ),
              SizedBox(height: 40.h),

              Obx(
                () => Column(
                  children: controller.jobTracks
                      .map(
                        (Map<String, dynamic> item) => Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: _CareerTrackCard(item: item),
                        ),
                      )
                      .toList(),
                ),
              ),

              SizedBox(height: 8.h),

              const _JobTipCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobSentencesTopBar extends GetView<PracticeHubController> {
  const _JobSentencesTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: controller.onJobSentencesBackTap,
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
      ],
    );
  }
}

class _CareerTrackCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> item;

  const _CareerTrackCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color background = item['background'] as Color;
    //final Color iconBackground = item['iconBackground'] as Color;
    final Color color = item['color'] as Color;

    return GestureDetector(
      onTap: () => controller.openJobTrackDetails(item),
      child: Container(
        width: double.infinity,
        height: 136.h,
        padding: EdgeInsets.fromLTRB(25.w, 24.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(42.r),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 87.r,
              height: 87.r,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.58),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(item['icon'] as IconData, size: 38.r, color: color),
              ),
            ),
            SizedBox(width: 39.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item['title'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      height: 1.16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      color: const Color(0xFF33383C),
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    item['bangla'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8E92),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 31.r, color: color),
          ],
        ),
      ),
    );
  }
}

class _JobTipCard extends StatelessWidget {
  const _JobTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250.h,
      decoration: BoxDecoration(
        color: const Color(0xFFB2D4FF),
        borderRadius: BorderRadius.circular(42.r),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -40.w,
            bottom: -30.h,
            child: Container(
              width: 126.r,
              height: 126.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF79A9DE).withValues(alpha: 0.52),
                  width: 14.w,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(32.w, 28.h, 32.w, 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 22.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005A91),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Center(
                    child: Text(
                      'TIP OF THE DAY',
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 19.h),
                Text(
                  'Speak Like a Local',
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: const Color(0xFF075B92),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: 258.w,
                  child: Text(
                    'Master common workplace phrases used in Italian kitchens and hospitality to stand out during interviews.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.62,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2D6DA4),
                    ),
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
