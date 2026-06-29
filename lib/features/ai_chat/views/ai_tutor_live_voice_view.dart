import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/ai_chat_controller.dart';
import '../services/ai_tutor_voice_service.dart';
import 'widgets/ai_tutor_common_widgets.dart';

class AiTutorLiveVoiceView extends StatefulWidget {
  const AiTutorLiveVoiceView({super.key});

  @override
  State<AiTutorLiveVoiceView> createState() => _AiTutorLiveVoiceViewState();
}

class _AiTutorLiveVoiceViewState extends State<AiTutorLiveVoiceView> {
  AiChatController get controller => Get.find<AiChatController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(controller.ensureLiveVoiceConnected());
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.handleLiveVoiceSystemBack,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFFFF0),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              const Positioned.fill(child: _VoiceBackground()),
              Column(
                children: <Widget>[
                  Obx(
                    () => AiTutorHeader(
                      lightBackground: true,
                      backEnabled: !controller.isLiveVoiceConnecting,
                      onBackTap: () =>
                          unawaited(controller.closeLiveVoicePage()),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      final AiTutorVoiceService voice = controller.voiceService;
                      final bool connecting = controller.isLiveVoiceConnecting;
                      final bool failed = voice.connectionState.value ==
                          AiTutorVoiceConnectionState.error;
                      final String assistantText =
                          voice.assistantThinking.value
                              ? ''
                              : voice.latestAssistantMessage?.primary ?? '';
                      final String userText =
                          voice.latestUserMessage?.primary ?? '';

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(24.w, 46.h, 24.w, 175.h),
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: _SessionStatusChip(
                                label: voice.status.value,
                                active: voice.isConnected,
                              ),
                            ),
                            SizedBox(height: 46.h),
                            if (connecting)
                              SizedBox(
                                width: 54.r,
                                height: 54.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: AppColors.primaryGreen,
                                ),
                              )
                            else
                              AiTutorWaveform(
                                activeColor: AppColors.primaryGreen,
                                inactiveColor: AppColors.primaryGreen.withValues(
                                  alpha: .14,
                                ),
                                width: 118,
                                height: 126,
                                animate: voice.isConnected &&
                                    (voice.assistantSpeaking.value ||
                                        voice.userSpeaking.value),
                                thinking: voice.assistantThinking.value,
                                audioLevel: voice.activeAudioLevel,
                              ),
                            SizedBox(height: 42.h),
                            if (assistantText.isNotEmpty)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 140),
                                child: Text(
                                  assistantText,
                                  key: ValueKey<String>(assistantText),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppFont.font22.sp,
                                    height: 1.22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.6,
                                    color: const Color(0xFF26312E),
                                  ),
                                ),
                              ),
                            if (userText.isNotEmpty) ...<Widget>[
                              SizedBox(height: 24.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 11.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: .75),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: Text(
                                  userText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF6E7874),
                                  ),
                                ),
                              ),
                            ],
                            if (failed) ...<Widget>[
                              SizedBox(height: 24.h),
                              OutlinedButton.icon(
                                onPressed: controller.retryLiveVoice,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try again'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _LiveVoiceControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceBackground extends StatelessWidget {
  const _VoiceBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
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
    );
  }
}


class _SessionStatusChip extends StatelessWidget {
  const _SessionStatusChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250.w),
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD9FFC8) : AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: active
              ? const Color.fromARGB(96, 42, 105, 0)
              : const Color(0xFFE0E5E1),
          width: 1.2.r,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryGreen
                  : const Color(0xFF9AA29F),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
                color: active
                    ? AppColors.primaryGreen
                    : const Color(0xFF7D8783),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveVoiceControls extends GetView<AiChatController> {
  const _LiveVoiceControls();

  @override
  AiChatController get controller => Get.find<AiChatController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      padding: EdgeInsets.fromLTRB(34.w, 24.h, 34.w, 30.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 34.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: Obx(() {
        final AiTutorVoiceService voice = controller.voiceService;
        final bool busy = controller.isLiveVoiceConnecting;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _SmallControlButton(
              icon: Icons.keyboard_alt_outlined,
              color: const Color(0xFF77807C),
              enabled: !busy && !controller.isGuidedVoiceSession,
              onTap: controller.switchLiveVoiceToText,
            ),
            GestureDetector(
              onTap: busy
                  ? null
                  : voice.isConnected
                      ? controller.toggleLiveVoiceMute
                      : controller.retryLiveVoice,
              child: Container(
                width: 74.r,
                height: 74.r,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: busy
                    ? Padding(
                        padding: EdgeInsets.all(22.r),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        voice.isMuted.value
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        size: 35.r,
                        color: AppColors.white,
                      ),
              ),
            ),
            _SmallControlButton(
              icon: Icons.call_end_rounded,
              color: const Color(0xFFFF4B4B),
              enabled: !busy,
              onTap: controller.closeLiveVoicePage,
            ),
          ],
        );
      }),
    );
  }
}

class _SmallControlButton extends StatelessWidget {
  const _SmallControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Color color;
  final FutureOr<void> Function() onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onTap() : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : .3,
        child: SizedBox(
          width: 48.r,
          height: 48.r,
          child: Icon(icon, size: 24.r, color: color),
        ),
      ),
    );
  }
}
