import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_constants.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/custom_button.dart';
import '../models/shop_models.dart';
import '../shop_controller.dart';

class StreakFreezeView extends GetView<ShopController> {
  const StreakFreezeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const _StoreTopBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'streak_freeze_store'.tr,
                style: TextStyle(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1.1,
                  color: AppColors.headerText,
                ),
              ),
              SizedBox(height: 7.h),
              Center(
                child: Text(
                  'protect_your_progress_in_italian'.tr,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
                ),
              ),
              SizedBox(height: 33.h),
              const _InventoryCard(),
              SizedBox(height: 32.h),
              Obx(() {
                if (controller.streakPackages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text('no_streak_freeze_packages_are_available'.tr),
                    ),
                  );
                }
                return Column(
                  children: controller.streakPackages
                      .map(
                        (StorePackageModel package) => Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: _FreezePackCard(package: package),
                        ),
                      )
                      .toList(growable: false),
                );
              }),
              SizedBox(height: 50.h),
              Obx(
                () => CustomButton.primary(
                  text: controller.isLoadingQuote.value
                      ? 'loading'.tr
                      : 'confirm_purchase'.tr,
                  icon: Icons.play_arrow_rounded,
                  onPressed: controller.isLoadingQuote.value ||
                          controller.streakPackages.isEmpty
                      ? () {}
                      : controller.goToStreakFreezeOrderSummary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _StoreTopBar();

  @override
  Size get preferredSize => Size.fromHeight(104.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 17.h),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: Get.back,
                  child: Container(
                    width: 47.r,
                    height: 47.r,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.04),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 23.r,
                      color: AppColors.blockSuccessBlueText,
                    ),
                  ),
                ),
              ),
              Text(
                'streak_freeze_refiller'.tr,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.blockSuccessBlueText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryCard extends GetView<ShopController> {
  const _InventoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 144.h,
      padding: EdgeInsets.fromLTRB(24.w, 19.h, 24.w, 19.h),
      decoration: BoxDecoration(
        color: AppColors.blockSuccessBlueBg,
        borderRadius: BorderRadius.circular(kRadius30.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'your_inventory'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.blockSuccessBlueText,
                  ),
                ),
                SizedBox(height: 6.h),
                Obx(
                  () => Text(
                    'freezes_controller_streakfreezebalance'.trParams(<String, String>{'streakfreezebalance': controller.streakFreezeBalance.toString()}),
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.blockSuccessBlueText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 76.r,
            height: 76.r,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.12),
                  blurRadius: 18.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Icon(
              Icons.ac_unit_rounded,
              size: 49.r,
              color: AppColors.blockSuccessBlueText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreezePackCard extends GetView<ShopController> {
  const _FreezePackCard({required this.package});

  final StorePackageModel package;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool selected = controller.isStreakPackageSelected(package.id);
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          GestureDetector(
            onTap: () => controller.selectStreakPackage(package.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              height: selected ? 185.h : 175.h,
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: selected
                      ? AppColors.blockSuccessBlueText
                      : AppColors.transparent,
                  width: selected ? 4.w : 0,
                ),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 68.w,
                    child: _PackIcon(package: package),
                  ),
                  SizedBox(width: 22.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          package.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font20.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headerText,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          package.description.isNotEmpty
                              ? package.description
                              : package.entitlementSummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bodyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    controller.packagePriceText(package),
                    style: TextStyle(
                      fontSize: AppFont.font20.sp,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? AppColors.blockSuccessBlueText
                          : AppColors.headerText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selected && package.badgeLabel.isNotEmpty)
            Positioned(
              top: -13.h,
              child: Container(
                height: 27.h,
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blockSuccessBlueText,
                  borderRadius: BorderRadius.circular(kRadius60.r),
                ),
                child: Text(
                  package.badgeLabel,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _PackIcon extends StatelessWidget {
  const _PackIcon({required this.package});

  final StorePackageModel package;

  @override
  Widget build(BuildContext context) {
    if (package.isUnlimitedStreak) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.ac_unit_rounded,
            size: 31.r,
            color: AppColors.blockSuccessBlueText,
          ),
          Text(
            '∞',
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w900,
              height: 0.72,
              color: AppColors.blockSuccessBlueText,
            ),
          ),
        ],
      );
    }

    final int count = package.streakFreezeCount.clamp(1, 3).toInt();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2.w,
      runSpacing: 2.h,
      children: List<Widget>.generate(
        count,
        (_) => Icon(
          Icons.ac_unit_rounded,
          size: 27.r,
          color: AppColors.blockSuccessBlueText,
        ),
      ),
    );
  }
}
