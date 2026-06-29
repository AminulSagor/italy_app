import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'shop_controller.dart';
import '../../../../../core/widgets/widgets.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: SimpleAppbar(
        onBackTap: () => Navigator.pop(context),
        title: 'gen_shop'.tr.tr,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //_ShopHeader(onBackTap: () => Navigator.pop(context)),
              //SizedBox(height: 34.h),
              GestureDetector(
                onTap: controller.onRefillCreditTap,
                child: const _RefillCreditCard(),
              ),

              SizedBox(height: 32.h),

              _CvCreditPackCard(onTap: controller.onCvCreditTap),

              SizedBox(height: 32.h),

              _StreakFreezeCard(onTap: controller.onStreakFreezeTap),

              SizedBox(height: 36.h),

              Text(
                'CURRENT BALANCE',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  color: const Color(0xFF5B5B5B),
                ),
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _BalanceCard(
                      icon: Icons.view_in_ar_outlined,
                      title: 'gen_tokens'.tr.tr,
                      value: '1,240',
                      bgColor: const Color(0xFFFFF4E9),
                      borderColor: const Color(0xFFFF9D55),
                      iconColor: const Color(0xFFFF6D1A),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: _BalanceCard(
                      icon: Icons.mic_none_rounded,
                      title: 'gen_minutes'.tr.tr,
                      value: '45m',
                      bgColor: const Color(0xFFEFFFF7),
                      borderColor: const Color(0xFF20E5A2),
                      iconColor: const Color(0xFF15BD86),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: _BalanceCard(
                      icon: Icons.ac_unit_rounded,
                      title: 'gen_streak_nfreezes'.tr.tr,
                      value: '3×',
                      bgColor: const Color(0xFFE8F5FF),
                      borderColor: const Color(0xFF91CFFF),
                      iconColor: const Color(0xFF0066A8),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              const _CvBalanceCard(),

              SizedBox(height: 32.h),

              _OrderHistoryCard(onTap: controller.onOrderHistoryTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefillCreditCard extends StatelessWidget {
  const _RefillCreditCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 152.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B8600), Color(0xFF1F6900)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B8600).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refill AI Credits',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Buy more minutes &\ntokens',
                  style: TextStyle(
                    fontSize: 17.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 42.r,
              color: const Color(0xFFC9FFAA),
            ),
          ),
        ],
      ),
    );
  }
}

class _CvCreditPackCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CvCreditPackCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 22.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1DA),
          borderRadius: BorderRadius.circular(42.r),
          border: Border.all(color: const Color(0xFFF1D19D)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/icons_png/wingmail.png'),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CV Credit Pack',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A4E00),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Generate and export professional resumes.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF616161),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '€0.99 for 1 • €2.99 for 5',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFA76500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            CustomButton(
              height: 50.h,
              text: 'BUY NOW',
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              btnColor: const Color(0xFFA76500),
              textColor: Colors.white,
              onPressed: onTap,
              borderColor: Colors.transparent,
            ),
            // _BuyNowButton(
            //   textColor: Colors.white,
            //   bgColor: const Color(0xFFA76500),
            //   onTap: onTap,
            // ),
          ],
        ),
      ),
    );
  }
}

class _StreakFreezeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StreakFreezeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 34.h, 32.w, 30.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF5DABE3), Color(0xFF86C4F6)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42.w,
            bottom: -62.h,
            child: Icon(
              Icons.ac_unit_rounded,
              size: 150.r,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.ac_unit_rounded,
                      size: 25.r,
                      color: const Color(0xFF0066A8),
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy Streak\nFreeze',
                        style: TextStyle(
                          fontSize: 25.sp,
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '€0.99 / each',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              _BuyNowButton(
                textColor: const Color(0xFF0066A8),
                bgColor: Colors.white,
                onTap: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuyNowButton extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _BuyNowButton({
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          'BUY NOW',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;

  const _BalanceCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28.r, color: iconColor),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5B5B5B),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 27.sp,
              fontWeight: FontWeight.w900,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CvBalanceCard extends StatelessWidget {
  const _CvBalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEED5),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFD9963C)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 28.r,
            color: const Color(0xFFA76500),
          ),
          SizedBox(height: 16.h),
          Text(
            'CV CREDITS',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '1,240',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF8A4E00),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _OrderHistoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(32.w, 32.h, 32.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(44.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order History',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'View your past purchases',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5E5E5E),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7F4FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 34.r,
                    color: const Color(0xFF0070B8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            Container(
              height: 128.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB894),
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.18,
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 96.r,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  Positioned(
                    right: 48.w,
                    child: Transform.rotate(
                      angle: 0.18,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 104.r,
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
