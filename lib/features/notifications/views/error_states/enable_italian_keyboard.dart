import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/status_error_widgets.dart';
import 'package:get/get.dart';

class ItalianKeyboardWarningView extends StatelessWidget {
  final VoidCallback? onSkipTap;
  final String headerAssetPath;

  const ItalianKeyboardWarningView({
    super.key,
    this.onSkipTap,
    this.headerAssetPath = 'assets/status/italian_keyboard_header.png',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StatusColors.pageBg,
      body: StatusPageBackground(
        showKeyboardGlow: true,
        child: ScrollableStatusBody(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 104.h, bottom: 60.h),
              child: Container(
                width: 356.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(42.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 45.r,
                      offset: Offset(0, 25.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(42.r),
                      ),
                      child: AssetOrKeyboardPlaceholder(
                        assetPath: headerAssetPath,
                        width: double.infinity,
                        height: 223.h,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(34.w, 27.h, 34.w, 31.h),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'enable_italian_keyboard'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: StatusColors.primaryGreen,
                              fontSize: 24.sp,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),

                          SizedBox(height: 17.h),

                          Text(
                            'italian_keyboard_accents_help'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: StatusColors.bodyText,
                              fontSize: 16.sp,
                              height: 1.26,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.15,
                            ),
                          ),

                          SizedBox(height: 7.h),

                          Text(
                            'italian_keyboard_setup_help'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF8E8E8E),
                              fontSize: 14.sp,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 27.h),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                              27.w,
                              29.h,
                              25.w,
                              27.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(27.r),
                              border: Border.all(
                                color: const Color(0xFFECECEC),
                                width: 1.w,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.035),
                                  blurRadius: 25.r,
                                  offset: Offset(0, 12.h),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: 22.r,
                                      height: 22.r,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE4F1FA),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.info_rounded,
                                        size: 15.r,
                                        color: const Color(0xFF0E72B8),
                                      ),
                                    ),
                                    SizedBox(width: 11.w),
                                    Text(
                                      'why_it_matters'.tr,
                                      style: TextStyle(
                                        color: const Color(0xFF005D9E),
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 26.h),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          AccentWordRow(
                                            word: 'caffe'.tr,
                                            mark: Icons.close_rounded,
                                            color: const Color(0xFFC8290D),
                                          ),
                                          SizedBox(height: 11.h),
                                          AccentWordRow(
                                            word: 'caff'.tr,
                                            mark: Icons.check_rounded,
                                            color: StatusColors.primaryGreen,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 18.w),

                                    SizedBox(
                                      width: 108.w,
                                      child: Text(
                                        'italian_accents_explanation'.tr,
                                        style: TextStyle(
                                          color: StatusColors.bodyText,
                                          fontSize: 15.sp,
                                          height: 1.45,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32.h),

                          Align(
                            alignment: Alignment.centerRight,
                            child: SkipPillButton(onTap: onSkipTap),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
