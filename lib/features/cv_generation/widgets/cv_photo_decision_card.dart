import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';

class CvPhotoDecisionCard extends StatelessWidget {
  const CvPhotoDecisionCard({
    required this.isBusy,
    required this.onUploadPhoto,
    required this.onContinueWithoutPhoto,
    super.key,
  });

  final bool isBusy;
  final VoidCallback onUploadPhoto;
  final VoidCallback onContinueWithoutPhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        16.w,
        5.h,
        16.w,
        7.h,
      ),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7E4),
                  borderRadius:
                  BorderRadius.circular(13.r),
                ),
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 24.w,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'cv_photo_decision_title'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color:
                        AppColors.homePrimaryText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'cv_photo_decision_description'.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.4,
                        color:
                        AppColors.homeSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy
                      ? null
                      : onContinueWithoutPhoto,
                  icon: const Icon(
                    Icons.person_off_outlined,
                    size: 18,
                  ),
                  label: Text(
                    'cv_photo_decision_without_photo'.tr,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                    AppColors.homePrimaryText,
                    side: const BorderSide(
                      color: Color(0xFFD8DDD6),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                  isBusy ? null : onUploadPhoto,
                  icon: isBusy
                      ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child:
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.add_a_photo_outlined,
                    size: 18,
                  ),
                  label: Text(
                    'cv_photo_decision_upload_photo'.tr,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}