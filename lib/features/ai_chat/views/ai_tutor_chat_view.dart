import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../controllers/ai_chat_controller.dart';
import 'widgets/ai_tutor_common_widgets.dart';

class AiTutorChatView extends GetView<AiChatController> {
  const AiTutorChatView({super.key});

  @override
  AiChatController get controller => Get.find<AiChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                const AiTutorHeader(),
                Expanded(
                  child: Obx(() {
                    final bool isVoice = controller.chatMode.value == 'voice';
                    final List<Map<String, dynamic>> messages = isVoice
                        ? controller.voiceMessages
                        : controller.textMessages;

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        24.w,
                        29.h,
                        24.w,
                        controller.isRecording.value ? 318.h : 102.h,
                      ),
                      children: <Widget>[
                        const AiTutorDateChip(),
                        SizedBox(height: 26.h),
                        ...messages.map((Map<String, dynamic> message) {
                          if (message['type'] == 'voice') {
                            return _VoiceMessageBubble(message: message);
                          }
                          return _TextMessageBubble(message: message);
                        }),
                        if (isVoice) ...<Widget>[
                          SizedBox(height: 16.h),
                          const AiTutorTypingDots(),
                        ],
                      ],
                    );
                  }),
                ),
              ],
            ),
            Obx(
              () => controller.isRecording.value
                  ? const _RecordingPanel()
                  : Positioned(
                      left: 24.w,
                      right: 24.w,
                      bottom: 22.h,
                      child: AiTutorInputBar(
                        onEqTap: controller.openLiveVoiceSession,
                        controller: controller.inputController,
                        inputText: controller.inputText.value,
                        onChanged: controller.onInputChanged,
                        onSendTap: controller.sendTextFromChat,
                        onMicTap: controller.startRecording,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceMessageBubble extends GetView<AiChatController> {
  final Map<String, dynamic> message;

  const _VoiceMessageBubble({required this.message});

  @override
  AiChatController get controller => Get.find<AiChatController>();

  @override
  Widget build(BuildContext context) {
    final bool isUser = message['sender'] == 'user';
    final int id = message['id'] as int;
    final bool hasTranscript = !isUser;

    return Obx(() {
      final bool expanded = controller.expandedTranscriptIds.contains(id);

      return Padding(
        padding: EdgeInsets.only(bottom: 22.h),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 46.h,
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 12.w, 6.h),
              constraints: BoxConstraints(minWidth: 145.w, maxWidth: 215.w),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFDDF8D2) : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                  bottomLeft: isUser ? Radius.circular(24.r) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : Radius.circular(24.r),
                ),
                boxShadow: isUser
                    ? const <BoxShadow>[]
                    : <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 14.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 31.r,
                    height: 31.r,
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFF7FFF4)
                          : const Color(0xFFEAFADD),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 21.r,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AiTutorWaveform(
                      activeColor: isUser
                          ? AppColors.primaryGreen
                          : const Color(0xFF8FDB78),
                      width: 72,
                      height: 23,
                      dense: true,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    message['duration'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8F9693),
                    ),
                  ),
                ],
              ),
            ),
            if (hasTranscript) ...<Widget>[
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () => controller.toggleTranscript(id),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      expanded ? 'HIDE TRANSCRIPTION' : 'SHOW TRANSCRIPTION',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                        color: const Color(0xFFB1B8B5),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 15.r,
                      color: const Color(0xFFB1B8B5),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: expanded
                    ? Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: _TranscriptBox(message: message),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _TranscriptBox extends StatelessWidget {
  final Map<String, dynamic> message;

  const _TranscriptBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final String original =
        message['transcriptOriginal'] as String? ??
        'Ciao! Sto bene, grazie. Certo, iniziamo con i saluti formali.';
    final String translation =
        message['transcriptBangla'] as String? ??
        'Hello! I am good, thanks. Sure, we start with formal greetings.';

    return Container(
      width: 210.w,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAFADD),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              original,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.45,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E3935),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE7ECEA)),
            ),
            child: Text(
              translation,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6C7672),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextMessageBubble extends GetView<AiChatController> {
  final Map<String, dynamic> message;

  const _TextMessageBubble({required this.message});

  @override
  AiChatController get controller => Get.find<AiChatController>();

  @override
  Widget build(BuildContext context) {
    final bool isUser = message['sender'] == 'user';
    final int id = message['id'] as int;

    return Obx(() {
      final bool expanded = controller.expandedTranslationIds.contains(id);

      return Padding(
        padding: EdgeInsets.only(bottom: 21.h),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(maxWidth: isUser ? 240.w : 205.w),
              padding: EdgeInsets.fromLTRB(15.w, 13.h, 15.w, 12.h),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFDDF8D2) : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: isUser ? Radius.circular(18.r) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : Radius.circular(18.r),
                ),
                boxShadow: isUser
                    ? const <BoxShadow>[]
                    : <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 12.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message['primary'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.38,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF26312E),
                    ),
                  ),
                  if (!isUser) ...<Widget>[
                    SizedBox(height: 13.h),
                    Row(
                      children: <Widget>[
                        _BubbleActionIcon(
                          icon: Icons.volume_up_rounded,
                          onTap: () {},
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => controller.toggleTranslations(id),
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            expanded
                                ? Icons.visibility_off_rounded
                                : Icons.remove_red_eye_rounded,
                            size: 16.r,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!isUser)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: expanded
                    ? Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: _TranslationCard(message: message),
                      )
                    : const SizedBox.shrink(),
              ),
            SizedBox(height: 6.h),
            Text(
              message['time'] as String? ?? '',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFA7AFAB),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TranslationCard extends StatelessWidget {
  final Map<String, dynamic> message;

  const _TranslationCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final String english = message['english'] as String? ?? 'A coffee, please.';
    final String other =
        message['bangla'] as String? ?? 'Ek cup coffee, please.';

    return Container(
      width: 200.w,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _LanguageLine(label: 'ENGLISH', text: english),
          SizedBox(height: 10.h),
          _LanguageLine(label: 'BENGALI', text: other),
        ],
      ),
    );
  }
}

class _LanguageLine extends StatelessWidget {
  final String label;
  final String text;

  const _LanguageLine({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
            color: const Color(0xFFC2C8C5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6D7672),
          ),
        ),
      ],
    );
  }
}

class _BubbleActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BubbleActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22.r,
        height: 22.r,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7EA),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 12.r, color: AppColors.primaryGreen),
      ),
    );
  }
}

class _RecordingPanel extends GetView<AiChatController> {
  const _RecordingPanel();

  @override
  AiChatController get controller => Get.find<AiChatController>();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 290.h,
        padding: EdgeInsets.fromLTRB(38.w, 22.h, 38.w, 26.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34.r)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 28.r,
              offset: Offset(0, -8.h),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4566),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 7.w),
                Text(
                  'RECORDING...',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                    color: const Color(0xFF8F9693),
                  ),
                ),
                const Spacer(),
                Text(
                  '0:04',
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF26312E),
                  ),
                ),
                SizedBox(width: 26.w),
                GestureDetector(
                  onTap: controller.cancelRecording,
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.r,
                    color: const Color(0xFF88908C),
                  ),
                ),
              ],
            ),
            SizedBox(height: 34.h),
            AiTutorWaveform(
              activeColor: AppColors.primaryGreen,
              inactiveColor: const Color(0xFFE1E8DE),
              width: 185,
              height: 75,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _RoundControlButton(
                  icon: Icons.play_arrow_rounded,
                  size: 42,
                  iconColor: AppColors.primaryGreen,
                  bgColor: const Color(0xFFE8F9DD),
                  onTap: () {},
                ),
                SizedBox(width: 28.w),
                _RoundControlButton(
                  icon: Icons.mic_rounded,
                  size: 67,
                  iconColor: AppColors.primaryGreen,
                  bgColor: const Color(0xFFDFF8D2),
                  onTap: () {},
                ),
                SizedBox(width: 28.w),
                _RoundControlButton(
                  icon: Icons.send_rounded,
                  size: 42,
                  iconColor: AppColors.primaryGreen,
                  bgColor: const Color(0xFFE8F9DD),
                  onTap: controller.sendRecording,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _RoundControlButton({
    required this.icon,
    required this.size,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.r,
        height: size.r,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: (size * .42).r, color: iconColor),
      ),
    );
  }
}
