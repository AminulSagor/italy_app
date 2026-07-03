import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';

class CvChatInputBar extends StatelessWidget {
  const CvChatInputBar({
    required this.controller,
    required this.isSending,
    required this.isUploading,
    required this.onAttach,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isUploading;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final bool isBusy =
        isSending || isUploading;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          14.w,
          8.h,
          14.w,
          12.h,
        ),
        color: Colors.white,
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: isBusy ? null : onAttach,
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                width: 45.w,
                height: 45.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF7E4),
                  shape: BoxShape.circle,
                ),
                child: isUploading
                    ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child:
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Icon(
                  Icons.add_rounded,
                  color:
                  AppColors.primaryGreen,
                ),
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction:
                TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type your answer...',
                  filled: true,
                  fillColor:
                  AppColors.chatInputBg,
                  contentPadding:
                  EdgeInsets.symmetric(
                    horizontal: 17.w,
                    vertical: 13.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 9.w),
            InkWell(
              onTap: isBusy ? null : onSend,
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                width: 45.w,
                height: 45.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: isSending
                    ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child:
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}