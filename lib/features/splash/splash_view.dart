import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/themes/app_theme.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  static const List<String> _splashHeaderImages = <String>[
    'assets/decor_png/splash-1.png',
    'assets/decor_png/splash-2.png',
    'assets/decor_png/splash-3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: <Widget>[
              PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: <Widget>[
                  _buildWelcomePage(context, controller),
                  _buildOnboardingPage(
                    context: context,
                    index: 1,
                    title: 'splash_slide_1_title'.tr,
                    highlight: 'splash_slide_1_highlight'.tr,
                    titleSuffix: 'splash_slide_1_suffix'.tr,
                    description: 'splash_slide_1_desc'.tr,
                  ),
                  _buildOnboardingPage(
                    context: context,
                    index: 2,
                    title: 'splash_slide_2_title'.tr,
                    highlight: 'splash_slide_2_highlight'.tr,
                    titleSuffix: 'splash_slide_2_suffix'.tr,
                    description: 'splash_slide_2_desc'.tr,
                  ),
                  _buildOnboardingPage(
                    context: context,
                    index: 3,
                    title: 'splash_slide_3_title'.tr,
                    highlight: 'splash_slide_3_highlight'.tr,
                    titleSuffix: 'splash_slide_3_suffix'.tr,
                    description: 'splash_slide_3_desc'.tr,
                  ),
                ],
              ),

              if (!controller.isFirstPage && !controller.isLastPage)
                Positioned(
                  top: 8.h,
                  right: 18.w,
                  child: TextButton(
                    onPressed: controller.onSkipTap,
                    child: Text(
                      'skip'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        fontSize: 12.sp,
                        color: AppTheme.splashSkipText,
                      ),
                    ),
                  ),
                ),

              if (!controller.isFirstPage)
                Positioned(
                  left: 24.w,
                  right: 24.w,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    minimum: EdgeInsets.only(bottom: 32.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildPageIndicator(
                          context,
                          controller.currentPage.value,
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: controller.onPrimaryButtonTap,
                            style: ElevatedButton.styleFrom(
                              elevation: 10,
                              shadowColor: AppTheme.primaryGreen.withAlpha(140),
                              backgroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.isLastPage
                                      ? 'get_started'.tr
                                      : 'next'.tr,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.white,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (controller.isLastPage)
                          TextButton(
                            onPressed: controller.onAlreadyHaveAccountTap,
                            child: Text(
                              'already_have_account_lower'.tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.splashSecondaryActionText,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // WELCOME PAGE
  // =========================================================

  Widget _buildWelcomePage(BuildContext context, SplashController controller) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.splashWelcomeGradient),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
      child: Column(
        children: <Widget>[
          SizedBox(height: 56.h),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -30.h,
                left: 120.w,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Color.fromARGB(255, 73, 227, 26),
                          blurRadius: 150,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 13.r,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Icon(
                      Icons.language,
                      color: AppTheme.white,
                      size: 14.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'app_name'.tr,
                    style: AppTheme.brandHeaderStyle.copyWith(
                      fontSize: 22.sp,
                      height: 1,
                      letterSpacing: 0,
                      color: AppTheme.splashBrandText,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          Text(
            'splash_title_line1'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              height: 1.12,
              color: AppTheme.splashTextPrimary,
            ),
          ),

          Text(
            'splash_title_line2'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.primaryGreen,
            ),
          ),

          SizedBox(height: 26.h),

          Align(
            child: Container(
              width: 263.w,
              height: 142.h,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppTheme.splashChipContainer,
                borderRadius: BorderRadius.circular(42.r),
                border: Border.all(color: AppTheme.splashChipBorder),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x10000000),
                    offset: Offset(0, 3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Legacy implementation kept for quick revert.
                  // _ServiceChip(
                  //   icon: Icons.menu_book,
                  //   label: 'splash_service_italian'.tr,
                  //   active: true,
                  // ),
                  // _ServiceChip(
                  //   icon: Icons.gavel,
                  //   label: 'splash_service_caf'.tr,
                  //   iconColor: AppTheme.splashChipCafIcon,
                  // ),
                  // _ServiceChip(
                  //   icon: Icons.work,
                  //   label: 'splash_service_cv'.tr,
                  //   iconColor: AppTheme.splashChipCvIcon,
                  // ),
                  _ServiceChipHighlighted(
                    icon: Icons.menu_book,
                    label: 'splash_service_italian'.tr,
                    iconColor: AppTheme.splashChipActiveIcon,
                    iconBackground: AppTheme.splashChipActiveBg,
                  ),
                  _ServiceChipPlain(
                    icon: Icons.gavel,
                    label: 'splash_service_caf'.tr,
                    iconColor: AppTheme.splashChipCafIcon,
                    iconBackground: AppTheme.splashChipInactiveBg,
                  ),
                  _ServiceChipPlain(
                    icon: Icons.work,
                    label: 'splash_service_cv'.tr,
                    iconColor: AppTheme.splashChipCvIcon,
                    iconBackground: AppTheme.splashChipInactiveBg,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 28.h),

          SizedBox(
            width: 270.w,
            height: 60.h,
            child: ElevatedButton(
              onPressed: controller.onPrimaryButtonTap,
              style: ElevatedButton.styleFrom(
                elevation: 10,
                shadowColor: AppTheme.primaryGreen.withAlpha(140),
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                'splash_get_started'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.splashTrustedBadgeBg,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'splash_trusted'.tr,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppTheme.splashTrustedBadgeText,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          _buildLanguageSwitcher(controller),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher(SplashController controller) {
    const List<String> languages = <String>['EN', 'IT', 'বাং'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD5D5D5),
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (String language) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22.r),
                    onTap: () => controller.setLanguage(language),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: controller.selectedLanguage.value == language
                            ? AppTheme.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Text(
                        language,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: controller.selectedLanguage.value == language
                              ? Colors.white
                              : const Color(0xFF545454),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // =========================================================
  // ONBOARDING PAGE
  // =========================================================

  Widget _buildOnboardingPage({
    required BuildContext context,
    required int index,
    required String title,
    required String highlight,
    required String titleSuffix,
    required String description,
  }) {
    final int imageIndex = (index - 1).clamp(0, _splashHeaderImages.length - 1);
    final TextStyle headlineLargeStyle =
        Theme.of(context).textTheme.headlineLarge ??
        AppTheme.splashHeadlineStyle;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.splashOnboardingGradient,
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
      child: Column(
        children: <Widget>[
          SizedBox(height: 42.h),

          SizedBox(
            height: 210.h,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                if (index == 1)
                  Transform.translate(
                    offset: Offset(-15.w, 40.h),
                    child: Transform.scale(
                      scale: 2.5,
                      child: Image.asset(
                        _splashHeaderImages[imageIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (index == 2)
                  Transform.translate(
                    offset: Offset(30.w, 65.h),
                    child: Transform.scale(
                      scale: 2.25,
                      child: Image.asset(
                        _splashHeaderImages[imageIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (index == 3)
                  Transform.translate(
                    offset: Offset(55.w, 50.h),
                    child: Transform.scale(
                      scale: 2,
                      child: Image.asset(
                        _splashHeaderImages[imageIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 80.h),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: title, style: headlineLargeStyle),
                TextSpan(
                  text: highlight,
                  style: headlineLargeStyle.copyWith(
                    color: AppTheme.splashHighlight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(text: titleSuffix, style: headlineLargeStyle),
              ],
            ),
            textAlign: TextAlign.center,
            style: headlineLargeStyle,
          ),

          SizedBox(height: 16.h),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: AppTheme.splashBodyText,
            ),
          ),

          SizedBox(height: 170.h),
        ],
      ),
    );
  }

  // =========================================================
  // INDICATOR
  // =========================================================

  Widget _buildPageIndicator(BuildContext context, int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final bool isActive = i == (activeIndex - 1);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryGreen
                : AppTheme.splashIndicatorInactive,
            borderRadius: BorderRadius.circular(10.r),
          ),
        );
      }),
    );
  }
}

// =========================================================
// SERVICE CHIP
// =========================================================

class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? iconColor;

  const _ServiceChip({
    required this.icon,
    required this.label,
    this.active = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.splashChipCardBg,
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.splashChipActiveBg
                  : AppTheme.splashChipInactiveBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 21.r,
              color: active
                  ? AppTheme.splashChipActiveIcon
                  : (iconColor ?? AppTheme.splashChipCafIcon),
            ),
          ),
          SizedBox(height: 8.h),
          Text(label, style: AppTheme.splashServiceChipLabelStyle),
        ],
      ),
    );
  }
}

class _ServiceChipHighlighted extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  const _ServiceChipHighlighted({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return _ServiceChipPlain(
      icon: icon,
      label: label,
      iconColor: iconColor,
      iconBackground: iconBackground,
      backgroundColor: AppTheme.splashChipCardBg,
    );
  }
}

class _ServiceChipPlain extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;
  final Color backgroundColor;

  const _ServiceChipPlain({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124.h,
      width: 79.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 21.r, color: iconColor),
          ),
          SizedBox(height: 8.h),
          Text(label, style: AppTheme.splashServiceChipLabelStyle),
        ],
      ),
    );
  }
}
