import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_constants.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/custom_button.dart';
import '../models/shop_models.dart';
import '../shop_controller.dart';
import 'monthly_streak_protection_view.dart';

class StreakFreezeView extends GetView<ShopController> {
  const StreakFreezeView({super.key});

  Future<void> _openMonthlyManagement(
      StorePackageModel? package,
      ) async {
    await Get.to<void>(
          () => MonthlyStreakProtectionView(package: package),
    );

    await controller.refreshBalances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const _StoreTopBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'streak_freeze_store'.tr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                  color: AppColors.headerText,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                'protect_your_progress_in_italian'.tr,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppColors.bodyText,
                ),
              ),
              SizedBox(height: 24.h),
              const _InventoryCard(),
              SizedBox(height: 26.h),
              Obx(() {
                final List<StorePackageModel> finitePackages =
                controller.streakPackages
                    .where(
                      (StorePackageModel package) =>
                  !package.isUnlimitedStreak,
                )
                    .toList(growable: false);

                final List<StorePackageModel> monthlyPackages =
                controller.streakPackages
                    .where(
                      (StorePackageModel package) =>
                  package.isUnlimitedStreak,
                )
                    .toList(growable: false);

                if (finitePackages.isEmpty && monthlyPackages.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Center(
                      child: Text(
                        'no_streak_freeze_packages_are_available'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (finitePackages.isNotEmpty) ...<Widget>[
                      const _SectionTitle(
                        translationKey: 'one_time_streak_freezes',
                      ),
                      SizedBox(height: 12.h),
                      ...finitePackages.map(
                            (StorePackageModel package) => Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: _FreezePackCard(
                            package: package,
                            monthlyPurchaseBlocked: false,
                            monthlyProtectionActive: false,
                            monthlyProtectionExpiresAt: null,
                            onManageMonthlyPlan: null,
                          ),
                        ),
                      ),
                    ],
                    if (monthlyPackages.isNotEmpty) ...<Widget>[
                      if (finitePackages.isNotEmpty) SizedBox(height: 14.h),
                      const _SectionTitle(
                        translationKey: 'monthly_streak_protection',
                      ),
                      SizedBox(height: 12.h),
                      ...monthlyPackages.map(
                            (StorePackageModel package) {
                          final bool isActiveMonthly =
                          controller
                              .isActiveMonthlyStreakPackage(
                            package,
                          );

                          final bool purchaseBlocked =
                          controller.isMonthlyPurchaseBlocked(
                            package,
                          );

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: 14.h,
                            ),
                            child: _FreezePackCard(
                              package: package,

                              monthlyProtectionActive:
                              isActiveMonthly,

                              monthlyPurchaseBlocked:
                              purchaseBlocked,

                              monthlyProtectionExpiresAt:
                              isActiveMonthly
                                  ? controller
                                  .monthlyStreakProtectionExpiresAt
                                  : null,

                              onManageMonthlyPlan:
                              isActiveMonthly
                                  ? () =>
                                  _openMonthlyManagement(
                                    package,
                                  )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              }),
              SizedBox(height: 18.h),
              Obx(() {
                final StorePackageModel? selected =
                    controller.selectedStreakPackage;

                final bool manageActiveMonthly =
                    selected != null &&
                        controller
                            .isActiveMonthlyStreakPackage(
                          selected,
                        );

                final bool disabled =
                    controller.isLoadingQuote.value || selected == null;

                return CustomButton.primary(
                  text: controller.isLoadingQuote.value
                      ? 'loading'.tr
                      : manageActiveMonthly
                      ? 'manage_monthly_plan'.tr
                      : 'confirm_purchase'.tr,
                  icon: manageActiveMonthly
                      ? Icons.settings_rounded
                      : Icons.play_arrow_rounded,
                  onPressed: disabled
                      ? () {}
                      : manageActiveMonthly
                      ? () => _openMonthlyManagement(selected)
                      : controller.goToStreakFreezeOrderSummary,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.translationKey,
  });

  final String translationKey;

  @override
  Widget build(BuildContext context) {
    return Text(
      translationKey.tr,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: AppFont.font14.sp,
        fontWeight: FontWeight.w900,
        height: 1.25,
        letterSpacing: 0.7,
        color: AppColors.headerText,
      ),
    );
  }
}

class _StoreTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _StoreTopBar();

  @override
  Size get preferredSize => Size.fromHeight(82.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => Get.back<void>(),
                child: Container(
                  width: 44.r,
                  height: 44.r,
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
                    size: 22.r,
                    color: AppColors.blockSuccessBlueText,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'streak_freeze_refiller'.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    color: AppColors.blockSuccessBlueText,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(width: 44.r),
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
      constraints: BoxConstraints(minHeight: 120.h),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 18.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.blockSuccessBlueBg,
        borderRadius: BorderRadius.circular(kRadius30.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'your_inventory'.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    height: 1.25,
                    color: AppColors.blockSuccessBlueText,
                  ),
                ),
                SizedBox(height: 7.h),
                Obx(
                      () => Text(
                    'streak_freeze_balance'.trParams(
                      <String, String>{
                        'count': controller.streakFreezeBalance.toString(),
                      },
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      color: AppColors.blockSuccessBlueText,
                    ),
                  ),
                ),
                Obx(() {
                  if (!controller.hasActiveMonthlyStreakProtection) {
                    return const SizedBox.shrink();
                  }

                  final DateTime? expiresAt =
                      controller.monthlyStreakProtectionExpiresAt;

                  final String expiryText = expiresAt == null
                      ? 'monthly_protection_active'.tr
                      : 'protected_until'.trParams(
                    <String, String>{
                      'date': MaterialLocalizations.of(context)
                          .formatMediumDate(expiresAt.toLocal()),
                    },
                  );

                  return Padding(
                    padding: EdgeInsets.only(top: 7.h),
                    child: Text(
                      expiryText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.font12.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: AppColors.blockSuccessBlueText,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.10),
                  blurRadius: 15.r,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: Icon(
              Icons.ac_unit_rounded,
              size: 38.r,
              color: AppColors.blockSuccessBlueText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreezePackCard extends GetView<ShopController> {
  const _FreezePackCard({
    required this.package,
    required this.monthlyProtectionActive,
    required this.monthlyPurchaseBlocked,
    required this.monthlyProtectionExpiresAt,
    required this.onManageMonthlyPlan,
  });
  final bool monthlyPurchaseBlocked;
  final StorePackageModel package;
  final bool monthlyProtectionActive;
  final DateTime? monthlyProtectionExpiresAt;
  final VoidCallback? onManageMonthlyPlan;

  @override
  Widget build(BuildContext context) {
    final bool blockedMonthly =
        package.isUnlimitedStreak &&
            monthlyPurchaseBlocked;
    return Obx(() {
      final bool selected =
      controller.isStreakPackageSelected(package.id);

      final bool activeMonthly =
          package.isUnlimitedStreak && monthlyProtectionActive;

      final String description;

      if (
      package.description
          .trim()
          .isNotEmpty
      ) {
        description = package.description.tr;
      } else if (
      package.isUnlimitedStreak
      ) {
        description =
            'unlimited_streak_protection_description'
                .tr;
      } else {
        description =
            'streak_freeze_pack_count'
                .trParams(
              <String, String>{
                'count':
                package.streakFreezeCount
                    .toString(),
              },
            );
      }

      final String badge =
      activeMonthly
          ? 'active'
          : blockedMonthly
          ? 'monthly_plan_already_active_badge'
          : package.badgeLabel;

      return GestureDetector(
        onTap: activeMonthly
            ? onManageMonthlyPlan
            : blockedMonthly
            ? controller
            .showMonthlyPlanAlreadyActive
            : () =>
            controller.selectStreakPackage(
              package.id,
            ),
        child: Opacity(
          opacity:
          blockedMonthly ? 0.62 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 142.h),
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(26.r),
              border: Border.all(
                color: selected || activeMonthly
                    ? AppColors.blockSuccessBlueText
                    : AppColors.transparent,
                width: 2.5.w,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (badge.isNotEmpty) ...<Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 210.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blockSuccessBlueText,
                          borderRadius:
                          BorderRadius.circular(kRadius60.r),
                        ),
                        child: Text(
                          badge.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font12.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 56.w,
                      child: _PackIcon(package: package),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            package.name.tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              color: AppColors.headerText,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppFont.font13.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                              color: AppColors.bodyText,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          if (activeMonthly)
                            _ActiveMonthlyFooter(
                              expiresAt: monthlyProtectionExpiresAt,
                              onManage: onManageMonthlyPlan,
                            )
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    package.isUnlimitedStreak
                                        ? 'unlimited_protection'.tr
                                        : 'streak_freeze_pack_count'.trParams(
                                      <String, String>{
                                        'count': package.streakFreezeCount
                                            .toString(),
                                      },
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppFont.font12.sp,
                                      fontWeight: FontWeight.w800,
                                      color:
                                      AppColors.blockSuccessBlueText,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                _PackagePriceChip(
                                  package: package,
                                  selected: selected,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _PackagePriceChip
    extends GetView<ShopController> {
  const _PackagePriceChip({
    required this.package,
    required this.selected,
  });

  final StorePackageModel package;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 116.w,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 9.w,
          vertical: 7.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors
              .blockSuccessBlueBg
              : AppColors
              .scaffoldBackground,

          borderRadius:
          BorderRadius.circular(
            13.r,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,

          alignment:
          Alignment.centerRight,

          child: Text(
            controller.packagePriceText(
              package,
            ),

            maxLines: 1,

            style: TextStyle(
              fontSize: 14.sp,

              fontWeight:
              FontWeight.w900,

              height: 1.1,

              color: selected
                  ? AppColors
                  .blockSuccessBlueText
                  : AppColors.headerText,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveMonthlyFooter extends StatelessWidget {
  const _ActiveMonthlyFooter({
    required this.expiresAt,
    required this.onManage,
  });

  final DateTime? expiresAt;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final String statusText = expiresAt == null
        ? 'monthly_protection_active'.tr
        : 'protected_until'.trParams(
      <String, String>{
        'date': MaterialLocalizations.of(context)
            .formatMediumDate(expiresAt!.toLocal()),
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          statusText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppFont.font12.sp,
            fontWeight: FontWeight.w900,
            height: 1.3,
            color: AppColors.blockSuccessBlueText,
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onManage,
            icon: Icon(
              Icons.settings_rounded,
              size: 18.r,
            ),
            label: Text(
              'manage_monthly_plan'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blockSuccessBlueText,
              side: BorderSide(
                color: AppColors.blockSuccessBlueText,
                width: 1.4.w,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              textStyle: TextStyle(
                fontSize: AppFont.font12.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PackIcon extends StatelessWidget {
  const _PackIcon({
    required this.package,
  });

  final StorePackageModel package;

  @override
  Widget build(BuildContext context) {
    if (package.isUnlimitedStreak) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.ac_unit_rounded,
            size: 28.r,
            color: AppColors.blockSuccessBlueText,
          ),
          Text(
            '∞',
            style: TextStyle(
              fontSize: 27.sp,
              fontWeight: FontWeight.w900,
              height: 0.8,
              color: AppColors.blockSuccessBlueText,
            ),
          ),
        ],
      );
    }

    final int count = package.streakFreezeCount;

    if (count > 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.ac_unit_rounded,
            size: 30.r,
            color: AppColors.blockSuccessBlueText,
          ),
          SizedBox(height: 2.h),
          Text(
            '×$count',
            maxLines: 1,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.blockSuccessBlueText,
            ),
          ),
        ],
      );
    }

    final int visibleCount = count.clamp(1, 3);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2.w,
      runSpacing: 2.h,
      children: List<Widget>.generate(
        visibleCount,
            (_) => Icon(
          Icons.ac_unit_rounded,
          size: 24.r,
          color: AppColors.blockSuccessBlueText,
        ),
      ),
    );
  }
}
