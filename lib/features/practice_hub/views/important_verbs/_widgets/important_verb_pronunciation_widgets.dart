import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../controllers/important_verbs_controller.dart';
import '../../../models/important_verb_detail_models.dart';
import '../../../models/important_verb_models.dart';

class VerbConjugationCard extends StatelessWidget {
  const VerbConjugationCard({
    super.key,
    required this.conjugation,
    required this.highlighted,
  });

  final ImportantVerbConjugationModel conjugation;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final String pronoun = conjugation.pronounIt.isNotEmpty
        ? conjugation.pronounIt
        : conjugation.pronoun;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF7FBF4) : const Color(0xFFF7F9F7),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE8F1E2), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$pronoun ${conjugation.conjugatedText}'.trim(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              PronunciationButton(tts: conjugation.tts),
            ],
          ),
          if (conjugation.banglaMeaning.isNotEmpty ||
              conjugation.englishMeaning.isNotEmpty) ...<Widget>[
            SizedBox(height: 7.h),
            Text(
              _translationText(conjugation),
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF747A80),
              ),
            ),
          ],
          if (conjugation.examples.isNotEmpty) ...<Widget>[
            SizedBox(height: 12.h),
            ...conjugation.examples.map(VerbExampleTile.new),
          ],
        ],
      ),
    );
  }

  String _translationText(ImportantVerbConjugationModel item) {
    final String bangla = item.banglaMeaning;
    final String english = item.englishMeaning;
    if (bangla.isNotEmpty && english.isNotEmpty) return '$bangla ($english)';
    return bangla.isNotEmpty ? bangla : english;
  }
}

class VerbExampleTile extends StatelessWidget {
  const VerbExampleTile(this.example, {super.key});

  final ImportantVerbExampleModel example;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  example.italianText,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4A4F53),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              PronunciationButton(tts: example.tts),
            ],
          ),
          if (example.banglaText.isNotEmpty ||
              example.englishText.isNotEmpty) ...<Widget>[
            SizedBox(height: 7.h),
            Text(
              _exampleTranslation(example),
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF747A80),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _exampleTranslation(ImportantVerbExampleModel item) {
    if (item.banglaText.isNotEmpty && item.englishText.isNotEmpty) {
      return '${item.banglaText} (${item.englishText})';
    }
    return item.banglaText.isNotEmpty ? item.banglaText : item.englishText;
  }
}

class PronunciationButton extends GetView<ImportantVerbsController> {
  const PronunciationButton({
    super.key,
    required this.tts,
    this.large = false,
    this.foregroundColor,
    this.backgroundColor,
  });

  final ImportantVerbTtsModel tts;
  final bool large;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCurrent = controller.isSpeaking.value &&
          controller.speakingText.value == tts.text;
      final double size = large ? 50.r : 30.r;
      return GestureDetector(
        onTap: isCurrent ? null : () => controller.speak(tts),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? const Color(0xFFEFF9E9),
            shape: BoxShape.circle,
          ),
          child: isCurrent
              ? Padding(
                  padding: EdgeInsets.all(large ? 14.r : 8.r),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: foregroundColor ?? AppColors.primaryGreen,
                  ),
                )
              : Icon(
                  Icons.volume_up_rounded,
                  size: large ? 28.r : 17.r,
                  color: foregroundColor ?? AppColors.primaryGreen,
                ),
        ),
      );
    });
  }
}
