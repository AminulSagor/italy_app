import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_choice_option_card.dart';
import '../_widgets/recent_cv_tile.dart';

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
                  'Create Your CV',
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
                  'Choose how to start your professional\njourney.',
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
                title: 'Create a New CV',
                icon: Icons.note_add_rounded,
                backgroundColor: AppColors.primaryGreen,
                iconBackgroundColor: AppColors.serviceHubGreenStart,
                iconColor: AppColors.white,
                titleColor: AppColors.white,
                isPrimary: true,
                onTap: () {},
              ),
              SizedBox(height: 14.h),
              CvChoiceOptionCard(
                title: 'Use Existing CV',
                subtitle: 'Duplicate or edit your previous version.',
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
                'Recent CVs',
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 22.h),
              const _SectionLabel(title: 'DRAFTS'),
              SizedBox(height: 10.h),
              RecentCvTile(
                title: 'Kitchen Assistant',
                subtitle: 'Last edited 2 days ago',
                status: 'DRAFT',
                isCompleted: false,
                onTap: () {},
              ),
              SizedBox(height: 10.h),
              RecentCvTile(
                title: 'Delivery Driver',
                subtitle: 'Last edited 5 days ago',
                status: 'DRAFT',
                isCompleted: false,
                onTap: () {},
              ),
              SizedBox(height: 22.h),
              const _SectionLabel(title: 'COMPLETED'),
              SizedBox(height: 10.h),
              RecentCvTile(
                title: 'Restaurant Waiter',
                subtitle: 'Oct 2023',
                status: 'COMPLETED',
                isCompleted: true,
                onTap: () {},
              ),
              SizedBox(height: 10.h),
              RecentCvTile(
                title: 'Cleaning Staff',
                subtitle: 'Sept 2023',
                status: 'COMPLETED',
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
            'Your Future',
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

  const _SectionLabel({
    required this.title,
  });

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