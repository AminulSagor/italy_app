import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/widgets.dart';
import 'package:get/get.dart';

class ShopErrorView extends StatelessWidget {
  const ShopErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            FilledButton(onPressed: onRetry, child: Text('try_again'.tr)),
          ],
        ),
      ),
    );
  }
}

class ShopRefillCreditCard extends StatelessWidget {
  const ShopRefillCreditCard({
    required this.title,
    required this.subtitle,
    required this.priceText,
  });

  final String title;
  final String subtitle;
  final String priceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44.r),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF2B8600), Color(0xFF1F6900)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF2B8600).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFC9FFAA),
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

class ShopCvCreditPackCard extends StatelessWidget {
  const ShopCvCreditPackCard({
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.priceText,
  });

  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final String priceText;

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
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A4E00),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF616161),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        priceText,
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
              text: 'buy_now'.tr,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              btnColor: const Color(0xFFA76500),
              textColor: Colors.white,
              onPressed: onTap,
              borderColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class ShopStreakFreezeCard extends StatelessWidget {
  const ShopStreakFreezeCard({
    required this.onTap,
    required this.title,
    required this.priceText,
  });

  final VoidCallback onTap;
  final String title;
  final String priceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 216),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 34.h, 32.w, 30.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44.r),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF5DABE3), Color(0xFF86C4F6)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 25.sp,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _ShopBuyNowButton(
            textColor: const Color(0xFF0066A8),
            bgColor: Colors.white,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _ShopBuyNowButton extends StatelessWidget {
  const _ShopBuyNowButton({
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

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
          'buy_now'.tr,
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

class ShopBalanceCard extends StatelessWidget {
  const ShopBalanceCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 164),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 28.r, color: iconColor),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5B5B5B),
            ),
          ),
          SizedBox(height: 12.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppFont.font26.sp,
                fontWeight: FontWeight.w900,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShopCvBalanceCard extends StatelessWidget {
  const ShopCvBalanceCard({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 144),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEED5),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFD9963C)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.article_outlined,
            size: 28.r,
            color: const Color(0xFFA76500),
          ),
          SizedBox(height: 16.h),
          Text(
            'cv_credits'.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value.toString(),
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

class ShopOrderHistoryCard extends StatelessWidget {
  const ShopOrderHistoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(32.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(44.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'order_history'.tr,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'view_your_past_purchases'.tr,
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
      ),
    );
  }
}
