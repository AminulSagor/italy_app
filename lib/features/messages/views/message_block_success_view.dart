import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/message_user_info_controller.dart';
import '../models/message_models.dart';

class MessageBlockSuccessView
    extends GetView<MessageUserInfoController> {
  const MessageBlockSuccessView({
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
                    const _BlockedHeroIcon(),

                    SizedBox(height: 28.h),

                    Text(
                      'user_blocked'.tr,
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
                        color:
                        AppColors.primaryGreen,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Padding(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal: 16.w,
                      ),
                      child: Text(
                        'safe_learning_environment_restored'
                            .tr,
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          fontSize:
                          AppFont.font15.sp,
                          fontWeight:
                          FontWeight.w400,
                          height: 1.45,
                          color:
                          AppColors.modalTextGrey,
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    _PrivacyInfoCard(
                      userName: userName,
                    ),

                    SizedBox(height: 18.h),

                    const _SafetyStatusCards(),

                    SizedBox(height: 32.h),

                    CustomButton.primary(
                      text:
                      'back_to_message'.tr,
                      onPressed:
                      controller.backToMessage,
                    ),

                    SizedBox(height: 12.h),

                    CustomButton(
                      text: 'unblock_user'.tr,
                      width: double.infinity,
                      height: 52.h,
                      btnColor: AppColors.white,
                      borderColor:
                      AppColors.primaryGreen,
                      textColor:
                      AppColors.primaryGreen,
                      showShadow: false,
                      onPressed: controller
                          .openUnblockUserSheet,
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

class _BlockedHeroIcon
    extends StatelessWidget {
  const _BlockedHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92.w,
      height: 92.w,
      decoration: BoxDecoration(
        color:
        AppColors.blockSuccessIconBg,
        borderRadius:
        BorderRadius.circular(28.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors
                .blockSuccessGlow
                .withValues(alpha: 0.5),
            blurRadius: 28.r,
            spreadRadius: 8.r,
          ),
        ],
      ),
      child: Icon(
        Icons.verified_user_rounded,
        color: AppColors.homePaleGreen,
        size: 46.w,
      ),
    );
  }
}

class _PrivacyInfoCard
    extends StatelessWidget {
  const _PrivacyInfoCard({
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color:
        AppColors.blockSuccessBlueBg,
        borderRadius:
        BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: AppColors
                  .blockSuccessBlueIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.visibility_off_outlined,
              color:
              AppColors.profileBlueText,
              size: 23.w,
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'username_has_been_hidden_from_your_app'
                      .trParams(
                    <String, String>{
                      'username': userName,
                    },
                  ),
                  style: TextStyle(
                    fontSize:
                    AppFont.font15.sp,
                    fontWeight:
                    FontWeight.w700,
                    height: 1.35,
                    color: AppColors
                        .blockSuccessBlueText,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'they_will_not_be_notified_that_you_blocked_them_yo'
                      .tr,
                  style: TextStyle(
                    fontSize:
                    AppFont.font13.sp,
                    fontWeight:
                    FontWeight.w400,
                    height: 1.45,
                    color: AppColors
                        .blockSuccessBlueText
                        .withValues(
                      alpha: 0.75,
                    ),
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

class _SafetyStatusCards
    extends StatelessWidget {
  const _SafetyStatusCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SafetyStatusCard(
            icon:
            Icons.lock_outline_rounded,
            title: 'gen_secure'.tr,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: _SafetyStatusCard(
            icon: Icons.shield_outlined,
            title: 'gen_private'.tr,
          ),
        ),
      ],
    );
  }
}

class _SafetyStatusCard
    extends StatelessWidget {
  const _SafetyStatusCard({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 84.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color:
        AppColors.messageTileInactiveBg,
        borderRadius:
        BorderRadius.circular(18.r),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: AppColors.primaryGreen,
            size: 25.w,
          ),

          SizedBox(height: 8.h),

          Text(
            title,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}