import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../themes/app_colors.dart';

class RewardedAdOptInDialog extends StatelessWidget {
  const RewardedAdOptInDialog({required this.rewardDescription, super.key});

  final String rewardDescription;

  static Future<bool> show({required String rewardDescription}) async {
    return await Get.dialog<bool>(
          RewardedAdOptInDialog(rewardDescription: rewardDescription),
          barrierDismissible: true,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      icon: Container(
        width: 58.r,
        height: 58.r,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF6E5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.ondemand_video_rounded,
          size: 30.r,
          color: AppColors.primaryGreen,
        ),
      ),
      title: Text('rewarded_ad_opt_in_title'.tr, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'rewarded_ad_opt_in_message'.trParams(<String, String>{
              'reward': rewardDescription,
            }),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F4),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.verified_user_outlined,
                  size: 18.r,
                  color: AppColors.primaryGreen,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'rewarded_ad_opt_in_verification_note'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF626862),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back<bool>(result: false),
          child: Text('cancel'.tr),
        ),
        FilledButton.icon(
          onPressed: () => Get.back<bool>(result: true),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text('rewarded_ad_watch_action'.tr),
        ),
      ],
    );
  }
}
