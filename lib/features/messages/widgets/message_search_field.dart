import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class MessageSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const MessageSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kMessageSearchHeight.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kHomeCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        cursorColor: AppColors.primaryGreen,
        style: TextStyle(
          fontSize: AppFont.font18.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.messageSearchHint,
        ).copyWith(color: AppColors.homePrimaryText),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'gen_search_learners'.tr,
          hintStyle: TextStyle(
            fontSize: AppFont.font18.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.messageSearchHint,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 8.w),
            child: Icon(
              Icons.search_rounded,
              size: 26.w,
              color: AppColors.bodyText,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 74.w),
          contentPadding: EdgeInsets.symmetric(vertical: 19.h),
        ),
      ),
    );
  }
}
