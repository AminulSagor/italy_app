import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../models/shop_models.dart';
import '../shop_controller.dart';

class AdFreeStoreView extends GetView<ShopController> {
  const AdFreeStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: SimpleAppbar(title: 'Ad-Free', onBackTap: () => Get.back<void>()),
      body: SafeArea(
        child: Obx(() {
          final List<StorePackageModel> plans = controller.adFreePackages;
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
                  children: <Widget>[
                    Icon(
                      Icons.block_rounded,
                      size: 58.r,
                      color: const Color(0xFF006B3F),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Learn without ad interruptions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your subscription removes banner, native, interstitial, and rewarded ads across the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.45,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    ...plans.map(
                      (StorePackageModel plan) => Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: _PlanCard(
                          plan: plan,
                          price: controller.packagePriceText(plan),
                          selected: controller.isAdFreePackageSelected(plan.id),
                          onTap: () => controller.selectAdFreePackage(plan.id),
                        ),
                      ),
                    ),
                    if (Platform.isIOS &&
                        controller.selectedAdFreePackage != null)
                      TextButton(
                        onPressed: controller.isRestoringSubscription.value
                            ? null
                            : () => controller.restoreAppStoreSubscription(
                                controller.selectedAdFreePackage!,
                              ),
                        child: Text(
                          controller.isRestoringSubscription.value
                              ? 'Restoring…'
                              : 'Restore Purchases',
                        ),
                      ),
                    SizedBox(height: 12.h),
                    Text(
                      'Auto-renewing subscription. Manage or cancel in your App Store or Google Play account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.4,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: CustomButton.primary(
                  text: 'Continue',
                  onPressed: controller.buySelectedAdFreePlan,
                  btnColor: const Color(0xFF006B3F),
                  borderColor: const Color(0xFF006B3F),
                  textColor: Colors.white,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.price,
    required this.selected,
    required this.onTap,
  });
  final StorePackageModel plan;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: selected ? const Color(0xFF006B3F) : const Color(0xFFDCE4DE),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFF006B3F),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    plan.isYearly ? '1 year' : '1 month',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF006B3F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
