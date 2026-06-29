import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/themes/app_colors.dart';

import '../../../../../core/themes/app_font.dart';
import '../_widgets/guide_bottom_action_button.dart';
import '../_widgets/guide_info_card.dart';
import '../_widgets/guide_video_card.dart';
import '../_widgets/official_checklist_card.dart';

class PermessoSoggiornoGuideView extends StatelessWidget {
  const PermessoSoggiornoGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 24.h),
                child: Column(
                  children: <Widget>[
                    const _Header(),
                    SizedBox(height: 14.h),
                    const GuideVideoCard(),
                    SizedBox(height: 18.h),
                    const GuideInfoCard(),
                    SizedBox(height: 18.h),
                    const OfficialChecklistCard(),
                  ],
                ),
              ),
            ),
            GuideBottomActionButton(
              title: 'Go To official Website',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: AppFont.font13.sp,
                  color: AppColors.homeDarkGreen,
                ),
              ),
            ),
          ),
          Text(
            'Permesso di Soggiorno Guide',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
