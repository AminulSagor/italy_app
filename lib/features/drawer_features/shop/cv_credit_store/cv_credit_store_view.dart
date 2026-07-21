import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/shop_models.dart';
import '../shop_controller.dart';

class CvCreditStoreView extends GetView<ShopController> {
  const CvCreditStoreView({super.key});

  static const Color _background = Color(0xFFF7F7F7);
  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: const _TopBar(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 330.w),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'cv_credit_store'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28.sp,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                                color: _text,
                                letterSpacing: -0.6,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'never_pause_your_career_growth'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const _InventoryCard(),
                    SizedBox(height: 24.h),
                    Text(
                      'choose_package'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Obx(() {
                      final bool isInitialLoading =
                          controller.isLoadingShop.value &&
                              controller.cvPackages.isEmpty;

                      if (isInitialLoading) {
                        return const _PackagesLoadingState();
                      }

                      if (controller.cvPackages.isEmpty) {
                        return _EmptyPackagesState(
                          message:
                          'no_cv_credit_packages_are_available'.tr,
                        );
                      }

                      return Column(
                        children: controller.cvPackages
                            .map(
                              (StorePackageModel offer) =>
                              Padding(
                                padding:
                                EdgeInsets.only(bottom: 12.h),
                                child: _CvCreditOfferCard(
                                  offer: offer,
                                ),
                              ),
                        )
                            .toList(growable: false),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16.r,
                offset: Offset(0, -4.h),
              ),
            ],
          ),
          child: Obx(
                () => _ConfirmButton(
              isLoading:
              controller.isLoadingShop.value ||
                  controller.isLoadingQuote.value,
              isEnabled:
              !controller.isLoadingShop.value &&
                  controller.cvPackages.isNotEmpty,
              onTap:
              controller.goToCvCreditOrderSummary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  static const Color _brown = Color(0xFF9B5B00);
  static const Color _blue = Color(0xFF005A94);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: Get.back,
              child: SizedBox(
                width: 42.r,
                height: 42.r,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22.r,
                  color: _blue,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'cv_credit_refiller'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _brown,
                letterSpacing: -0.2,
              ),
            ),
          ),
          SizedBox(width: 42.r),
        ],
      ),
    );
  }
}

class _InventoryCard
    extends GetView<ShopController> {
  const _InventoryCard();

  static const Color _brown =
  Color(0xFF9B5B00);

  static const Color _cream =
  Color(0xFFFFF2DA);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int freeRemaining =
          controller
              .freeCvGenerationsRemaining;

      final int paidCredits =
          controller.cvCreditBalance;

      final bool freeEnded =
          freeRemaining <= 0;

      return Container(
        width: double.infinity,

        padding: EdgeInsets.all(18.r),

        decoration: BoxDecoration(
          color: _cream,

          borderRadius:
          BorderRadius.circular(20.r),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 52.r,
                  height: 52.r,

                  decoration:
                  const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.history_edu_rounded,
                    size: 26.r,
                    color: _brown,
                  ),
                ),

                SizedBox(width: 14.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: <Widget>[
                      Text(
                        'your_cv_allowance'.tr,

                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing: 0.8,
                          color: _brown,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        freeEnded
                            ? 'cv_free_limit_ended'
                            .tr
                            : 'cv_free_creations_remaining'
                            .trParams(
                          <String, String>{
                            'count':
                            freeRemaining
                                .toString(),
                          },
                        ),

                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 20.sp,
                          height: 1.15,
                          fontWeight:
                          FontWeight.w800,
                          color: _brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            Container(
              width: double.infinity,

              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),

              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: 0.72),

                borderRadius:
                BorderRadius.circular(16.r),
              ),

              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 20.r,
                    color: _brown,
                  ),

                  SizedBox(width: 9.w),

                  Expanded(
                    child: Text(
                      'cv_paid_credit_balance'
                          .trParams(
                        <String, String>{
                          'count':
                          paidCredits.toString(),
                        },
                      ),

                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                        FontWeight.w700,
                        color: _brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (freeEnded) ...<Widget>[
              SizedBox(height: 12.h),

              Text(
                paidCredits > 0
                    ? 'cv_next_creation_uses_credit'
                    .tr
                    : 'cv_purchase_credit_to_continue'
                    .tr,

                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: _brown,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _CvCreditOfferCard extends GetView<ShopController> {
  const _CvCreditOfferCard({required this.offer});

  final StorePackageModel offer;

  static const Color _brown = Color(0xFF9B5B00);
  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF666666);
  static const Color _cream = Color(0xFFFFF2DA);
  static const Color _border = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool selected = controller.isCvPackageSelected(offer.id);
      final bool hasBadge = offer.badgeLabel.trim().isNotEmpty;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => controller.selectCvPackage(offer.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: selected ? _cream.withValues(alpha: 0.45) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: selected ? _brown : _border,
                width: selected ? 1.8.w : 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (hasBadge) ...<Widget>[
                  _PackageBadge(label: offer.badgeLabel.tr, selected: selected),
                  SizedBox(height: 10.h),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: selected ? _cream : const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        offer.isMonthly
                            ? Icons.all_inclusive_rounded
                            : Icons.history_edu_rounded,
                        size: 24.r,
                        color: _brown,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            offer.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17.sp,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            offer.entitlementSummary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    _SelectionIndicator(selected: selected),
                  ],
                ),
                SizedBox(height: 14.h),
                const Divider(height: 1, color: _border),
                SizedBox(height: 12.h),
                Row(
                  children: <Widget>[
                    Text(
                      offer.isMonthly
                          ? 'monthly_subscription'.tr
                          : 'one_time_purchase'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        controller.packagePriceText(offer),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 18.sp,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: selected ? _brown : _text,
                        ),
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

class _PackageBadge extends StatelessWidget {
  const _PackageBadge({required this.label, required this.selected});

  final String label;
  final bool selected;

  static const Color _brown = Color(0xFF9B5B00);
  static const Color _cream = Color(0xFFFFF2DA);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: selected ? _brown : _cream,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: selected ? Colors.white : _brown,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  static const Color _brown = Color(0xFF9B5B00);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24.r,
      height: 24.r,
      decoration: BoxDecoration(
        color: selected ? _brown : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _brown : const Color(0xFFB8B8B8),
          width: 1.5.w,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
          : null,
    );
  }
}

class _PackagesLoadingState
    extends StatelessWidget {
  const _PackagesLoadingState();

  static const Color _brown =
  Color(0xFF9B5B00);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 180.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 28.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20.r,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 34.r,
          height: 34.r,
          child:
          const CircularProgressIndicator(
            strokeWidth: 3,
            color: _brown,
          ),
        ),
      ),
    );
  }
}

class _EmptyPackagesState extends StatelessWidget {
  const _EmptyPackagesState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.inventory_2_outlined,
            size: 34.r,
            color: const Color(0xFF888888),
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.onTap,
    required this.isLoading,
    required this.isEnabled,
  });

  final VoidCallback onTap;
  final bool isLoading;
  final bool isEnabled;

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onTap : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _green,
          disabledBackgroundColor: _green.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isLoading
              ? SizedBox(
            key: const ValueKey<String>('loading'),
            width: 22.r,
            height: 22.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : Row(
            key: const ValueKey<String>('label'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'confirm_purchase'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.arrow_forward_rounded, size: 20.r),
            ],
          ),
        ),
      ),
    );
  }
}
