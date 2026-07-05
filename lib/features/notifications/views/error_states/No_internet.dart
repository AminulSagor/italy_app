import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/status_error_widgets.dart';
import 'package:get/get.dart';

class NoInternetStatusView extends StatelessWidget {
  final VoidCallback? onTryAgainTap;
  final String headerAssetPath;

  const NoInternetStatusView({
    super.key,
    this.onTryAgainTap,
    this.headerAssetPath = 'assets/status/no_internet_header.png',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StatusColors.pageBg,
      body: StatusPageBackground(
        child: ScrollableStatusBody(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 80.h, bottom: 60.h),
              child: Container(
                width: 342.w,
                padding: EdgeInsets.fromLTRB(30.w, 32.h, 30.w, 31.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 55.r,
                      offset: Offset(0, 30.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(42.r),
                      child: AssetOrNoInternetPlaceholder(
                        assetPath: headerAssetPath,
                        width: 278.w,
                        height: 278.h,
                      ),
                    ),

                    SizedBox(height: 39.h),

                    Text(
                      "Oops! You're\nOffline.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StatusColors.primaryGreen,
                        fontSize: 30.sp,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.1,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      'Please check your internet\nconnection to continue learning\nyour favorite Italian phrases.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StatusColors.bodyText,
                        fontSize: 17.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.15,
                      ),
                    ),

                    SizedBox(height: 49.h),

                    BrightGreenButton(
                      width: 278.w,
                      height: 68.h,
                      text: 'try_again'.tr,
                      onTap: onTryAgainTap,
                    ),

                    SizedBox(height: 28.h),

                    Text(
                      'error_code_is_404_offline'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFA6A6A6),
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.3,
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
