import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import ' permesso_soggiorno_guide_view.dart';
import '../ _widgets/caf_path_card.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import 'administrative_services_view.dart';


class CafAdministrativeHelpView extends StatelessWidget {
  const CafAdministrativeHelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Header(),
              SizedBox(height: 26.h),
              Text(
                'Welcome to the Gateway',
                style: TextStyle(
                  color: AppColors.homeSecondaryText,
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Choose Your Path',
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font22.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(height: 18.h),
              CafPathCard(
                minHeight: 192.h,
                gradientColors: const <Color>[
                  AppColors.serviceHubGreenStart,
                  AppColors.serviceHubGreenEnd,
                ],
                leadingIcon: Icons.school_rounded,
                trailingIcon: Icons.menu_book_rounded,
                title: 'CAF Courses',
                description: 'Learn how the Italian tax and legal system works.',
                buttonText: 'START LEARNING',
                onTap: () {Get.to(() => const PermessoSoggiornoGuideView());},
              ),
              SizedBox(height: 20.h),
              CafPathCard(
                minHeight: 224.h,
                gradientColors: const <Color>[
                  AppColors.homeBlueIcon,
                  AppColors.legacyColorFF0B4A7D,
                ],
                leadingIcon: Icons.description_rounded,
                trailingIcon: Icons.verified_rounded,
                title: 'CAF Services & Guides',
                description:
                'Step-by-step help for your documents.\nপ্রশাসনিক সহায়তা এবং গাইড',
                descriptionMaxLines: 3,
                buttonText: 'EXPLORE SERVICES',
                onTap: () {Get.to(() => const  AdministrativeServicesView());},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
            'CAF & Legal Hub',
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