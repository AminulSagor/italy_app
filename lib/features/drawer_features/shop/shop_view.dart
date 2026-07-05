import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/widgets/widgets.dart';
import '_widgets/shop_home_widgets.dart';
import 'models/shop_models.dart';
import 'shop_controller.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: SimpleAppbar(
        onBackTap: () {
          controller.prepareForShopExit();
          Navigator.pop(context);
        },
        title: 'gen_shop'.tr,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingShop.value && controller.shop.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.shopError.value.isNotEmpty &&
              controller.shop.value == null) {
            return ShopErrorView(
              message: controller.shopError.value,
              onRetry: controller.loadShop,
            );
          }

          final StoreShopSectionModel? ai = controller.sectionFor(
            StorePackageType.aiBundle,
          );
          final StoreShopSectionModel? cv = controller.sectionFor(
            StorePackageType.cvCredit,
          );
          final StoreShopSectionModel? streak = controller.sectionFor(
            StorePackageType.streakFreeze,
          );

          return RefreshIndicator(
            onRefresh: controller.loadShop,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: controller.onRefillCreditTap,
                    child: ShopRefillCreditCard(
                      title: ai?.title ?? 'refill_ai_credits'.tr,
                      subtitle: ai?.subtitle ?? 'buy_more_minutes_and_tokens'.tr,
                      priceText: _startingPrice(ai),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ShopCvCreditPackCard(
                    onTap: controller.onCvCreditTap,
                    title: cv?.title ?? 'cv_credit_pack'.tr,
                    subtitle:
                        cv?.subtitle ??
                        'Generate and export professional resumes.',
                    priceText: _startingPrice(cv),
                  ),
                  SizedBox(height: 32.h),
                  ShopStreakFreezeCard(
                    onTap: controller.onStreakFreezeTap,
                    title: streak?.title ?? 'buy_streak_freeze'.tr,
                    priceText: _startingPrice(streak),
                  ),
                  SizedBox(height: 36.h),
                  Text(
                    'current_balance'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                      color: const Color(0xFF5B5B5B),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ShopBalanceCard(
                          icon: Icons.view_in_ar_outlined,
                          title: 'gen_tokens'.tr,
                          value: _compact(controller.aiTextTokens),
                          bgColor: const Color(0xFFFFF4E9),
                          borderColor: const Color(0xFFFF9D55),
                          iconColor: const Color(0xFFFF6D1A),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: ShopBalanceCard(
                          icon: Icons.mic_none_rounded,
                          title: 'gen_minutes'.tr,
                          value: '${controller.aiVoiceMinutes}m',
                          bgColor: const Color(0xFFEFFFF7),
                          borderColor: const Color(0xFF20E5A2),
                          iconColor: const Color(0xFF15BD86),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: ShopBalanceCard(
                          icon: Icons.ac_unit_rounded,
                          title: 'gen_streak_nfreezes'.tr,
                          value: '${controller.streakFreezeBalance}×',
                          bgColor: const Color(0xFFE8F5FF),
                          borderColor: const Color(0xFF91CFFF),
                          iconColor: const Color(0xFF0066A8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ShopCvBalanceCard(value: controller.cvCreditBalance),
                  SizedBox(height: 32.h),
                  ShopOrderHistoryCard(onTap: controller.onOrderHistoryTap),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _startingPrice(StoreShopSectionModel? section) {
    final double? price = section?.startingPriceEur;
    return price == null ? 'view_packages'.tr : '€${price.toStringAsFixed(2)}';
  }

  String _compact(int value) {
    if (value < 1000) return value.toString();
    if (value % 1000 == 0) return '${value ~/ 1000}k';
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
}
