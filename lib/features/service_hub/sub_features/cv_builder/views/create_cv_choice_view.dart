import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_choice_option_card.dart';
import '../_widgets/recent_cv_tile.dart';
import '../../../../../routes/app_routes.dart';

class CreateCvChoiceView extends StatelessWidget {
  const CreateCvChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _Header(),
              SizedBox(height: 30.h),
              Center(
                child: Text(
                  'create_your_cv'.tr,
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font24.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -0.7,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  'choose_how_to_start_your_professional_journey'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.homeSecondaryText,
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 26.h),
              CvChoiceOptionCard(
                title: 'gen_create_a_new_cv'.tr,
                icon: Icons.note_add_rounded,
                backgroundColor: AppColors.primaryGreen,
                iconBackgroundColor: AppColors.serviceHubGreenStart,
                iconColor: AppColors.white,
                titleColor: AppColors.white,
                isPrimary: true,
                onTap: () => Get.toNamed(AppRoutes.chooseCvTemplate),
              ),
              SizedBox(height: 14.h),
              CvChoiceOptionCard(
                title: 'gen_use_existing_cv'.tr,
                subtitle: 'gen_duplicate_or_edit_your_previou'.tr,
                icon: Icons.copy_rounded,
                backgroundColor: AppColors.white,
                iconBackgroundColor: AppColors.homePaleGreen,
                iconColor: AppColors.primaryGreen,
                titleColor: AppColors.homePrimaryText,
                borderColor: AppColors.primaryGreen,
                onTap: () {},
              ),
              SizedBox(height: 28.h),
              Text(
                'recent_cvs_1'.tr,
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 22.h),
              _SectionLabel(title: 'gen_drafts'.tr),
              SizedBox(height: 10.h),
              RecentCvTile(
                title: 'gen_kitchen_assistant'.tr,
                subtitle: 'gen_last_edited_2_days_ago'.tr,
                status: 'draft'.tr,
                isCompleted: false,
                onTap: () {},
              ),
              SizedBox(height: 10.h),
              RecentCvTile(
                title: 'gen_delivery_driver'.tr,
                subtitle: 'gen_last_edited_5_days_ago'.tr,
                status: 'draft'.tr,
                isCompleted: false,
                onTap: () {},
              ),
              SizedBox(height: 22.h),
              _SectionLabel(title: 'gen_completed'.tr),
              SizedBox(height: 10.h),
              RecentCvTile(
                title: 'gen_restaurant_waiter'.tr,
                subtitle: 'gen_oct_2023'.tr,
                status: 'completed'.tr,
                isCompleted: true,
                onTap: () {},
              ),
              SizedBox(height: 10.h),
              RecentCvTile(
                title: 'gen_cleaning_staff'.tr,
                subtitle: 'gen_sept_2023'.tr,
                status: 'completed'.tr,
                isCompleted: true,
                onTap: () {},
              ),
            ],
          ),
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
            'your_future'.tr,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.homeSecondaryText,
        fontSize: AppFont.font9.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }
}
