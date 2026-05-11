import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
import 'splash_controller.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_font.dart';
import '../../core/themes/app_constants.dart';

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
      backgroundColor: AppColors.scaffoldBackground,
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
                        fontSize: AppFont.font12.sp,
                        color: AppColors.splashSkipText,
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
                        CustomButton(
                          onPressed: controller.onPrimaryButtonTap,
                          text: controller.isLastPage ? 'get_started' : 'next',
                          height: 60,
                          width: double.infinity,
                          isElevated: true,
                          icon: controller.isLastPage
                              ? null
                              : Icons.arrow_forward,
                        ),
                        if (controller.isLastPage)
                          TextButton(
                            onPressed: controller.onAlreadyHaveAccountTap,
                            child: Text(
                              'already_have_account_lower'.tr,
                              style: TextStyle(
                                fontSize: AppFont.font13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.splashSecondaryActionText,
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
      decoration: const BoxDecoration(
        gradient: AppColors.splashWelcomeGradient,
      ),
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
                    backgroundColor: AppColors.primaryGreen,
                    child: Icon(
                      Icons.language,
                      color: AppColors.white,
                      size: 14.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'app_name'.tr,
                    style:
                        TextStyle(
                          fontSize: AppFont.font36.sp,
                          fontWeight: FontWeight.w800,
                          height: 40 / 36,
                          letterSpacing: -0.9,
                          color: AppColors.headerText,
                        ).copyWith(
                          fontSize: AppFont.font22.sp,
                          height: 1,
                          letterSpacing: 0,
                          color: AppColors.splashBrandText,
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
              color: AppColors.splashTextPrimary,
            ),
          ),

          Text(
            'splash_title_line2'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.primaryGreen,
            ),
          ),

          SizedBox(height: 26.h),

          Align(
            child: Container(
              width: 263.w,
              height: 142.h,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.splashChipContainer,
                borderRadius: BorderRadius.circular(kRadius42.r),
                border: Border.all(color: AppColors.splashChipBorder),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.legacyColor10000000,
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
                  //   iconColor: AppColors.splashChipCafIcon,
                  // ),
                  // _ServiceChip(
                  //   icon: Icons.work,
                  //   label: 'splash_service_cv'.tr,
                  //   iconColor: AppColors.splashChipCvIcon,
                  // ),
                  _ServiceChipHighlighted(
                    icon: Icons.menu_book,
                    label: 'splash_service_italian'.tr,
                    iconColor: AppColors.splashChipActiveIcon,
                    iconBackground: AppColors.splashChipActiveBg,
                  ),
                  _ServiceChipPlain(
                    icon: Icons.gavel,
                    label: 'splash_service_caf'.tr,
                    iconColor: AppColors.splashChipCafIcon,
                    iconBackground: AppColors.splashChipInactiveBg,
                  ),
                  _ServiceChipPlain(
                    icon: Icons.work,
                    label: 'splash_service_cv'.tr,
                    iconColor: AppColors.splashChipCvIcon,
                    iconBackground: AppColors.splashChipInactiveBg,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 28.h),

          CustomButton(
            onPressed: controller.onPrimaryButtonTap,
            text: 'splash_get_started',
            height: 60,
            width: 270,
            isElevated: true,
            //showShadow: false,
          ),

          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.splashTrustedBadgeBg,
              borderRadius: BorderRadius.circular(kRadius20.r),
            ),
            child: Text(
              'splash_trusted'.tr,
              style: TextStyle(
                fontSize: AppFont.font11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.splashTrustedBadgeText,
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
        color: AppColors.legacyColorFFD5D5D5,
        borderRadius: BorderRadius.circular(kRadius26.r),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (String language) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(kRadius22.r),
                    onTap: () => controller.setLanguage(language),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: controller.selectedLanguage.value == language
                            ? AppColors.primaryGreen
                            : AppColors.transparent,
                        borderRadius: BorderRadius.circular(kRadius18.r),
                      ),
                      child: Text(
                        language,
                        style: TextStyle(
                          fontSize: AppFont.font13.sp,
                          fontWeight: FontWeight.w700,
                          color: controller.selectedLanguage.value == language
                              ? AppColors.white
                              : AppColors.legacyColorFF545454,
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
        TextStyle(
          fontSize: AppFont.font38.sp,
          fontWeight: FontWeight.w800,
          height: 1.13,
          letterSpacing: -0.9,
          color: AppColors.splashTextPrimary,
        );

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.splashOnboardingGradient,
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
                    color: AppColors.splashHighlight,
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
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: AppColors.splashBodyText,
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
                ? AppColors.primaryGreen
                : AppColors.splashIndicatorInactive,
            borderRadius: BorderRadius.circular(kRadius10.r),
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
        color: AppColors.splashChipCardBg,
        borderRadius: BorderRadius.circular(kRadius36.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.splashChipActiveBg
                  : AppColors.splashChipInactiveBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 21.r,
              color: active
                  ? AppColors.splashChipActiveIcon
                  : (iconColor ?? AppColors.splashChipCafIcon),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.splashTextSecondary,
            ),
          ),
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
      backgroundColor: AppColors.splashChipCardBg,
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
    this.backgroundColor = AppColors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124.h,
      width: 79.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(kRadius36.r),
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
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.splashTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
