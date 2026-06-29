import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../guide_controller.dart';
import '../models/guide_faq_item.dart';
import '../widgets/guide_faq_video_player.dart';

class GuideFaqView extends GetView<GuideController> {
  const GuideFaqView({super.key});

  static const Color _backgroundColor = Color(0xFFF5F5F5);
  static const Color _green = Color(0xFF267A05);
  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF626262);

  @override
  Widget build(BuildContext context) {
    final String? faqId = Get.arguments as String?;
    final GuideFaqItem faq = controller.getFaqById(faqId);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 42.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _FaqTopBar(),
              SizedBox(height: 34.h),
              Text(
                faq.category,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                  color: _green,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                faq.title,
                style: TextStyle(
                  fontSize: 30.sp,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  color: _text,
                  letterSpacing: -0.95,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                faq.description,
                style: TextStyle(
                  fontSize: 18.sp,
                  height: 1.48,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                  letterSpacing: -0.2,
                ),
              ),
              if (faq.hasVideo) ...<Widget>[
                SizedBox(height: 36.h),
                GuideFaqVideoPlayer(assetPath: faq.videoAssetPath!),
              ],
              SizedBox(height: 42.h),
              Column(
                children: faq.steps
                    .map(
                      (GuideStepItem step) => Padding(
                        padding: EdgeInsets.only(bottom: 32.h),
                        child: _StepBlock(step: step),
                      ),
                    )
                    .toList(),
              ),
              if (faq.hasExpertTip) ...<Widget>[
                SizedBox(height: 8.h),
                _ExpertTipCard(text: faq.expertTip!),
                SizedBox(height: 40.h),
              ] else
                SizedBox(height: 8.h),
              _SupportCard(onTap: controller.chatWithSupport),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTopBar extends StatelessWidget {
  const _FaqTopBar();

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
            'FAQ',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: _green,
              letterSpacing: -0.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBlock extends StatelessWidget {
  final GuideStepItem step;

  const _StepBlock({required this.step});

  static const Color _text = Color(0xFF2D3032);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 48.r,
          height: 48.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: step.color,
            shape: BoxShape.circle,
          ),
          child: Text(
            step.number,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: step.textColor,
            ),
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 20.sp,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  color: _text,
                  letterSpacing: -0.35,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                step.description,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.48,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF626262),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpertTipCard extends StatelessWidget {
  final String text;

  const _ExpertTipCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 30.h, 32.w, 30.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F0FF),
        borderRadius: BorderRadius.circular(42.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 24.r,
                color: const Color(0xFF005A94),
              ),
              SizedBox(width: 10.w),
              Text(
                'EXPERT TIP',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: const Color(0xFF005A94),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF005A94),
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SupportCard({required this.onTap});

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 34.h, 32.w, 28.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(42.r),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Still have questions?',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3032),
              letterSpacing: -0.45,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Our support team is ready to help with any issue not covered in this guide.',
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF626262),
            ),
          ),
          SizedBox(height: 28.h),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 62.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(100.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF155200),
                    blurRadius: 0,
                    offset: Offset(0, 7.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 24.r,
                    color: Colors.white,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Chat with Support',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 7.h),
        ],
      ),
    );
  }
}
