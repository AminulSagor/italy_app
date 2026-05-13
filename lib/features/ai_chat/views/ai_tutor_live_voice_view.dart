import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/ai_chat_controller.dart';
import 'widgets/ai_tutor_common_widgets.dart';

class AiTutorLiveVoiceView extends GetView<AiChatController> {
  const AiTutorLiveVoiceView({super.key});

  @override
  AiChatController get controller => Get.find<AiChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFF0),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color.fromARGB(144, 187, 248, 181),
                      Color(0xFFF9FBFA),
                      Color.fromARGB(255, 196, 252, 194),
                    ],
                    stops: <double>[0, .55, 1],
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                const AiTutorHeader(lightBackground: true),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 82.h, 24.w, 188.h),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 24.h,
                          padding: EdgeInsets.symmetric(horizontal: 13.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9FFC8),
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(
                              color: const Color.fromARGB(96, 42, 105, 0),
                              width: 1.5.r,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'LIVE SESSION',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .8,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 54.h),
                        AiTutorWaveform(
                          activeColor: AppColors.primaryGreen,
                          inactiveColor: AppColors.primaryGreen.withValues(
                            alpha: .14,
                          ),
                          width: 118,
                          height: 126,
                        ),
                        SizedBox(height: 54.h),
                        Text(
                          '"Ciao! Come posso aiutarti\noggi con il tuo italiano?"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font22.sp,
                            height: 1.18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.7,
                            color: const Color(0xFF26312E),
                          ),
                        ),
                        SizedBox(height: 26.h),
                        Text(
                          '"Hello! How can I help you with your Italian\ntoday?"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.sp,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7D8783),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          '"হ্যালো! আজ আপনার ইতালীয় ভাষায় কীভাবে সাহায্য করতে পারি?"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.sp,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7D8783),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 150.h,
                padding: EdgeInsets.fromLTRB(34.w, 24.h, 34.w, 30.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: .95),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 34.r,
                      offset: Offset(0, -8.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _LiveSmallButton(
                      icon: Icons.keyboard_alt_outlined,
                      color: const Color(0xFF77807C),
                      onTap: () {
                        Get.back<void>();
                        controller.startTextConversation('I want to learn');
                      },
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 74.r,
                        height: 74.r,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic_rounded,
                          size: 35.r,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    _LiveSmallButton(
                      icon: Icons.call_end_rounded,
                      color: const Color(0xFFFF4B4B),
                      onTap: Get.back<void>,
                    ),
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

class _LiveSmallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LiveSmallButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48.r,
        height: 48.r,
        child: Icon(icon, size: 22.r, color: color),
      ),
    );
  }
}
