import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/message_user_info_controller.dart';
import '../models/message_models.dart';

class MessageUnblockSuccessView
    extends GetView<MessageUserInfoController> {
  const MessageUnblockSuccessView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Obx(() {
          final MessageUserProfileModel? profile =
              controller.profile.value;

          final String rawUserName =
              profile?.name.trim() ?? '';

          final String userName =
          rawUserName.isEmpty
              ? 'user'.tr
              : rawUserName;

          return SingleChildScrollView(
            physics:
            const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24.w,
              36.h,
              24.w,
              28.h,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 560,
                ),
                child: Column(
                  children: <Widget>[
                    const _UnblockedHeroIcon(),

                    SizedBox(height: 28.h),

                    Text(
                      'user_unblocked'.tr,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                        AppFont.font28.sp,
                        fontWeight:
                        FontWeight.w800,
                        height: 1.15,
                        color: AppColors
                            .homePrimaryText,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Padding(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal: 12.w,
                      ),
                      child: Text(
                        'username_has_been_successfully_unblocked_you_can_now_send_messages_and_view_their_profile_again'
                            .trParams(
                          <String, String>{
                            'username': userName,
                          },
                        ),
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          fontSize:
                          AppFont.font15.sp,
                          fontWeight:
                          FontWeight.w400,
                          height: 1.45,
                          color: AppColors
                              .modalTextGrey,
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    const _CommunicationRestoredCard(),

                    SizedBox(height: 32.h),

                    CustomButton.primary(
                      text:
                      'back_to_messages'.tr,
                      onPressed: () {
                        controller
                            .backToMessages();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _UnblockedHeroIcon
    extends StatelessWidget {
  const _UnblockedHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104.w,
      height: 104.w,
      decoration: BoxDecoration(
        color: AppColors
            .unblockSuccessIconBg,
        borderRadius:
        BorderRadius.circular(30.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors
                .blockSuccessGlow
                .withValues(alpha: 0.45),
            blurRadius: 28.r,
            spreadRadius: 7.r,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
            BorderRadius.circular(22.r),
          ),
          child: Center(
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration:
              const BoxDecoration(
                color:
                AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: 25.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunicationRestoredCard
    extends StatelessWidget {
  const _CommunicationRestoredCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color:
        AppColors.unblockSuccessInfoBg,
        borderRadius:
        BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 46.w,
            height: 46.w,
            decoration:
            const BoxDecoration(
              color: AppColors
                  .unblockSuccessIconCircle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_open_rounded,
              color:
              AppColors.primaryGreen,
              size: 24.w,
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'communication_restored'
                      .tr,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                    AppFont.font16.sp,
                    fontWeight:
                    FontWeight.w700,
                    height: 1.25,
                    color: AppColors
                        .homePrimaryText,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  'safe_learning_environment_maintained'
                      .tr,
                  style: TextStyle(
                    fontSize:
                    AppFont.font13.sp,
                    fontWeight:
                    FontWeight.w400,
                    height: 1.4,
                    color: AppColors
                        .modalTextGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}