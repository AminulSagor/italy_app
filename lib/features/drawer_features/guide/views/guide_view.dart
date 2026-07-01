import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../guide_controller.dart';

class GuideView extends GetView<GuideController> {
  const GuideView({super.key});

  static const Color _bg = Color(0xFFF5F5F5);
  static const Color _green = Color(0xFF267A05);
  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _GuideTopBar(title: 'gen_guides'.tr.tr),
              SizedBox(height: 36.h),

              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.6,
                  color: _muted,
                ),
              ),

              SizedBox(height: 18.h),

              Column(
                children: controller.faqItems
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: _FaqTile(
                          title: item.title,
                          onTap: () => controller.openFaq(item.id),
                        ),
                      ),
                    )
                    .toList(),
              ),

              SizedBox(height: 18.h),

              _CommunityCard(onTap: controller.joinFacebookCommunity),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideTopBar extends StatelessWidget {
  final String title;

  const _GuideTopBar({required this.title});

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 25.r,
                  color: _green,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: _green,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _FaqTile({required this.title, required this.onTap});

  static const Color _text = Color(0xFF2D3032);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 64.h),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: _text,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 28.r,
              color: const Color(0xFFA5A5A5),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CommunityCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 128.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: const Color(0xFF2E3030),
          borderRadius: BorderRadius.circular(42.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 26.r,
              offset: Offset(0, 16.h),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: 8.w,
              bottom: 4.h,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 13.r,
                    height: 13.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Container(
                    width: 18.r,
                    height: 18.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5ADB00),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    size: 35.r,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Join our Facebook\nCommunity',
                        style: TextStyle(
                          fontSize: 18.sp,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.25,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Connect with 10k+ Bengali learners in Italy.',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
