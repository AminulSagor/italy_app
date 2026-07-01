import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/message_chat_controller.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageChatController>();

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 26.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(kRadius60.r),
          topRight: Radius.circular(kRadius60.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.blockStatus.value != 'none') {
            if (controller.blockStatus.value == 'blocked_by_me') {
              return Container(
                height: kChatInputHeight.h,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.chatInputBg,
                  borderRadius: BorderRadius.circular(kRadius34.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You blocked this user. ',
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.bodyText,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.unblockUser,
                      child: Text(
                        'Unblock',
                        style: TextStyle(
                          fontSize: AppFont.font16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              height: kChatInputHeight.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.chatInputBg,
                borderRadius: BorderRadius.circular(kRadius34.r),
              ),
              child: Text(
                "You cannot message this user.",
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyText,
                ),
              ),
            );
          }

          return Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: kChatInputHeight.h,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: AppColors.chatInputBg,
                    borderRadius: BorderRadius.circular(kRadius34.r),
                  ),
                  child: TextField(
                    cursorColor: AppColors.primaryGreen,
                    controller: controller.chatTextController,
                    onSubmitted: (_) => controller.sendMessage(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 17.h,
                      ),
                      hintText: 'gen_type_a_message'.tr.tr,
                      hintStyle: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.bodyText,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                width: kChatSendButtonSize.w,
                height: kChatSendButtonSize.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.homeCardShadow,
                      blurRadius: 16.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Obx(() {
                  final bool sending = controller.isSending.value;
                  return GestureDetector(
                    onTap: sending ? null : controller.sendMessage,
                    child: sending
                        ? const Center(child: CircularProgressIndicator())
                        : Icon(
                            Icons.send_rounded,
                            color: AppColors.limeTextColor,
                            size: 26.w,
                          ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
