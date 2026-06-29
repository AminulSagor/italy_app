import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../reward_controller.dart';
import '../widgets/reward_shipping_dialog.dart';
import '../widgets/reward_widgets.dart';

class RewardChestView extends GetView<RewardController> {
  const RewardChestView({super.key});

  static const Color bg = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 48.h),
          child: Column(
            children: <Widget>[
              RewardTopBar(title: 'gen_chest'.tr.tr),
              SizedBox(height: 24.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(31.w, 28.h, 31.w, 32.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4FFD7),
                  borderRadius: BorderRadius.circular(58.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 34.r,
                      offset: Offset(0, 24.h),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 270.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(44.r),
                      ),
                      child: Image.asset(
                        'assets/heroes/chest_img.png',
                        fit: BoxFit.cover,
                      ),
                      // child: ClipRRect(
                      //   borderRadius: BorderRadius.circular(44.r),
                      //   child: Image.asset(
                      //     'assets/rewards/tablet.png',
                      //     fit: BoxFit.cover,
                      //     errorBuilder: (_, __, ___) => Stack(
                      //       alignment: Alignment.center,
                      //       children: <Widget>[
                      //         Transform.rotate(
                      //           angle: -0.18,
                      //           // child: Icon(
                      //           //   Icons.tablet_mac_rounded,
                      //           //   size: 175.r,
                      //           //   color: const Color(0xFF2D3032),
                      //           // ),
                      //         ),
                      //         Positioned(
                      //           top: 52.h,
                      //           right: 46.w,
                      //           child: Transform.rotate(
                      //             angle: 0.55,
                      //             child: Icon(
                      //               Icons.edit_rounded,
                      //               size: 142.r,
                      //               color: const Color(0xFF5E5E5E),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ),

                    SizedBox(height: 32.h),

                    Text(
                      'CONGRATULAZIONI, ARIF!',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.9,
                        color: const Color(0xFF161616),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    Text(
                      'YOU WON A\nTABLET!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34.sp,
                        height: 1.22,
                        fontWeight: FontWeight.w900,
                        color: green,
                        letterSpacing: -0.65,
                      ),
                    ),

                    SizedBox(height: 40.h),

                    RewardPrimaryButton(
                      text: 'Enter Shipping Address',
                      suffixIcon: Icons.local_shipping_outlined,
                      onTap: () {
                        Get.dialog(
                          const RewardShippingDialog(),
                          barrierColor: Colors.black.withValues(alpha: 0.38),
                        );
                      },
                    ),

                    SizedBox(height: 7.h),
                  ],
                ),
              ),

              SizedBox(height: 33.h),

              Container(
                height: 94.h,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 26.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE4FFD7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        size: 22.r,
                        color: green,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Text(
                        'Keep learning to unlock more\nprizes!',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
