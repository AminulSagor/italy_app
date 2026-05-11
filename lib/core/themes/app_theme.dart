import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryGreen = Color(0xFF2A6900);
  static const Color scaffoldBackground = Color(0xFFE3E3E3);
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;
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

  static const Color homeBackground = Color(0xFFF6F6F6);
  static const Color homeDarkGreen = Color(0xFF176F00);
  static const Color homeDeepGreen = Color(0xFF1E6F00);
  static const Color homePrimaryText = Color(0xFF22272B);
  static const Color homeSecondaryText = Color(0xFF7A7E83);
  static const Color homeMutedText = Color(0xFF9EA3A9);
  static const Color homeLime = Color(0xFF82FF3B);
  static const Color homePaleGreen = Color(0xFFD9FFC8);
  static const Color homeSoftGreen = Color(0xFFDEF8C9);
  static const Color homeGreenChip = Color(0xFFC8FFAA);
  static const Color homeLightGreen = Color(0xFFA9D98A);
  static const Color homeBarLight = Color(0xFFB8DBA3);
  static const Color homeBarPale = Color(0xFFB8E676);
  static const Color homeBarTrack = Color(0xFFE4E6EC);
  static const Color homeOrange = Color(0xFFFF9300);
  static const Color homeOrangeDeep = Color(0xFFFF5A21);
  static const Color homeBlueCard = Color(0xFFB6D6FF);
  static const Color homeBlueIcon = Color(0xFF1671B8);
  static const Color homeCreamIcon = Color(0xFFF8EFE3);
  static const Color homeBrownIcon = Color(0xFF9A6100);
  static const Color homeCardShadow = Color(0x1F1A5B00);
  static const Color homeNeutralShadow = Color(0x14000000);
  static const Color homeNotificationRed = Color(0xFFE7202A);
  static const Color homeBottomNavBg = Color(0xFFFFFFFF);
  static const Color homeBottomNavActiveBg = Color(0xFFD8FF98);
  static const Color homeBottomNavInactive = Color(0xFF9EA8B4);
  static const Color homeProgressTrack = Color(0xFFE1E8E6);
  static const Color homeChallengeGreen = Color(0xFF267800);

  static const double homeHorizontalPadding = 24;
  static const double homeSectionSpacing = 26;
  static const double homeCardRadius = 34;
  static const double homeSmallCardRadius = 26;
  static const double homePillRadius = 28;
  static const double homeIconCircleSize = 46;
  static const double homeTopIconSize = 26;
  static const double homeAvatarSize = 48;
  static const double homeTinyBadgeSize = 24;
  static const double homeChartHeight = 130;
  static const double homeChapterCardHeight = 252;
  static const double homeToolCardHeight = 130;
  static const double homeToolCardWidth = 150;
  static const double homeWorkChipHeight = 52;
  static const double homeSupportCardHeight = 78;
  static const double homeWebinarCardHeight = 170;
  static const double homeCultureCardMinHeight = 124;
  static const double homeStreakHeight = 88;
  static const double homeTutorCardMinHeight = 260;
  static const double homeChallengeCardHeight = 136;
  static const double homeBottomNavHeight = 72;
  static const double homeBottomNavIconBox = 64;
  static const double homeBottomNavOuterPadding = 12;
  static const double homeLoadingSize = 28;
  static const double homeProgressHeight = 16;
  static const double homeSlimProgressHeight = 14;

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

  static const LinearGradient homeChapterGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[homeDarkGreen, homeDeepGreen],
  );

  static const LinearGradient homeCultureGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[white, homePaleGreen],
  );

  static const LinearGradient homeAiTutorGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: <Color>[white, homePaleGreen],
  );

  static const LinearGradient homeStreakGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[homeOrangeDeep, homeOrange],
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

  static TextStyle get homeWelcomeLabelStyle => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
    color: homeSecondaryText,
  );

  static TextStyle get homeWelcomeNameStyle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w800,
    height: 1,
    color: primaryGreen,
  );

  static TextStyle get homeSectionTitleStyle => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w800,
    height: 1.1,
    color: homePrimaryText,
  );

  static TextStyle get homeSectionSubtitleStyle => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: homeSecondaryText,
  );

  static TextStyle get homeOverviewValueStyle => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w900,
    height: 1,
    color: primaryGreen,
  );

  static TextStyle get homeOverviewUnitStyle => TextStyle(
    fontSize: 9.sp,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.1,
    color: homeSecondaryText,
  );

  static TextStyle get homeChartAxisStyle => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w900,
    color: homeSecondaryText,
  );

  static TextStyle get homeChapterEyebrowStyle => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.9,
    color: homeBarLight,
  );

  static TextStyle get homeChapterTitleStyle => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w900,
    height: 1.12,
    color: homePaleGreen,
  );

  static TextStyle get homeChapterMetaStyle => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w800,
    color: homePaleGreen,
  );

  static TextStyle get homePrimaryButtonStyle => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w900,
    color: primaryGreen,
  );

  static TextStyle get homeToolTitleStyle => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w900,
    height: 1.05,
    color: homePrimaryText,
  );

  static TextStyle get homeToolSubtitleStyle => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: homeSecondaryText,
  );

  static TextStyle get homeActionChipStyle => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w900,
    color: primaryGreen,
  );

  static TextStyle get homeWorkChipStyle => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w800,
    color: homePrimaryText,
  );

  static TextStyle get homeSupportTitleStyle => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w900,
    height: 1,
    color: primaryGreen,
  );

  static TextStyle get homeSupportSubtitleStyle => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: primaryGreen,
  );

  static TextStyle get homeWebinarBadgeStyle => TextStyle(
    fontSize: 9.sp,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
    color: homePaleGreen,
  );

  static TextStyle get homeWebinarTitleStyle => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w900,
    color: white,
  );

  static TextStyle get homeWebinarNameStyle => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w900,
    height: 1.1,
    color: white,
  );

  static TextStyle get homeWebinarTimeStyle => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
    color: homePaleGreen,
  );

  static TextStyle get homeJoinButtonStyle => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w900,
    color: primaryGreen,
  );

  static TextStyle get homeCultureTitleStyle => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w900,
    color: primaryGreen,
  );

  static TextStyle get homeCultureBodyStyle => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: homeSecondaryText,
  );

  static TextStyle get homeStreakTitleStyle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w900,
    height: 1,
    color: white,
  );

  static TextStyle get homeStreakSubtitleStyle => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: white,
  );

  static TextStyle get homeAiEyebrowStyle => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.1,
    color: primaryGreen,
  );

  static TextStyle get homeAiTitleStyle => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w900,
    height: 1.12,
    color: primaryGreen,
  );

  static TextStyle get homeAiBodyStyle => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    height: 1.55,
    color: homeSecondaryText,
  );

  static TextStyle get homeChatButtonStyle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w900,
    color: white,
  );

  static TextStyle get homeChallengeLabelStyle => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.3,
    color: homeSecondaryText,
  );

  static TextStyle get homeChallengeValueStyle => TextStyle(
    fontSize: 23.sp,
    fontWeight: FontWeight.w900,
    height: 1,
    color: homePrimaryText,
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
