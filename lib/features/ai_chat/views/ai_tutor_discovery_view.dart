import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/ai_chat_controller.dart';
import 'widgets/ai_tutor_common_widgets.dart';

class AiTutorDiscoveryView extends GetView<AiChatController> {
  const AiTutorDiscoveryView({super.key});

  @override
  AiChatController get controller => Get.find<AiChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F1),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                const AiTutorHeader(),
                Expanded(
                  child: Obx(
                    () => SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(24.w, 44.h, 24.w, 112.h),
                      child: Column(
                        children: <Widget>[
                          const _HeroIcon(),
                          SizedBox(height: 22.h),
                          Text(
                            'Ciao!',
                            style: TextStyle(
                              fontSize: 30.sp,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 11.h),
                          Text(
                            "I am your AI Tutor. Let's practice\nItalian together.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5F6965),
                            ),
                          ),
                          SizedBox(height: 45.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'CONVERSATION STARTERS',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: const Color(0xFF8A918E),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...controller.visibleStarters.map((
                            Map<String, dynamic> starter,
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 13.h),
                              child: _StarterCard(
                                starter: starter,
                                onTap: () => controller.onStarterTap(starter),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 22.h,
              child: Obx(
                () => AiTutorInputBar(
                  controller: controller.inputController,
                  inputText: controller.inputText.value,
                  onChanged: controller.onInputChanged,
                  onSendTap: controller.sendTextFromDiscovery,
                  onMicTap: controller.openLiveVoiceSession,
                  onEqTap: controller.openLiveVoiceSession,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96.r,
        height: 96.r,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          shape: BoxShape.circle,
        ),
        child: Image.asset('assets/icons_png/handwave.png'),
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  final Map<String, dynamic> starter;
  final VoidCallback onTap;

  const _StarterCard({required this.starter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final IconData icon = starter['icon'] as IconData? ?? Icons.chat_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72.h,
        padding: EdgeInsets.fromLTRB(15.w, 0, 14.w, 0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 14.r,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 43.r,
              height: 43.r,
              decoration: const BoxDecoration(
                color: Color(0xFFEFFFDF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22.r, color: AppColors.primaryGreen),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    starter['title'] as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font13.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF32403B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    starter['subtitle'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 10.sp,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF909A96),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24.r,
              color: const Color(0xFFB7BEBA),
            ),
          ],
        ),
      ),
    );
  }
}
