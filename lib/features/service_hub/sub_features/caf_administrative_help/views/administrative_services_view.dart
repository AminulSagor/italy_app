import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../ _widgets/administrative_search_bar.dart';
import '../ _widgets/administrative_service_card.dart';
import '../ _widgets/administrative_service_pill.dart';


class AdministrativeServicesView extends StatelessWidget {
  const AdministrativeServicesView({super.key});

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
              SizedBox(height: 24.h),
              Text(
                'Essential Tasks',
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.7,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                'Select a service to begin your administrative\napplication or renewal process.',
                style: TextStyle(
                  color: AppColors.homeSecondaryText,
                  fontSize: AppFont.font9.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AdministrativeServiceCard(
                      height: 118.h,
                      backgroundColor: AppColors.adminPermitBg,
                      iconBackgroundColor: AppColors.white,
                      icon: Icons.badge_outlined,
                      iconColor: AppColors.adminPurple,
                      label: 'gen_permit'.tr.tr,
                      title: 'gen_permesso_di_soggiorno'.tr.tr,
                      labelColor: AppColors.adminPurple,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: AdministrativeServiceCard(
                      height: 118.h,
                      backgroundColor: AppColors.adminHealthBg,
                      iconBackgroundColor: AppColors.white,
                      icon: Icons.credit_card_rounded,
                      iconColor: AppColors.adminTeal,
                      label: 'gen_health'.tr.tr,
                      title: 'gen_tessera_sanitaria'.tr.tr,
                      labelColor: AppColors.adminTeal,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              AdministrativeServiceCard(
                height: 96.h,
                width: double.infinity,
                backgroundColor: AppColors.adminDocumentBg,
                iconBackgroundColor: AppColors.primaryGreen,
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.white,
                label: 'gen_official_document'.tr.tr,
                title: 'gen_bangladesh_passport'.tr.tr,
                labelColor: AppColors.primaryGreen,
                trailingText: 'gen_safe_work'.tr.tr,
                onTap: () {},
              ),
              SizedBox(height: 14.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AdministrativeServiceCard(
                      height: 118.h,
                      backgroundColor: AppColors.adminTaxesBg,
                      iconBackgroundColor: AppColors.white,
                      icon: Icons.account_balance_rounded,
                      iconColor: AppColors.adminBrown,
                      label: 'gen_taxes'.tr.tr,
                      title: 'gen_agenzia_delle_entrate'.tr.tr,
                      labelColor: AppColors.homeBlueIcon,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: AdministrativeServiceCard(
                      height: 118.h,
                      backgroundColor: AppColors.adminEmploymentBg,
                      iconBackgroundColor: AppColors.white,
                      icon: Icons.work_rounded,
                      iconColor: AppColors.adminBrown,
                      label: 'gen_employment'.tr.tr,
                      title: 'gen_jobs_work_contract'.tr.tr,
                      labelColor: AppColors.adminBrown,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              AdministrativeServicePill(
                icon: Icons.account_balance_rounded,
                label: 'gen_legal'.tr.tr,
                title: 'gen_ministry_of_justice'.tr.tr,
                onTap: () {},
              ),
              SizedBox(height: 28.h),
              const AdministrativeSearchBar(),
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
            'Administrative Services',
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