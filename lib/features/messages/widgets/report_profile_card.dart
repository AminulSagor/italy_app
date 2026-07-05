import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/message_models.dart';
import 'message_avatar.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import 'package:get/get.dart';

class ReportProfileCard extends StatelessWidget {
  final MessageUserProfileModel profile;

  const ReportProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kReportProfileCardHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 38.w),
      decoration: BoxDecoration(
        color: AppColors.messageTileInactiveBg,
        borderRadius: BorderRadius.circular(kRadius42.r),
      ),
      child: Row(
        children: <Widget>[
          MessageAvatar(imageUrl: profile.avatarUrl, size: 72),
          SizedBox(width: 26.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'reporting_profile'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
