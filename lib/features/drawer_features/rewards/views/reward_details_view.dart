import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/reward_widgets.dart';

class RewardDetailsView extends StatelessWidget {
  const RewardDetailsView({super.key});

  static const Color bg = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(25.w, 39.h, 25.w, 56.h),
          child: Column(
            children: <Widget>[
              RewardTopBar(title: 'gen_reward_details'.tr.tr),
              SizedBox(height: 30.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(34.w, 31.h, 34.w, 33.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 22.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 191.h,
                      width: 191.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26.r),
                      ),
                      child: Image.asset(
                        'assets/rewards/headphones.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.headphones_rounded,
                          size: 136.r,
                          color: const Color(0xFFD71920),
                        ),
                      ),
                    ),

                    SizedBox(height: 25.h),

                    Text(
                      'Boat Wireless\nHeadphones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 29.sp,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D3032),
                        letterSpacing: -0.8,
                      ),
                    ),

                    SizedBox(height: 13.h),

                    Text(
                      'Premium Sound Experience',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF626262),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              Row(
                children: <Widget>[
                  Container(
                    width: 161.w,
                    height: 65.h,
                    padding: EdgeInsets.symmetric(horizontal: 19.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4F8C3),
                      borderRadius: BorderRadius.circular(100.r),
                      border: Border.all(color: const Color(0xFFAAE891)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: const BoxDecoration(
                            color: green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Text(
                          'Status:\nDelivered',
                          style: TextStyle(
                            fontSize: 13.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18.r,
                    color: const Color(0xFF575757),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Awarded: Sept 20,\n2023',
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF626262),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 35.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(32.w, 31.h, 32.w, 31.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(34.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9700),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            size: 26.r,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 17.w),
                        Expanded(
                          child: Text(
                            'How you earned this',
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2D3032),
                              letterSpacing: -0.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 17.sp,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF626262),
                          letterSpacing: -0.2,
                        ),
                        children: const <TextSpan>[
                          TextSpan(text: 'You reached the '),
                          TextSpan(
                            text: 'Top 3 in the\nGold League',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFA76500),
                            ),
                          ),
                          TextSpan(
                            text:
                                ' for 4 consecutive\nweeks. Remarkable consistency!',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 39.h),

              Container(
                width: double.infinity,
                height: 138.h,
                padding: EdgeInsets.fromLTRB(26.w, 24.h, 22.w, 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(42.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 16.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F3FF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        size: 29.r,
                        color: const Color(0xFF0067A7),
                      ),
                    ),
                    SizedBox(width: 22.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Delivery\nConfirmed',
                            style: TextStyle(
                              fontSize: 18.sp,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2D3032),
                              letterSpacing: -0.35,
                            ),
                          ),
                          SizedBox(height: 7.h),
                          Text(
                            'Signed by: Arif on\nSept 22',
                            style: TextStyle(
                              fontSize: 13.sp,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF626262),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: const BoxDecoration(
                        color: green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 18.r,
                        color: Colors.white,
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
