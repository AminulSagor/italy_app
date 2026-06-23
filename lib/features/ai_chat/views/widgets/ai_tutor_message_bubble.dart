import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../controllers/ai_chat_controller.dart';
import '../../models/ai_tutor_models.dart';

class AiTutorMessageBubble extends GetView<AiChatController> {
  const AiTutorMessageBubble({
    super.key,
    required this.message,
  });

  final AiTutorMessageModel message;

  @override
  AiChatController get controller => Get.find<AiChatController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool expanded =
          controller.expandedTranslationIds.contains(message.id);
      final bool hasTranslations =
          (message.english?.isNotEmpty ?? false) ||
          (message.bangla?.isNotEmpty ?? false);

      return Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 285.w),
          margin: EdgeInsets.only(bottom: 13.h),
          child: Column(
            crossAxisAlignment: message.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 13.h, 16.w, 12.h),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? const Color(0xFFDFF8D2)
                      : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                    bottomLeft: Radius.circular(message.isUser ? 18.r : 5.r),
                    bottomRight: Radius.circular(message.isUser ? 5.r : 18.r),
                  ),
                  boxShadow: message.isUser
                      ? const <BoxShadow>[]
                      : <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .04),
                            blurRadius: 12.r,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            message.primary,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.42,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF26312E),
                            ),
                          ),
                        ),
                        if (!message.isUser) ...<Widget>[
                          SizedBox(width: 8.w),
                          _ItalianSpeechButton(
                            isSpeaking:
                                controller.speakingMessageId.value == message.id,
                            onTap: () =>
                                controller.toggleItalianSpeech(message),
                          ),
                        ],
                      ],
                    ),
                    if (!message.isUser && hasTranslations) ...<Widget>[
                      SizedBox(height: 11.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () =>
                              controller.toggleTranslations(message.id),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                expanded
                                    ? Icons.visibility_off_rounded
                                    : Icons.translate_rounded,
                                size: 16.r,
                                color: AppColors.primaryGreen,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                expanded ? 'Hide meaning' : 'Show meaning',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!message.isUser && expanded && hasTranslations)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: _TranslationCard(message: message),
                ),
              if (!message.isUser && message.correction?.isValid == true)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: _CorrectionCard(correction: message.correction!),
                ),
              SizedBox(height: 5.h),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFA7AFAB),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatTime(DateTime dateTime) {
    final DateTime local = dateTime.toLocal();
    final int hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final String minute = local.minute.toString().padLeft(2, '0');
    final String period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}


class _CorrectionCard extends StatelessWidget {
  const _CorrectionCard({required this.correction});

  final AiTutorCorrectionModel correction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 285.w,
      padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF2),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFFFDFAF),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.auto_fix_high_rounded,
                size: 15.r,
                color: const Color(0xFFE67A00),
              ),
              SizedBox(width: 6.w),
              Text(
                'QUICK CORRECTION',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                  color: const Color(0xFFE67A00),
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          _CorrectionSentence(
            icon: Icons.close_rounded,
            iconColor: const Color(0xFFE45353),
            text: correction.original,
          ),
          SizedBox(height: 7.h),
          _CorrectionSentence(
            icon: Icons.check_rounded,
            iconColor: AppColors.primaryGreen,
            text: correction.corrected,
          ),
          SizedBox(height: 11.h),
          Text(
            correction.explanation,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF59635F),
            ),
          ),
          if (correction.rule?.trim().isNotEmpty == true) ...<Widget>[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                correction.rule!.trim(),
                style: TextStyle(
                  fontSize: 10.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6D5A3E),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CorrectionSentence extends StatelessWidget {
  const _CorrectionSentence({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 20.r,
          height: 20.r,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 13.r, color: iconColor),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF35413D),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItalianSpeechButton extends StatelessWidget {
  const _ItalianSpeechButton({
    required this.isSpeaking,
    required this.onTap,
  });

  final bool isSpeaking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.r,
        height: 30.r,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: .1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
          size: 17.r,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  const _TranslationCard({required this.message});

  final AiTutorMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235.w,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7ED),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (message.english?.isNotEmpty ?? false)
            _LanguageLine(label: 'ENGLISH', text: message.english!),
          if ((message.english?.isNotEmpty ?? false) &&
              (message.bangla?.isNotEmpty ?? false))
            SizedBox(height: 10.h),
          if (message.bangla?.isNotEmpty ?? false)
            _LanguageLine(label: 'BENGALI', text: message.bangla!),
        ],
      ),
    );
  }
}

class _LanguageLine extends StatelessWidget {
  const _LanguageLine({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
            color: const Color(0xFF9AA29F),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF59635F),
          ),
        ),
      ],
    );
  }
}

class AiTutorThinkingBubble extends StatelessWidget {
  const AiTutorThinkingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 13.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: SizedBox(
          width: 18.r,
          height: 18.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}
