import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../service/incoming_call_coordinator.dart';

class GlobalCallStatusCard extends GetView<IncomingCallCoordinator> {
  const GlobalCallStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryGreen,
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: controller.resumePresentedCall,
          child: SizedBox(
            height: 54.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: <Widget>[
                  Obx(
                    () => Icon(
                      controller.presentedCallIsVideo.value
                          ? Icons.videocam_rounded
                          : Icons.call_rounded,
                      color: AppColors.white,
                      size: 24.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(
                      () => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            controller.presentedCallParticipantName.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: AppFont.font14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            controller.presentedCallStatus.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.85),
                              fontSize: AppFont.font12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.open_in_full_rounded,
                    color: AppColors.white,
                    size: 20.w,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
