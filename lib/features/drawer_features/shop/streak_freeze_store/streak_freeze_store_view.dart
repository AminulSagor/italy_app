import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:italir_pothe/core/themes/app_colors.dart';
import 'package:italir_pothe/core/themes/app_constants.dart';
import 'package:italir_pothe/core/themes/app_font.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
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
                'Streak Freeze Store',
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
                  'Protect your progress in Italian',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: AppColors.bodyText,
                  ),
                ),
              ),
              SizedBox(height: 33.h),
              const _InventoryCard(),
              SizedBox(height: 32.h),
              const _FreezePackCard(
                pack: StreakFreezePackTitles.singleFreezeTitle,
              ),
              SizedBox(height: 15.h),
              const _FreezePackCard(
                pack: StreakFreezePackTitles.tripleProtectionTitle,
              ),
              SizedBox(height: 15.h),
              const _FreezePackCard(
                pack: StreakFreezePackTitles.unlimitedMonthlyShieldTitle,
              ),
              SizedBox(height: 65.h),
              CustomButton.primary(
                text: 'Confirm Purchase',
                icon: Icons.play_arrow_rounded,
                onPressed: controller.goToStreakFreezeOrderSummary,
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
                'Streak Freeze Refiller',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.blockSuccessBlueText,
                  letterSpacing: -0.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
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
                  'YOUR INVENTORY',
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.blockSuccessBlueText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Freezes: 2',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: -0.4,
                    color: AppColors.blockSuccessBlueText,
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
          SizedBox(width: 10.w),
        ],
      ),
    );
  }
}

class _FreezePackCard extends GetView<ShopController> {
  final String pack;

  const _FreezePackCard({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String selectedPack = controller.selectedStreakFreezePack.value;
      final bool selected = selectedPack == pack;
      final String badge = controller.streakFreezePackBadge(pack);

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          GestureDetector(
            onTap: () => controller.selectStreakFreezePack(pack),
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
                    child: _PackIcon(pack: pack, selected: selected),
                  ),
                  SizedBox(width: 22.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _displayTitle(pack),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font20.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.28,
                            letterSpacing: -0.35,
                            color: AppColors.headerText,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          controller.streakFreezePackSubtitle(pack),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font13.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            color: AppColors.bodyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  _PackPrice(pack: pack, selected: selected),
                ],
              ),
            ),
          ),
          if (selected && badge.isNotEmpty)
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
                  badge.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  String _displayTitle(String value) {
    if (pack == StreakFreezePackTitles.tripleProtectionTitle) {
      return value.replaceAll(' (3x)', '\n(3x)');
    }
    if (pack == StreakFreezePackTitles.unlimitedMonthlyShieldTitle) {
      return value.replaceFirst('Unlimited ', 'Unlimited\n');
    }
    return value.replaceFirst(' ', '\n');
  }
}

class _PackIcon extends StatelessWidget {
  final String pack;
  final bool selected;

  const _PackIcon({required this.pack, required this.selected});

  @override
  Widget build(BuildContext context) {
    if (pack == StreakFreezePackTitles.tripleProtectionTitle) {
      return SizedBox(
        width: 67.w,
        height: 54.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 22.w,
              top: 0,
              child: _Snowflake(size: 33.r),
            ),
            Positioned(
              left: 0,
              top: 22.h,
              child: _Snowflake(size: 28.r),
            ),
            Positioned(
              right: 0,
              top: 24.h,
              child: _Snowflake(size: 30.r),
            ),
          ],
        ),
      );
    }

    if (pack == StreakFreezePackTitles.unlimitedMonthlyShieldTitle) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _Snowflake(size: 31.r),
          Transform.translate(
            offset: Offset(0, -2.h),
            child: Text(
              '∞',
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.w900,
                height: 0.72,
                color: AppColors.blockSuccessBlueText,
              ),
            ),
          ),
        ],
      );
    }

    return Center(child: _Snowflake(size: 31.r));
  }
}

class _Snowflake extends StatelessWidget {
  final double size;

  const _Snowflake({required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.ac_unit_rounded,
      size: size,
      color: AppColors.blockSuccessBlueText,
    );
  }
}

class _PackPrice extends GetView<ShopController> {
  final String pack;
  final bool selected;

  const _PackPrice({required this.pack, required this.selected});

  @override
  Widget build(BuildContext context) {
    final String price = controller.formatPrice(
      controller.streakFreezePackPriceValue(pack),
    );
    final bool monthly =
        pack == StreakFreezePackTitles.unlimitedMonthlyShieldTitle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          price,
          style: TextStyle(
            fontSize: monthly ? AppFont.font20.sp : AppFont.font22.sp,
            fontWeight: FontWeight.w900,
            height: 1,
            color: selected
                ? AppColors.blockSuccessBlueText
                : AppColors.headerText,
          ),
        ),
        if (monthly)
          Text(
            '/mo',
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.bodyText,
            ),
          ),
      ],
    );
  }
}
