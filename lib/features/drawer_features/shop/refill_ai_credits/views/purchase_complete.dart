import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/themes/app_colors.dart';
import 'package:italir_pothe/core/widgets/widgets.dart';
import '../../models/shop_models.dart';
import '../../shop_controller.dart';
import 'package:material_symbols_icons/symbols.dart';

class PurchaseCompletedPage extends StatelessWidget {
  const PurchaseCompletedPage({super.key});

  static const Color bg = AppColors.scaffoldBackground;
  static const Color green = AppColors.primaryGreen;
  static const Color darkGreen = AppColors.primaryBtnShadow;
  static const Color textDark = AppColors.black;
  static const Color muted = AppColors.bodyText;
  static const Color blueCard = Color(0xFFAED0FA);
  static const Color orangeCard = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final ShopController controller = Get.find<ShopController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: SimpleAppbar(
        onBackTap: () => Get.back(),
        title: 'Purchase Completed',
        icon: Icons.close,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
                child: Column(
                  children: [
                    // _topBar(),
                    SizedBox(height: 42.h),

                    _successIcon(),

                    SizedBox(height: 36.h),

                    Text(
                      'Congratulations!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textDark,
                        fontSize: 31.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                        height: 1.05,
                      ),
                    ),

                    SizedBox(height: 18.h),

                    Obx(
                      () => Text(
                        controller.completedMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF656565),
                          fontSize: 16.sp,
                          height: 1.48,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),

                    SizedBox(height: 42.h),

                    Obx(() {
                      final StorePackageType? packageType =
                          controller.completedPurchase.value?.packageType;
                      return Row(
                        children: [
                          Expanded(
                            child: _creditCard(
                              bgColor: blueCard,
                              icon: _firstCompletionIcon(packageType),
                              iconColor: const Color(0xFF006BAA),
                              value: controller.completionFirstValue,
                              label: controller.completionFirstLabel,
                              textColor: const Color(0xFF075D97),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _creditCard(
                              bgColor: orangeCard,
                              icon: _secondCompletionIcon(packageType),
                              iconColor: const Color(0xFF9A5A00),
                              value: controller.completionSecondValue,
                              label: controller.completionSecondLabel,
                              textColor: const Color(0xFF3A3434),
                            ),
                          ),
                        ],
                      );
                    }),

                    SizedBox(height: 42.h),

                    Obx(
                      () => _orderStatusBox(
                        orderId: controller.completedOrderId,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 30.h),
              child: CustomButton.primary(
                text: 'Start Learning Now',
                icon: Icons.arrow_forward,
                onPressed: controller.startLearningNow,
                btnColor: green,
                btnShadowColor: darkGreen,
                borderColor: green,
                borderRadius: 30.r,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return SizedBox(
      height: 32.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Icons.close,
                color: const Color(0xFF5F6368),
                size: 25.r,
              ),
            ),
          ),
          Text(
            'Purchase Completed',
            style: TextStyle(
              color: green,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _successIcon() {
    return Container(
      height: 168.r,
      width: 168.r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(44.r),
        border: Border.all(color: const Color(0xFF69EA3A), width: 3.5.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF69EA3A).withValues(alpha: .28),
            blurRadius: 42.r,
            spreadRadius: 10.r,
          ),
        ],
      ),
      child: Center(
        child: Image.asset('assets/icons_png/Container (1).png'),
        // child: Stack(
        //   alignment: Alignment.center,
        //   children: [
        //     Icon(Icons.settings, color: green, size: 66.r),
        //     Icon(Icons.check, color: Colors.white, size: 31.r),
        //   ],
        // ),
      ),
    );
  }

  Widget _creditCard({
    required Color bgColor,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color textColor,
  }) {
    return Container(
      height: 151.h,
      padding: EdgeInsets.fromLTRB(22.w, 22.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38.r,
            width: 38.r,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.r),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 30.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor.withValues(alpha: .78),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderStatusBox({required String orderId}) {
    return Container(
      height: 84.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: const Color(0xFFDCDCDC), width: 1.5.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: _orderInfo(label: 'ORDER ID', value: orderId),
          ),
          Container(height: 34.h, width: 1.w, color: const Color(0xFFE1E1E1)),
          SizedBox(width: 12.w),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4.r, backgroundColor: green),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'Status: Completed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderInfo({required String label, required String value}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF6B6B6B),
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textDark,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: .4,
          ),
        ),
      ],
    );
  }

  IconData _firstCompletionIcon(StorePackageType? packageType) {
    switch (packageType) {
      case StorePackageType.aiBundle:
        return Icons.mic;
      case StorePackageType.streakFreeze:
        return Icons.ac_unit_rounded;
      case StorePackageType.cvCredit:
        return Icons.description_outlined;
      case null:
        return Icons.check_rounded;
    }
  }

  IconData _secondCompletionIcon(StorePackageType? packageType) {
    switch (packageType) {
      case StorePackageType.aiBundle:
        return Symbols.deployed_code;
      case StorePackageType.streakFreeze:
        return Icons.inventory_2_outlined;
      case StorePackageType.cvCredit:
        return Icons.account_balance_wallet_outlined;
      case null:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
