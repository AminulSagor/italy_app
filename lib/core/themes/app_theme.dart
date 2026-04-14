import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryGreen = Color(0xFF2A6900);
  static const Color scaffoldBackground = Color(0xFFE3E3E3);
  static const Color white = Colors.white;
  static const Color headerText = Color(0xFF2F3337);
  static const Color bodyText = Color(0xFF5C5E60);
  static const Color splashBrandText = Color(0xFF2E3336);
  static const Color splashTextPrimary = Color(0xFF2F3437);
  static const Color splashTextSecondary = Color(0xFF2F3438);
  static const Color splashSkipText = Color(0xFF666A6D);
  static const Color splashWelcomeGradientTop = Color(0xFFF7F8F7);
  static const Color splashWelcomeGradientBottom = Color(0xFFF3F6F9);
  static const Color splashOnboardingGradientTop = Color(0xFFF6F7F7);
  static const Color splashOnboardingGradientBottom = Color(0xFFF1F4F7);
  static const Color splashIllustrationBg = Color(0xFFD9E8CF);
  static const Color splashChipContainer = Color(0xFFF3F4F4);
  static const Color splashChipBorder = Color(0xFFE1E4E2);
  static const Color splashChipActiveBg = Color(0xFFDFE7DA);
  static const Color splashChipInactiveBg = Color(0xFFE4E4E4);
  static const Color splashChipCardBg = Color(0xFFFFFFFF);
  static const Color splashChipActiveIcon = Color(0xFF2A7A08);
  static const Color splashChipCafIcon = Color(0xFF9B712B);
  static const Color splashChipCvIcon = Color(0xFF1E7DBD);
  static const Color splashTrustedBadgeBg = Color(0xFFEDEFF0);
  static const Color splashTrustedBadgeText = Color(0xFF6E7377);
  static const Color splashBodyText = Color(0xFF5F6467);
  static const Color splashSecondaryActionText = Color(0xFF505356);
  static const Color splashIndicatorInactive = Color(0xFFD3D6D8);
  static const Color splashHighlight = primaryGreen;

  static const LinearGradient splashWelcomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[splashWelcomeGradientTop, splashWelcomeGradientBottom],
  );

  static const LinearGradient splashOnboardingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      splashOnboardingGradientTop,
      splashOnboardingGradientBottom,
    ],
  );

  static TextStyle get splashServiceChipLabelStyle => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: splashTextSecondary,
  );

  static TextStyle get brandHeaderStyle => TextStyle(
    fontSize: 36.sp,
    fontWeight: FontWeight.w800,
    height: 40 / 36,
    letterSpacing: -0.9,
    color: headerText,
  );

  static TextStyle get splashHeadlineStyle => brandHeaderStyle.copyWith(
    fontSize: 38.sp,
    height: 1.13,
    color: splashTextPrimary,
  );

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .copyWith(
          headlineLarge: brandHeaderStyle,
          headlineMedium: splashHeadlineStyle,
          headlineSmall: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
            color: splashTextPrimary,
          ),
        );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        base.primaryTextTheme,
      ),
    );
  }
}
