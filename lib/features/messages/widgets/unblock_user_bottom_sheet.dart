import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/message_user_info_controller.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';

class UnblockUserBottomSheet extends GetView<MessageUserInfoController> {
  final String userName;

  const UnblockUserBottomSheet({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(32.w, 20.h, 32.w, 40.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kSafetyBottomSheetRadius.r),
          ),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _BottomSheetHandle(),
              SizedBox(height: 32.h),
              _UnlockIcon(),
              SizedBox(height: 42.h),
              Text(
                'Unblock $userName?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font30.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'This user will be able to message you again and see your profile on the Leaderboard.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  color: AppColors.modalTextGrey,
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton.primary(
                text: 'Yes, Unblock',
                isLoading: controller.isSubmitting.value,
                onPressed: controller.unblockUser,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'Cancel',
                width: double.infinity,
                height: kButtonDefaultHeight,
                btnColor: AppColors.white,
                borderColor: AppColors.modalBorderGrey,
                textColor: AppColors.modalTextGrey,
                showShadow: false,
                onPressed: () => Get.back<void>(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: AppColors.modalHandle,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
    );
  }
}

class _UnlockIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124.w,
      height: 124.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius28.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blockSuccessGlow,
            blurRadius: 52.r,
            spreadRadius: 12.r,
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 22.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_open_rounded,
        color: AppColors.primaryGreen,
        size: 58.w,
      ),
    );
  }
}
