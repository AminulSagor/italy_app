import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/ai_chat_controller.dart';

class AiLevelTestView extends GetView<AiChatController> {
  const AiLevelTestView({super.key});

  @override
  AiChatController get controller {
    if (Get.isRegistered<AiChatController>()) {
      return Get.find<AiChatController>();
    }
    return Get.put<AiChatController>(AiChatController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(50.w, 29.h, 50.w, 175.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _LevelTestHeader(title: 'Level Test'),
                  SizedBox(height: 29.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(25.w, 33.h, 25.w, 31.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(31.r),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Discover your exact\nlevel.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.sp,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'তুমি এখন কোন লেভেলে আছো? মাত্র ৩০টি প্রশ্নের\nমাধ্যমে তোমার দক্ষতা যাচাই করো।',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 35.h),
                  Text(
                    'WHAT WE MEASURE:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.7,
                      color: const Color(0xFF686E6B),
                    ),
                  ),
                  SizedBox(height: 17.h),
                  const _MeasureCard(
                    icon: Icons.mic_rounded,
                    iconColor: Color(0xFF1376FF),
                    iconBg: Color(0xFFE7F0FF),
                    title: 'Speaking',
                    subtitle: 'Pronunciation & Fluency',
                  ),
                  SizedBox(height: 17.h),
                  const _MeasureCard(
                    icon: Icons.chat_bubble_rounded,
                    iconColor: Color(0xFFE93838),
                    iconBg: Color(0xFFFFE5E5),
                    title: 'Vocabulary',
                    subtitle: 'Word knowledge & Context',
                  ),
                  SizedBox(height: 17.h),
                  const _MeasureCard(
                    icon: Icons.menu_book_rounded,
                    iconColor: Color(0xFF24A75A),
                    iconBg: Color(0xFFDDF9E7),
                    title: 'Grammar',
                    subtitle: 'Sentence structure & Verbs',
                  ),
                ],
              ),
            ),
            Positioned(
              left: 30.w,
              right: 30.w,
              bottom: 0,
              child: Container(
                height: 149.h,
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(34.r),
                    //radius: Radius.circular(13.r),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.025),
                      blurRadius: 16.r,
                      offset: Offset(0, -6.h),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    _GreenPillButton(
                      text: 'Start Level Test',
                      onTap: controller.startLevelTest,
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 12.r,
                          color: const Color(0xFF808784),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Takes 3 minutes. Your results are private.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF808784),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: .h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiLevelTestResultView extends GetView<AiChatController> {
  const AiLevelTestResultView({super.key});

  @override
  AiChatController get controller {
    if (Get.isRegistered<AiChatController>()) {
      return Get.find<AiChatController>();
    }
    return Get.put<AiChatController>(AiChatController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 70.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.back<void>(),
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E3E5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 29.r,
                      color: const Color(0xFF33383C),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 37.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(46.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.18),
                      blurRadius: 25.r,
                      offset: Offset(0, 13.h),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      'YOUR FINAL LEVEL:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.1,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 13.h),
                    Text(
                      'Level A1+',
                      style: TextStyle(
                        fontSize: 50.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.8,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 21.h),
                    Text(
                      'অভিনন্দন! আপনার বর্তমান লার্নিং লেভেল A1+\nনির্ধারণ করা হয়েছে।',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withValues(alpha: 0.84),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 31.h),
              Text(
                'DETAILED SKILL BREAKDOWN',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.3,
                  color: const Color(0xFF5E6562),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: const <Widget>[
                  Expanded(
                    child: _SkillMiniCard(
                      color: Color(0xFFDDF1FF),
                      iconColor: Color(0xFF09649F),
                      icon: Icons.mic_rounded,
                      text: 'Speaking: A1',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _SkillMiniCard(
                      color: Color(0xFFFFEFD8),
                      iconColor: Color(0xFF8A4D00),
                      icon: Icons.chat_bubble_rounded,
                      text: 'Vocabulary: A1',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(30.w, 28.h, 30.w, 28.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDFCE7),
                  borderRadius: BorderRadius.circular(44.r),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 54.r,
                      height: 54.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFFFF0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 29.r,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    SizedBox(width: 21.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'KNOWLEDGE BASE',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: const Color(0xFF5B9B43),
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          'Grammar: A2',
                          style: TextStyle(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: const Color(0xFF25463B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
              CustomPaint(
                painter: _DashedRRectPainter(
                  color: const Color(0xFFBAD8AE),
                  radius: 34.r,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(25.w, 26.h, 25.w, 27.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 47.r,
                        height: 47.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF8E8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 24.r,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 15.sp,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5B6360),
                            ),
                            children: const <TextSpan>[
                              TextSpan(text: 'Your grammar '),
                              TextSpan(
                                text: '(A2)',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' is great, but speaking and vocabulary need practice. We’ve customized your lessons to fix this!',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 33.h),
              _GreenPillButton(
                text: 'Continue To AI Chat',
                onTap: controller.continueAfterLevelTest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelTestHeader extends StatelessWidget {
  final String title;

  const _LevelTestHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Get.back<void>(),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24.r,
                color: const Color(0xFF193F34),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF173F33),
                ),
              ),
            ),
          ),
          SizedBox(width: 40.r),
        ],
      ),
    );
  }
}

class _MeasureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _MeasureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 87.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 17.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 30.r, color: iconColor),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF303635),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF636A67),
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

class _SkillMiniCard extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String text;

  const _SkillMiniCard({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(38.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 44.r, color: iconColor),
          SizedBox(height: 19.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF114638),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenPillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GreenPillButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(31.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF123F00),
              blurRadius: 0,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Icon(Icons.play_arrow_rounded, size: 24.r, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final ui.PathMetric metric = path.computeMetrics().first;

    double distance = 0;
    const double dash = 6;
    const double gap = 5;

    while (distance < metric.length) {
      final Path extractPath = metric.extractPath(distance, distance + dash);
      canvas.drawPath(extractPath, paint);
      distance += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
