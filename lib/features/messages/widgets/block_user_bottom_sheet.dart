import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/message_user_info_controller.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';

class BlockUserBottomSheet extends GetView<MessageUserInfoController> {
  final String userName;

  const BlockUserBottomSheet({super.key, required this.userName});

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
              _WarningIcon(),
              SizedBox(height: 34.h),
              Text(
                'block_username'.trParams(<String, String>{'username': userName.toString()}),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font30.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 24.h),
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'block_user_warning_prefix'.tr,
                    ),
                    TextSpan(
                      text: 'leaderboard_1'.tr,
                      style: TextStyle(color: AppColors.profileOrangeText),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  color: AppColors.modalTextGrey,
                ),
              ),
              SizedBox(height: 44.h),
              CustomButton.primary(
                text: 'yes_block_user'.tr,
                isLoading: controller.isSubmitting.value,
                btnColor: AppColors.blockDangerRed,
                btnShadowColor: AppColors.blockDangerShadow,
                borderColor: AppColors.blockDangerRed,
                onPressed: controller.blockUser,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'cancel'.tr,
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

class _WarningIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: kSafetyBottomSheetIconSize.w,
      height: kSafetyBottomSheetIconSize.w,
      decoration: BoxDecoration(
        color: AppColors.blockDangerRed,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.18),
            blurRadius: 0,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Icon(
        Icons.block_rounded,
        color: AppColors.white.withValues(alpha: 0.86),
        size: 48.w,
      ),
    );
  }
}
