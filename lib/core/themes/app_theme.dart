import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_font.dart';

class AppTheme {
  AppTheme._();

  static final TextStyle textStyle = TextStyle(
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    fontSize: AppFont.font16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryGreen,
    letterSpacing: -0.04,
  );

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .copyWith(
          headlineLarge: TextStyle(
            fontSize: AppFont.font36.sp,
            fontWeight: FontWeight.w800,
            height: 40 / 36,
            letterSpacing: -0.9,
            color: AppColors.headerText,
          ),
          headlineMedium: TextStyle(
            fontSize: AppFont.font38.sp,
            fontWeight: FontWeight.w800,
            height: 1.13,
            letterSpacing: -0.9,
            color: AppColors.splashTextPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: AppFont.font32.sp,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
            color: AppColors.splashTextPrimary,
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
