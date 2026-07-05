import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../routes/app_routes.dart';
import '../_widgets/cv_create_card.dart';
import '../_widgets/cv_credit_card.dart';
import '../_widgets/cv_document_card.dart';
import '../_widgets/cv_tip_card.dart';

class CvBuilderView extends StatelessWidget {
  const CvBuilderView({super.key});

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
              SizedBox(height: 14.h),
              CvCreateCard(onTap: () => Get.toNamed(AppRoutes.createCvChoice)),
              SizedBox(height: 22.h),
              _SectionTitle(title: 'gen_get_more_credits'.tr),
              SizedBox(height: 10.h),
              SizedBox(
                height: 88.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    CvCreditCard(
                      title: 'gen_1_cv_credit'.tr,
                      price: '€0.99',
                      backgroundColor: AppColors.white,
                      titleColor: AppColors.homePrimaryText,
                      priceColor: AppColors.homePrimaryText,
                      iconBackgroundColor: AppColors.safetyBlockedBg,
                      iconColor: AppColors.primaryGreen,
                      onTap: () {},
                    ),
                    SizedBox(width: 10.w),
                    CvCreditCard(
                      title: 'gen_5_cv_credits'.tr,
                      price: '€2.99',
                      backgroundColor: AppColors.primaryGreen,
                      titleColor: AppColors.white,
                      priceColor: AppColors.serviceHubLightGreen,
                      iconBackgroundColor: AppColors.serviceHubLightGreen,
                      iconColor: AppColors.primaryGreen,
                      onTap: () {},
                    ),
                    SizedBox(width: 10.w),
                    CvCreditCard(
                      title: 'gen_unlimited'.tr,
                      price: '€5.99',
                      backgroundColor: AppColors.homeOrange,
                      titleColor: AppColors.homePrimaryText,
                      priceColor: AppColors.homePrimaryText,
                      iconBackgroundColor: AppColors.white,
                      iconColor: AppColors.homeOrange,
                      onTap: () {},
                    ),
                    SizedBox(width: 10.w),
                    CvCreditCard(
                      title: 'gen_1_cv_credit'.tr,
                      price: '€0.99',
                      backgroundColor: AppColors.white,
                      titleColor: AppColors.homePrimaryText,
                      priceColor: AppColors.homePrimaryText,
                      iconBackgroundColor: AppColors.safetyBlockedBg,
                      iconColor: AppColors.primaryGreen,
                      onTap: () {},
                    ),
                    SizedBox(width: 10.w),
                    CvCreditCard(
                      title: 'gen_5_cv_credits'.tr,
                      price: '€2.99',
                      backgroundColor: AppColors.primaryGreen,
                      titleColor: AppColors.white,
                      priceColor: AppColors.serviceHubLightGreen,
                      iconBackgroundColor: AppColors.serviceHubLightGreen,
                      iconColor: AppColors.primaryGreen,
                      onTap: () {},
                    ),
                    SizedBox(width: 10.w),
                    CvCreditCard(
                      title: 'gen_unlimited'.tr,
                      price: '€5.99',
                      backgroundColor: AppColors.homeOrange,
                      titleColor: AppColors.homePrimaryText,
                      priceColor: AppColors.homePrimaryText,
                      iconBackgroundColor: AppColors.white,
                      iconColor: AppColors.homeOrange,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              _SectionTitle(title: 'gen_your_documents'.tr),
              SizedBox(height: 10.h),
              CvDocumentCard(
                title: 'gen_restaurant_waiter_cv'.tr,
                subtitle: 'gen_saved_oct_24_2023'.tr,
                onPreviewTap: () {},
                onDownloadTap: () {},
                onEditTap: () {},
              ),
              SizedBox(height: 10.h),
              CvDocumentCard(
                title: 'gen_delivery_driver'.tr,
                subtitle: 'gen_saved_sep_12_2023'.tr,
                onPreviewTap: () {},
                onDownloadTap: () {},
                onEditTap: () {},
              ),
              SizedBox(height: 14.h),
              const CvTipCard(),
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
      height: 48.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: AppFont.font22.sp,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'my_cv_hub'.tr,
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: AppFont.font22.sp,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -0.6,
              ),
            ),
          ),
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            decoration: BoxDecoration(
              color: AppColors.homePaleGreen,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primaryGreen,
                  size: AppFont.font13.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '1_free'.tr,
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: AppFont.font11.sp,
                    fontWeight: FontWeight.w900,
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.homeSecondaryText,
        fontSize: AppFont.font8.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }
}
