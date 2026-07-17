import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/custom_button.dart';
import '../models/shop_models.dart';
import '../shop_controller.dart';

class MonthlyStreakProtectionView extends StatefulWidget {
  const MonthlyStreakProtectionView({
    super.key,
    required this.package,
  });

  final StorePackageModel? package;

  @override
  State<MonthlyStreakProtectionView> createState() =>
      _MonthlyStreakProtectionViewState();
}

class _MonthlyStreakProtectionViewState
    extends State<MonthlyStreakProtectionView>
    with WidgetsBindingObserver {
  static const String _androidPackageName =
      'com.shafacode.italir_pothe';

  late final ShopController _controller;
  bool _openingGooglePlay = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShopController>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.refreshBalances();
    }
  }

  Future<void> _openGooglePlaySubscription() async {
    if (_openingGooglePlay) return;

    setState(() => _openingGooglePlay = true);

    try {
      final String productId =
          widget.package?.storeProduct?.productId.trim() ?? '';

      final Map<String, String> queryParameters = <String, String>{
        'package': _androidPackageName,
        if (productId.isNotEmpty) 'sku': productId,
      };

      final Uri specificUri = Uri.https(
        'play.google.com',
        '/store/account/subscriptions',
        queryParameters,
      );

      bool opened = await launchUrl(
        specificUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        opened = await launchUrl(
          Uri.parse(
            'https://play.google.com/store/account/subscriptions',
          ),
          mode: LaunchMode.externalApplication,
        );
      }

      if (!opened) {
        Get.snackbar(
          'unable_to_open_google_play'.tr,
          'open_google_play_subscriptions_manually'.tr,
        );
      }
    } catch (_) {
      Get.snackbar(
        'unable_to_open_google_play'.tr,
        'open_google_play_subscriptions_manually'.tr,
      );
    } finally {
      if (mounted) {
        setState(() => _openingGooglePlay = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.scaffoldBackground,
        foregroundColor: AppColors.blockSuccessBlueText,
        centerTitle: true,
        title: Text(
          'monthly_streak_protection'.tr,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final bool active =
              _controller.hasActiveMonthlyStreakProtection;

          final DateTime? expiresAt =
              _controller.monthlyStreakProtectionExpiresAt;

          final String expiryText = expiresAt == null
              ? 'expiry_date_not_available'.tr
              : MaterialLocalizations.of(context)
                  .formatMediumDate(expiresAt.toLocal());

          return RefreshIndicator(
            onRefresh: _controller.refreshBalances,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 34.h),
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(22.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 86.r,
                          height: 86.r,
                          decoration: BoxDecoration(
                            color: AppColors.blockSuccessBlueBg,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.ac_unit_rounded,
                                size: 34.r,
                                color: AppColors.blockSuccessBlueText,
                              ),
                              Text(
                                '∞',
                                style: TextStyle(
                                  fontSize: 31.sp,
                                  height: 0.75,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.blockSuccessBlueText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.blockSuccessBlueBg
                                : AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Text(
                            active
                                ? 'monthly_protection_active'.tr
                                : 'monthly_protection_inactive'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppFont.font12.sp,
                              fontWeight: FontWeight.w900,
                              color: active
                                  ? AppColors.blockSuccessBlueText
                                  : AppColors.bodyText,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          widget.package?.name.tr ??
                              'monthly_streak_protection'.tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 23.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            color: AppColors.headerText,
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          'monthly_protection_page_description'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font14.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            color: AppColors.bodyText,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 15.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blockSuccessBlueBg,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                'protected_until_label'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: AppFont.font12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.bodyText,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                active
                                    ? expiryText
                                    : 'not_currently_protected'.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.blockSuccessBlueText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info_outline_rounded,
                          size: 22.r,
                          color: AppColors.blockSuccessBlueText,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'monthly_cancellation_information'.tr,
                            style: TextStyle(
                              fontSize: AppFont.font13.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: AppColors.bodyText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CustomButton.primary(
                    text: _openingGooglePlay
                        ? 'opening_google_play'.tr
                        : 'manage_or_cancel_google_play'.tr,
                    icon: Icons.open_in_new_rounded,
                    onPressed: _openingGooglePlay
                        ? () {}
                        : _openGooglePlaySubscription,
                  ),
                  SizedBox(height: 13.h),
                  Text(
                    'google_play_handles_subscription_changes'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
