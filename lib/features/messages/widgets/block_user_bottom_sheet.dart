import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/message_user_info_controller.dart';

class BlockUserBottomSheet
    extends GetView<MessageUserInfoController> {
  const BlockUserBottomSheet({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    final String displayName =
    userName.trim().isEmpty
        ? 'user'.tr
        : userName.trim();

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          24.w,
          12.h,
          24.w,
          24.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Obx(
                () => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _BottomSheetHandle(),
                SizedBox(height: 20.h),

                const _WarningIcon(),
                SizedBox(height: 20.h),

                Text(
                  'block_username'.trParams(
                    <String, String>{
                      'username': displayName,
                    },
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.primaryGreen,
                  ),
                ),

                SizedBox(height: 14.h),

                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text:
                        'block_user_warning_prefix'
                            .tr,
                      ),
                      TextSpan(
                        text: 'leaderboard_1'.tr,
                        style: const TextStyle(
                          color: AppColors
                              .profileOrangeText,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: AppColors.modalTextGrey,
                  ),
                ),

                SizedBox(height: 28.h),

                CustomButton.primary(
                  text: 'yes_block_user'.tr,
                  isLoading: controller.isSubmitting.value,
                  btnColor: AppColors.blockDangerRed,
                  btnShadowColor: AppColors.blockDangerShadow,
                  borderColor: AppColors.blockDangerRed,
                  onPressed: () async {
                    if (controller.isSubmitting.value) {
                      return;
                    }

                    await controller.blockUser();
                  },
                ),

                SizedBox(height: 12.h),

                CustomButton(
                  text: 'cancel'.tr,
                  width: double.infinity,
                  height: 52.h,
                  btnColor: AppColors.white,
                  borderColor: AppColors.modalBorderGrey,
                  textColor: AppColors.modalTextGrey,
                  showShadow: false,
                  onPressed: () {
                    if (controller.isSubmitting.value) {
                      return;
                    }

                    Get.back<void>();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 5.h,
      decoration: BoxDecoration(
        color: AppColors.modalHandle,
        borderRadius: BorderRadius.circular(
          100.r,
        ),
      ),
    );
  }
}

class _WarningIcon extends StatelessWidget {
  const _WarningIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        color: AppColors.blockDangerRed,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(
              alpha: 0.14,
            ),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Icon(
        Icons.block_rounded,
        color: AppColors.white,
        size: 34.w,
      ),
    );
  }
}