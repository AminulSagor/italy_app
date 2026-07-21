import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/status_error_widgets.dart';
import 'package:get/get.dart';

class NoSearchResultStatusView extends StatelessWidget {
  final VoidCallback? onClearSearchTap;
  final String headerAssetPath;

  const NoSearchResultStatusView({
    super.key,
    this.onClearSearchTap,
    this.headerAssetPath = 'assets/status/no_search_result_header.png',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StatusColors.pageBg,
      body: StatusPageBackground(
        showColorGlows: true,
        child: ScrollableStatusBody(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 93.h, bottom: 70.h),
              child: Container(
                width: 342.w,
                padding: EdgeInsets.fromLTRB(40.w, 60.h, 40.w, 40.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(44.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 50.r,
                      offset: Offset(0, 25.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AssetOrNoResultPlaceholder(
                      assetPath: headerAssetPath,
                      width: 154.w,
                      height: 154.h,
                    ),

                    SizedBox(height: 45.h),

                    Text(
                      'no_results_found'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF194D34),
                        fontSize: 29.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),

                    SizedBox(height: 22.h),

                    Text(
                      'search_no_match_message'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StatusColors.bodyText,
                        fontSize: 17.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),

                    SizedBox(height: 45.h),

                    GreenOutlineActionButton(
                      width: 263.w,
                      height: 55.h,
                      text: 'clear_search'.tr,
                      onTap: onClearSearchTap,
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
