import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/message_user_info_controller.dart';

class UnblockUserBottomSheet
    extends GetView<MessageUserInfoController> {
  const UnblockUserBottomSheet({
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
        constraints: BoxConstraints(
          maxHeight:
          MediaQuery.sizeOf(context).height *
              0.82,
        ),
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
          physics:
          const BouncingScrollPhysics(),
          child: Obx(
                () => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _BottomSheetHandle(),

                SizedBox(height: 20.h),

                const _UnlockIcon(),

                SizedBox(height: 20.h),

                Text(
                  'unblock_username'.trParams(
                    <String, String>{
                      'username': displayName,
                    },
                  ),
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color:
                    AppColors.primaryGreen,
                  ),
                ),

                SizedBox(height: 12.h),

                Padding(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 8.w,
                  ),
                  child: Text(
                    'this_user_will_be_able_to_message_you_again_and_se'
                        .tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                      AppFont.font14.sp,
                      fontWeight:
                      FontWeight.w400,
                      height: 1.45,
                      color:
                      AppColors.modalTextGrey,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                CustomButton.primary(
                  text: 'yes_unblock'.tr,
                  isLoading:
                  controller
                      .isSubmitting
                      .value,
                  onPressed: () async {
                    if (controller
                        .isSubmitting
                        .value) {
                      return;
                    }

                    await controller
                        .unblockUser();
                  },
                ),

                SizedBox(height: 12.h),

                CustomButton(
                  text: 'cancel'.tr,
                  width: double.infinity,
                  height: 52.h,
                  btnColor: AppColors.white,
                  borderColor:
                  AppColors.modalBorderGrey,
                  textColor:
                  AppColors.modalTextGrey,
                  showShadow: false,
                  onPressed: () {
                    if (controller
                        .isSubmitting
                        .value) {
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

class _BottomSheetHandle
    extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 5.h,
      decoration: BoxDecoration(
        color: AppColors.modalHandle,
        borderRadius:
        BorderRadius.circular(100.r),
      ),
    );
  }
}

class _UnlockIcon extends StatelessWidget {
  const _UnlockIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76.w,
      height: 76.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(22.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blockSuccessGlow
                .withValues(alpha: 0.45),
            blurRadius: 24.r,
            spreadRadius: 5.r,
          ),
          BoxShadow(
            color: AppColors.black
                .withValues(alpha: 0.10),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_open_rounded,
        color: AppColors.primaryGreen,
        size: 36.w,
      ),
    );
  }
}