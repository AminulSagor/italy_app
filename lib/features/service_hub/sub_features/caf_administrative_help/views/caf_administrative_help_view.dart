import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/caf_path_card.dart';
import 'administrative_services_view.dart';
import 'permesso_soggiorno_guide_view.dart';

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
                'welcome_to_the_gateway'.tr,
                style: TextStyle(
                  color: AppColors.homeSecondaryText,
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'choose_your_path'.tr,
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
                title: 'gen_caf_courses'.tr,
                description:
                    'learn_how_the_italian_tax_and_legal_system_works'.tr,
                buttonText: 'gen_start_learning'.tr,
                onTap: () {
                  Get.to(() => const PermessoSoggiornoGuideView());
                },
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
                title: 'gen_caf_services_guides'.tr,
                description:
                    'Step-by-step help for your documents.\nপ্রশাসনিক সহায়তা এবং গাইড',
                descriptionMaxLines: 3,
                buttonText: 'gen_explore_services'.tr,
                onTap: () {
                  Get.to(() => const AdministrativeServicesView());
                },
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
            'caf_legal_hub'.tr,
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
