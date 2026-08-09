import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/native_bottom_inset.dart';
import '../controllers/ai_chat_controller.dart';
import '../models/ai_tutor_models.dart';
import 'ai_tutor_chat_view.dart';
import 'widgets/ai_tutor_common_widgets.dart';

class AiTutorDiscoveryView extends StatefulWidget {
  const AiTutorDiscoveryView({super.key});

  @override
  State<AiTutorDiscoveryView> createState() => _AiTutorDiscoveryViewState();
}

class _AiTutorDiscoveryViewState extends State<AiTutorDiscoveryView> {
  late final AiChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AiChatController>();
    _controller.prepareDiscoverySession();
  }

  @override
  void dispose() {
    _controller.resetTextConversation();
    super.dispose();
  }

  Future<bool> _handleSystemBack() async {
    if (_controller.isTextConversationActive.value) {
      _controller.resetTextConversation();
      return false;
    }
    _controller.resetTextConversation();
    return true;
  }

  void _handleHeaderBack() {
    if (_controller.isTextConversationActive.value) {
      _controller.resetTextConversation();
      return;
    }
    _controller.resetTextConversation();
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleSystemBack,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F1),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  AiTutorHeader(onBackTap: _handleHeaderBack),
                  Expanded(
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _controller.isTextConversationActive.value
                            ? const AiTutorChatContent()
                            : _DiscoveryStarterContent(
                                starters: _controller.visibleStarters,
                                onStarterTap: _controller.onStarterTap,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 24.w,
                right: 24.w,
                bottom: 0,
                child: NativeBottomInset(
                  additionalBottom: 22.h,
                  collapseWhenKeyboardVisible: true,
                  child: Obx(() {
                    final bool active =
                        _controller.isTextConversationActive.value;
                    final bool sending = _controller.isSendingMessage.value;

                    return IgnorePointer(
                      ignoring: sending,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: sending ? .65 : 1,
                        child: AiTutorInputBar(
                          controller: _controller.inputController,
                          inputText: _controller.inputText.value,
                          onChanged: _controller.onInputChanged,
                          onSendTap: active
                              ? _controller.sendTextFromChat
                              : _controller.sendTextFromDiscovery,
                          showVoiceAction: !active,
                          onVoiceTap: active
                              ? null
                              : () => _controller.openLiveVoiceSession(),
                          hint: active
                              ? 'ask_your_italian_tutor'.tr
                              : 'type_or_speak_a_phrase'.tr,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryStarterContent extends StatelessWidget {
  const _DiscoveryStarterContent({
    required this.starters,
    required this.onStarterTap,
  });

  final List<AiTutorStarterModel> starters;
  final ValueChanged<AiTutorStarterModel> onStarterTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey<String>('ai-tutor-discovery-content'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 44.h, 24.w, 112.h),
      child: Column(
        children: <Widget>[
          const _HeroIcon(),
          SizedBox(height: 22.h),
          Text(
            'ciao'.tr,
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
            'ai_tutor_intro'.tr,
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
              'conversation_starters'.tr,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: const Color(0xFF8A918E),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          ...starters.map((AiTutorStarterModel starter) {
            return Padding(
              padding: EdgeInsets.only(bottom: 13.h),
              child: _StarterCard(
                starter: starter,
                onTap: () => onStarterTap(starter),
              ),
            );
          }),
        ],
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
  const _StarterCard({required this.starter, required this.onTap});

  final AiTutorStarterModel starter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              child: Icon(
                starter.icon,
                size: 22.r,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    starter.title,
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
                    starter.subtitle,
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
