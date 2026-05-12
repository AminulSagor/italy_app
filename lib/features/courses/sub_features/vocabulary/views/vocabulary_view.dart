import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary_models.dart';

class VocabularyView extends GetView<VocabularyController> {
  final String controllerTag;

  const VocabularyView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.coursesDetailBg,
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          final VocabularySessionModel? session = controller.session.value;
          final VocabularyCardModel? card = controller.currentCard;

          if (controller.isLoading.value && session == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (session == null || card == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              kVocabularyHorizontalPadding.w,
              34.h,
              kVocabularyHorizontalPadding.w,
              48.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _VocabularyHeader(
                  title: session.title,
                  cardLabel: 'Card ${controller.currentCardNumber} of ${controller.totalCards}',
                  onBackTap: controller.showExitConfirmation,
                ),
                SizedBox(height: 50.h),
                _VocabularyProgressBar(value: controller.progressValue),
                SizedBox(height: 76.h),
                _VocabularyFlashCard(
                  card: card,
                  isRevealed: controller.isRevealed.value,
                  onTap: controller.flipCard,
                ),
                SizedBox(height: 108.h),
                _VocabularyStats(
                  streakDays: session.streakDays,
                  level: session.level,
                ),
                SizedBox(height: 64.h),
                if (controller.isRevealed.value)
                  _VocabularyRevealedActions(
                    onStudyAgainTap: controller.studyAgain,
                    onKnownTap: controller.markKnown,
                  )
                else
                  CustomButton.primary(
                    onPressed: controller.revealAnswer,
                    text: 'Reveal Answer',
                    icon: Icons.visibility_outlined,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _VocabularyHeader extends StatelessWidget {
  final String title;
  final String cardLabel;
  final VoidCallback onBackTap;

  const _VocabularyHeader({
    required this.title,
    required this.cardLabel,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onBackTap,
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primaryGreen,
            size: 30.w,
          ),
        ),
        SizedBox(width: 32.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: AppFont.font30.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        Text(
          cardLabel,
          style: TextStyle(
            fontSize: AppFont.font24.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }
}

class _VocabularyProgressBar extends StatelessWidget {
  final double value;

  const _VocabularyProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: LinearProgressIndicator(
        value: value,
        minHeight: kVocabularyProgressHeight.h,
        color: AppColors.primaryGreen,
        backgroundColor: AppColors.vocabularyProgressTrack,
      ),
    );
  }
}

class _VocabularyFlashCard extends StatelessWidget {
  final VocabularyCardModel card;
  final bool isRevealed;
  final VoidCallback onTap;

  const _VocabularyFlashCard({
    required this.card,
    required this.isRevealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: isRevealed ? math.pi : 0),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
        builder: (BuildContext context, double angle, Widget? child) {
          final bool showBack = angle > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(showBack ? math.pi : 0),
              child: Container(
                width: double.infinity,
                height: kVocabularyCardHeight.h,
                padding: EdgeInsets.fromLTRB(36.w, 44.h, 36.w, 44.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(kVocabularyCardRadius.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.vocabularyCardShadow,
                      blurRadius: 42.r,
                      offset: Offset(0, 22.h),
                    ),
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _VocabularyAudioButton(onTap: () {}),
                    ),
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 140),
                        child: showBack
                            ? _VocabularyBackSide(
                                card: card,
                                key: const ValueKey<String>('back'),
                              )
                            : _VocabularyFrontSide(
                                card: card,
                                key: const ValueKey<String>('front'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VocabularyAudioButton extends StatelessWidget {
  final VoidCallback onTap;

  const _VocabularyAudioButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: kVocabularyAudioButtonSize.w,
        height: kVocabularyAudioButtonSize.w,
        decoration: const BoxDecoration(
          color: AppColors.homePaleGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.volume_up_rounded,
          size: 46.w,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _VocabularyFrontSide extends StatelessWidget {
  final VocabularyCardModel card;

  const _VocabularyFrontSide({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          card.word,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font64.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryGreen,
            height: 1,
          ),
        ),
        SizedBox(height: 34.h),
        Text(
          card.languageLabel,
          style: TextStyle(
            fontSize: AppFont.font22.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: 118.h),
        Icon(
          Icons.pan_tool_alt_outlined,
          size: 34.w,
          color: AppColors.bodyText,
        ),
        SizedBox(height: 14.h),
        Text(
          'TAP CARD TO FLIP',
          style: TextStyle(
            fontSize: AppFont.font20.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }
}

class _VocabularyBackSide extends StatelessWidget {
  final VocabularyCardModel card;

  const _VocabularyBackSide({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          card.word,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font56.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.homePrimaryText,
            height: 1,
          ),
        ),
        SizedBox(height: 54.h),
        Text(
          card.meaning,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font36.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.vocabularyBlueText,
            height: 1.15,
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          card.example,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font28.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }
}

class _VocabularyStats extends StatelessWidget {
  final int streakDays;
  final int level;

  const _VocabularyStats({required this.streakDays, required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _VocabularyStatText(
            icon: Icons.local_fire_department_rounded,
            label: '$streakDays DAY STREAK',
            color: AppColors.vocabularyStreakText,
          ),
        ),
        Expanded(
          child: _VocabularyStatText(
            icon: Icons.emoji_events_outlined,
            label: 'LEVEL $level',
            color: AppColors.vocabularyBlueText,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _VocabularyStatText extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool alignEnd;

  const _VocabularyStatText({
    required this.icon,
    required this.label,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: color, size: 30.w),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _VocabularyRevealedActions extends StatelessWidget {
  final VoidCallback onStudyAgainTap;
  final VoidCallback onKnownTap;

  const _VocabularyRevealedActions({
    required this.onStudyAgainTap,
    required this.onKnownTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            onPressed: onStudyAgainTap,
            text: 'Study Again',
            height: kVocabularyBottomButtonHeight,
            icon: Icons.refresh_rounded,
            showShadow: true,
            btnColor: AppColors.vocabularyOrange,
            btnShadowColor: AppColors.vocabularyOrangeShadow,
            borderColor: AppColors.vocabularyOrange,
            textColor: AppColors.white,
            borderRadius: kRadius42,
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: CustomButton.primary(
            onPressed: onKnownTap,
            text: 'I Know This',
            icon: Icons.check_circle_rounded,
            borderRadius: kRadius42,
          ),
        ),
      ],
    );
  }
}
