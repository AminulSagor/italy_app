import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../routes/app_routes.dart';
import '../controllers/pro_checkout_controller.dart';
import '../models/pro_checkout_models.dart';

class ProPurchaseSuccessView extends GetView<ProCheckoutController> {
  final String controllerTag;

  const ProPurchaseSuccessView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  void _backToCourse() {
    Get.until(
      (Route<dynamic> route) =>
          route.settings.name == AppRoutes.courseDetail || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProPurchaseResultModel result =
        controller.purchaseResult.value ??
        ProPurchaseResultModel(
          orderId: '#IT-SHK-1024',
          statusLabel: 'status_completed'.tr,
          title: 'gen_congratulations'.tr,
          description:
              'You now have full lifetime access to all\nItalian Shikhi features. Your journey to\nfluency starts today.',
          buttonLabel: 'start_learning_now'.tr,
        );

    return Material(
      color: AppColors.coursesDetailBg,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 58.h),
          child: Column(
            children: <Widget>[
              SizedBox(height: 16.h),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _backToCourse,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.bodyText,
                        size: 22.w,
                      ),
                    ),
                  ),
                  Text(
                    'course_unlocked_1'.tr,
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48.h),
              const _SuccessHeroIcon(),
              SizedBox(height: 30.h),
              Text(
                result.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font36.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homePrimaryText,
                  height: 1.06,
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                result.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyText,
                  height: 1.55,
                ),
              ),
              SizedBox(height: 40.h),
              _OrderStatusCard(result: result),
              SizedBox(height: 40.h),
              CustomButton.primary(
                text: result.buttonLabel,
                icon: Icons.play_arrow_rounded,
                onPressed: _backToCourse,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessHeroIcon extends StatelessWidget {
  const _SuccessHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      height: 180.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(54.r),
        border: Border.all(color: AppColors.homeLime, width: 5.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeLime.withValues(alpha: 0.28),
            blurRadius: 58.r,
            spreadRadius: 22.r,
          ),
        ],
      ),
      child: Icon(
        Icons.verified_rounded,
        size: 60.w,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  final ProPurchaseResultModel result;

  const _OrderStatusCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius30.r),
        border: Border.all(
          color: AppColors.quizProgressTrack,
          width: 2.w,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'gen_order_id'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  result.orderId,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homePrimaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.w,
            height: 42.h,
            color: AppColors.quizProgressTrack,
          ),
          SizedBox(width: 16.w),
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              result.statusLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font12.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
