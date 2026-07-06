import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/message_incoming_call_controller.dart';

class MessageIncomingCallView extends StatelessWidget {
  const MessageIncomingCallView({required this.controller, super.key});

  final MessageIncomingCallController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Obx(
          () => Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 30.h),
            child: Column(
              children: <Widget>[
                SizedBox(height: 40.h),
                Icon(
                  controller.callType.isVideo
                      ? Icons.videocam_rounded
                      : Icons.call_rounded,
                  size: 34.w,
                  color: AppColors.primaryGreen,
                ),
                SizedBox(height: 14.h),
                Text(
                  controller.statusLabel.value,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                const Spacer(),
                _CallerAvatar(
                  avatarUrl: controller.caller.avatarUrl,
                  name: controller.caller.name,
                ),
                SizedBox(height: 22.h),
                Text(
                  controller.caller.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  controller.callType.isVideo
                      ? 'incoming_video_call'.tr
                      : 'incoming_voice_call'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.homePrimaryText.withValues(alpha: 0.65),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _IncomingCallButton(
                      icon: Icons.call_end_rounded,
                      label: 'gen_decline'.tr,
                      backgroundColor: Colors.red,
                      isLoading: controller.isProcessing.value,
                      onPressed: controller.rejectCall,
                    ),
                    _IncomingCallButton(
                      icon: controller.callType.isVideo
                          ? Icons.videocam_rounded
                          : Icons.call_rounded,
                      label: 'gen_answer'.tr,
                      backgroundColor: AppColors.primaryGreen,
                      isLoading: controller.isProcessing.value,
                      onPressed: controller.answerCall,
                    ),
                  ],
                ),
                SizedBox(height: 42.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallerAvatar extends StatelessWidget {
  const _CallerAvatar({required this.avatarUrl, required this.name});

  final String avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(avatarUrl.trim());
    final bool canLoadAvatar =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    return Container(
      width: 132.w,
      height: 132.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryGreen.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.primaryGreen, width: 3.w),
      ),
      child: ClipOval(
        child: ColoredBox(
          color: AppColors.white,
          child: canLoadAvatar
              ? Image.network(
                  avatarUrl.trim(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _AvatarFallback(),
                )
              : const _AvatarFallback(),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        color: AppColors.primaryGreen,
        size: 64,
      ),
    );
  }
}

class _IncomingCallButton extends StatelessWidget {
  const _IncomingCallButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.isLoading,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isLoading ? null : onPressed,
            child: SizedBox(
              width: 72.w,
              height: 72.w,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(icon, size: 32.w, color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFont.font14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.homePrimaryText,
          ),
        ),
      ],
    );
  }
}
