import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_font.dart';

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'PlusJakartaSans';
  static const List<String> fontFamilyFallback = <String>['NotoSansBengali'];

  static final TextStyle textStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
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
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );

    final textTheme = base.textTheme
        .apply(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback)
        .copyWith(
          headlineLarge: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: fontFamilyFallback,
            fontSize: AppFont.font36.sp,
            fontWeight: FontWeight.w800,
            height: 40 / 36,
            letterSpacing: -0.9,
            color: AppColors.headerText,
          ),
          headlineMedium: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: fontFamilyFallback,
            fontSize: AppFont.font38.sp,
            fontWeight: FontWeight.w800,
            height: 1.13,
            letterSpacing: -0.9,
            color: AppColors.splashTextPrimary,
          ),
          headlineSmall: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: fontFamilyFallback,
            fontSize: AppFont.font32.sp,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
            color: AppColors.splashTextPrimary,
          ),
        );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: base.primaryTextTheme.apply(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
    );
  }
}
