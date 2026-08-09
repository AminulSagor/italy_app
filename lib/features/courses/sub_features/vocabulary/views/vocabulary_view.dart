import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary_models.dart';

class VocabularyView extends GetView<VocabularyController> {
  final String controllerTag;

  const VocabularyView({
    super.key,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
          bool didPop,
          Object? result,
          ) {
        if (didPop) {
          return;
        }

        controller.showExitConfirmation();
      },
      child: LearningActivityPageScope(
        activityKind: LearningActivityKind.vocabulary,
        sourceId: 'vocabulary_view',
        child: Material(
          color: AppColors.coursesDetailBg,
          child: SafeArea(
            child: Obx(() {
              final VocabularySessionModel? session =
                  controller.session.value;
      
              final VocabularyCardModel? card =
                  controller.currentCard;
      
              if (controller.isLoading.value &&
                  session == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }
      
              if (session == null || card == null) {
                return _EmptyVocabularyState(
                  onBackTap: () => Get.back<void>(),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    _VocabularyHeader(
                      title: session.title,
                      cardLabel:
                      controller.displayMode.value ==
                          VocabularyDisplayMode.list
                          ? 'vocabulary_learned_progress'
                          .trParams(
                        <String, String>{
                          'learned': controller
                              .learnedCount
                              .toString(),
                          'total': controller
                              .totalCards
                              .toString(),
                        },
                      )
                          : 'vocabulary_card_progress'
                          .trParams(
                        <String, String>{
                          'current': controller
                              .currentCardNumber
                              .toString(),
                          'total': controller
                              .totalCards
                              .toString(),
                        },
                      ),
                      onBackTap:
                      controller.showExitConfirmation,
                    ),

                    SizedBox(height: 8.h),

                    _VocabularyProgressBar(
                      value:
                      controller.displayMode.value ==
                          VocabularyDisplayMode.list
                          ? controller
                          .learnedProgressValue
                          : controller.progressValue,
                    ),

                    SizedBox(height: 8.h),

                    _VocabularyModeSwitcher(
                      selectedMode:
                      controller.displayMode.value,
                      onChanged:
                      controller.setDisplayMode,
                    ),

                    SizedBox(height: 8.h),

                    if (controller.displayMode.value ==
                        VocabularyDisplayMode.list)
                      Expanded(
                        child: _VocabularyListMode(
                          cards:
                          controller.filteredCards,
                          showMeanings:
                          controller
                              .showMeanings.value,
                          isPlayingAll:
                          controller
                              .isPlayingAll.value,
                          onSearchChanged:
                          controller.setSearchQuery,
                          onShowMeaningsChanged:
                          controller
                              .setShowMeanings,
                          onAudioTap:
                          controller.speakCard,
                          onPlayAllTap:
                          controller
                              .playAllVisibleWords,
                          onPracticeTap: () {
                            controller.setDisplayMode(
                              VocabularyDisplayMode
                                  .flashcard,
                            );
                          },
                        ),
                      )
                    else ...<Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              _VocabularyFlashCard(
                                card: card,
                                isRevealed:
                                controller
                                    .isRevealed.value,
                                isSpeaking:
                                controller
                                    .isSpeaking.value,
                                onTap:
                                controller.flipCard,
                                onAudioTap:
                                controller
                                    .speakCurrentWord,
                              ),

                              SizedBox(height: 30.h),

                              _VocabularyStats(
                                streakDays:
                                controller
                                    .currentStreakDays,
                                level: session.level,
                              ),

                              SizedBox(height: 30.h),

                              if (controller
                                  .isRevealed.value)
                                _VocabularyRevealedActions(
                                  isKnownLoading:
                                  controller
                                      .isKnownSubmitting
                                      .value,
                                  onStudyAgainTap:
                                  controller.studyAgain,
                                  onKnownTap:
                                  controller.markKnown,
                                )
                              else
                                CustomButton.primary(
                                  onPressed:
                                  controller
                                      .revealAnswer,
                                  text:
                                  'reveal_answer'.tr,
                                  icon: Icons
                                      .visibility_outlined,
                                ),

                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
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
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryGreen,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          cardLabel,
          maxLines: 1,
          style: TextStyle(
            fontSize: AppFont.font12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }
}

class _VocabularyProgressBar
    extends StatelessWidget {
  final double value;

  const _VocabularyProgressBar({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(999.r),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight:
        kVocabularyProgressHeight.h,
        borderRadius:
        BorderRadius.circular(999.r),
        color: AppColors.primaryGreen,
        backgroundColor:
        AppColors.vocabularyProgressTrack,
      ),
    );
  }
}

class _VocabularyModeSwitcher
    extends StatelessWidget {
  final VocabularyDisplayMode selectedMode;
  final ValueChanged<VocabularyDisplayMode>
  onChanged;

  const _VocabularyModeSwitcher({
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color:
          AppColors.vocabularyProgressTrack,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _VocabularyModeButton(
              label:
              'vocabulary_list_mode'.tr,
              icon:
              Icons.list_alt_rounded,
              isSelected:
              selectedMode ==
                  VocabularyDisplayMode
                      .list,
              onTap: () {
                onChanged(
                  VocabularyDisplayMode
                      .list,
                );
              },
            ),
          ),
          Expanded(
            child: _VocabularyModeButton(
              label:
              'vocabulary_flashcard_mode'
                  .tr,
              icon: Icons.style_outlined,
              isSelected:
              selectedMode ==
                  VocabularyDisplayMode
                      .flashcard,
              onTap: () {
                onChanged(
                  VocabularyDisplayMode
                      .flashcard,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyModeButton
    extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _VocabularyModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(12.r),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 20.sp,
              color: isSelected
                  ? AppColors.white
                  : AppColors.bodyText,
            ),
            SizedBox(width: 7.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight:
                FontWeight.w700,
                color: isSelected
                    ? AppColors.white
                    : AppColors.bodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VocabularyListMode
    extends StatelessWidget {
  final List<VocabularyCardModel> cards;
  final bool showMeanings;
  final bool isPlayingAll;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool>
  onShowMeaningsChanged;
  final ValueChanged<VocabularyCardModel>
  onAudioTap;
  final VoidCallback onPlayAllTap;
  final VoidCallback onPracticeTap;

  const _VocabularyListMode({
    required this.cards,
    required this.showMeanings,
    required this.isPlayingAll,
    required this.onSearchChanged,
    required this.onShowMeaningsChanged,
    required this.onAudioTap,
    required this.onPlayAllTap,
    required this.onPracticeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'vocabulary_search'.tr,
            prefixIcon: const Icon(
              Icons.search_rounded,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                14.r,
              ),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        SizedBox(height: 8.h),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              onPressed: onPlayAllTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                isPlayingAll
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_outline,
                color: AppColors.primaryGreen,
              ),
              label: Text(
                isPlayingAll
                    ? 'vocabulary_stop_audio'.tr
                    : 'vocabulary_listen_all'.tr,
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'vocabulary_show_meaning'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
                ),

                SizedBox(width: 2.w),

                Transform.scale(
                  scale: 0.72,
                  child: Switch(
                    value: showMeanings,
                    activeThumbColor:
                    AppColors.primaryGreen,
                    materialTapTargetSize:
                    MaterialTapTargetSize
                        .shrinkWrap,
                    onChanged:
                    onShowMeaningsChanged,
                  ),
                ),
              ],
            ),
          ],
        ),


        SizedBox(height: 4.h),

        Expanded(
          child: cards.isEmpty
              ? Center(
            child: Text(
              'vocabulary_no_search_result'
                  .tr,
            ),
          )
              : ListView.separated(
            padding: EdgeInsets.only(
              bottom: 12.h,
            ),
            itemCount: cards.length,
            separatorBuilder:
                (_, __) =>
                SizedBox(
                  height: 10.h,
                ),
            itemBuilder: (
                BuildContext context,
                int index,
                ) {
              final VocabularyCardModel
              card =
              cards[index];

              return _VocabularyListCard(
                card: card,
                showMeaning:
                showMeanings,
                onAudioTap: () {
                  onAudioTap(card);
                },
              );
            },
          ),
        ),

        SizedBox(height: 10.h),

        CustomButton.primary(
          onPressed: onPracticeTap,
          text:
          'vocabulary_practice_words'
              .trParams(
            <String, String>{
              'count':
              cards.length.toString(),
            },
          ),
          icon: Icons.school_outlined,
        ),
      ],
    );
  }
}

class _VocabularyListCard
    extends StatelessWidget {
  final VocabularyCardModel card;
  final bool showMeaning;
  final VoidCallback onAudioTap;

  const _VocabularyListCard({
    required this.card,
    required this.showMeaning,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors
                .vocabularyCardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  card.word,
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight:
                    FontWeight.w700,
                    color: AppColors
                        .homePrimaryText,
                  ),
                ),

                if (showMeaning &&
                    card.meaning
                        .isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    card.meaning,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                      FontWeight.w600,
                      color: AppColors
                          .primaryGreen,
                    ),
                  ),
                ],

                if (card.example
                    .isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Text(
                    card.example,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:
                      AppColors.bodyText,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 8.w),

          GestureDetector(
            onTap: onAudioTap,
            child: Container(
              width: 46.w,
              height: 46.w,
              alignment:
              Alignment.center,
              decoration:
              const BoxDecoration(
                color:
                AppColors.homePaleGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volume_up_rounded,
                color:
                AppColors.primaryGreen,
                size: 24.sp,
              ),
            ),
          ),

          SizedBox(width: 14.w),

          Icon(
            card.isLearned
                ? Icons.check_circle_rounded
                : Icons
                .radio_button_unchecked_rounded,
            size: 28.sp,
            color: card.isLearned
                ? AppColors.primaryGreen
                : AppColors.bodyText,
          ),
        ],
      ),
    );
  }
}

class _VocabularyFlashCard
    extends StatelessWidget {
  final VocabularyCardModel card;
  final bool isRevealed;
  final bool isSpeaking;
  final VoidCallback onTap;
  final VoidCallback onAudioTap;

  const _VocabularyFlashCard({
    required this.card,
    required this.isRevealed,
    required this.isSpeaking,
    required this.onTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          end: isRevealed ? math.pi : 0,
        ),
        duration:
        const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
        builder: (
            BuildContext context,
            double angle,
            Widget? child,
            ) {
          final bool showBack =
              angle > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateY(
                  showBack ? math.pi : 0,
                ),
              child: Container(
                width: double.infinity,
                height: 440.h,
                padding: EdgeInsets.all(30.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                  BorderRadius.circular(
                    kRadius48.r,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors
                          .vocabularyCardShadow,
                      blurRadius: 42.r,
                      offset: Offset(0, 22.h),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 140,
                    ),
                    child: showBack
                        ? _VocabularyBackSide(
                      key:
                      const ValueKey<
                          String>(
                        'back',
                      ),
                      card: card,
                      isSpeaking:
                      isSpeaking,
                      onAudioTap:
                      onAudioTap,
                    )
                        : _VocabularyFrontSide(
                      key:
                      const ValueKey<
                          String>(
                        'front',
                      ),
                      card: card,
                      isSpeaking:
                      isSpeaking,
                      onAudioTap:
                      onAudioTap,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VocabularyAudioButton
    extends StatelessWidget {
  final bool isSpeaking;
  final VoidCallback onTap;

  const _VocabularyAudioButton({
    required this.isSpeaking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSpeaking ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: kVocabularyAudioButtonSize.w,
        height: kVocabularyAudioButtonSize.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.homePaleGreen,
          shape: BoxShape.circle,
        ),
        child: isSpeaking
            ? SizedBox(
          width: 20.w,
          height: 20.w,
          child:
          const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryGreen,
          ),
        )
            : Icon(
          Icons.volume_up_rounded,
          size: 28.sp,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _VocabularyFrontSide
    extends StatelessWidget {
  final VocabularyCardModel card;
  final bool isSpeaking;
  final VoidCallback onAudioTap;

  const _VocabularyFrontSide({
    super.key,
    required this.card,
    required this.isSpeaking,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment:
          MainAxisAlignment.end,
          children: <Widget>[
            _VocabularyAudioButton(
              isSpeaking: isSpeaking,
              onTap: onAudioTap,
            ),
          ],
        ),
        SizedBox(height: 60.h),
        Text(
          card.word,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font44.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryGreen,
            height: 1,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          card.languageLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font18.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: 60.h),
        Icon(
          Icons.pan_tool_alt_outlined,
          size: 26.sp,
          color: AppColors.bodyText,
        ),
        SizedBox(height: 8.h),
        Text(
          'tap_card_to_flip'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }
}

class _VocabularyBackSide
    extends StatelessWidget {
  final VocabularyCardModel card;
  final bool isSpeaking;
  final VoidCallback onAudioTap;

  const _VocabularyBackSide({
    super.key,
    required this.card,
    required this.isSpeaking,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment:
          MainAxisAlignment.end,
          children: <Widget>[
            _VocabularyAudioButton(
              isSpeaking: isSpeaking,
              onTap: onAudioTap,
            ),
          ],
        ),
        SizedBox(height: 60.h),
        Text(
          card.word,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font44.sp,
            fontWeight: FontWeight.w900,
            color:
            AppColors.homePrimaryText,
            height: 1,
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          card.meaning,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font22.sp,
            fontWeight: FontWeight.w600,
            color:
            AppColors.vocabularyBlueText,
            height: 1.15,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          card.example,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: 110.h),
      ],
    );
  }
}

class _VocabularyStats extends StatelessWidget {
  final int streakDays;
  final int level;

  const _VocabularyStats({
    required this.streakDays,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _VocabularyStatText(
            icon: Icons
                .local_fire_department_rounded,
            label:
            'gen_streakdays_day_streak'
                .trParams(
              <String, String>{
                'streakDays':
                streakDays.toString(),
              },
            ),
            color:
            AppColors.vocabularyStreakText,
          ),
        ),
        Expanded(
          child: _VocabularyStatText(
            icon:
            Icons.emoji_events_outlined,
            label: 'gen_level_level'.trParams(
              <String, String>{
                'level': level.toString(),
              },
            ),
            color:
            AppColors.vocabularyBlueText,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _VocabularyStatText
    extends StatelessWidget {
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
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          color: color,
          size: 22.sp,
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _VocabularyRevealedActions
    extends StatelessWidget {
  final bool isKnownLoading;
  final VoidCallback onStudyAgainTap;
  final VoidCallback onKnownTap;

  const _VocabularyRevealedActions({
    required this.isKnownLoading,
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
            text: 'study_again'.tr,
            icon: Icons.refresh_rounded,
            showShadow: true,
            btnColor:
            AppColors.vocabularyOrange,
            btnShadowColor:
            AppColors
                .vocabularyOrangeShadow,
            borderColor:
            AppColors.vocabularyOrange,
            textColor: AppColors.white,
            fontSize: 14.sp,
            borderRadius: kRadius42,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomButton.primary(
            fontSize: 14.sp,
            onPressed: onKnownTap,
            text: 'i_know_nthis'.tr,
            icon: Icons.check_circle_rounded,
            borderRadius: kRadius42,
            isLoading: isKnownLoading,
          ),
        ),
      ],
    );
  }
}

class _EmptyVocabularyState
    extends StatelessWidget {
  final VoidCallback onBackTap;

  const _EmptyVocabularyState({
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 20.h,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: onBackTap,
                behavior:
                HitTestBehavior.opaque,
                child: SizedBox(
                  width: 44.w,
                  height: 44.w,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color:
                    AppColors.primaryGreen,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'gen_vocabulary'.tr,
                  style: TextStyle(
                    fontSize:
                    AppFont.font18.sp,
                    fontWeight:
                    FontWeight.w700,
                    color: AppColors
                        .homePrimaryText,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding:
                EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 32.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                  BorderRadius.circular(
                    20.r,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors
                          .homeNeutralShadow,
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.menu_book_outlined,
                      color: AppColors
                          .primaryGreen,
                      size: 42.sp,
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'no_vocabulary_available'
                          .tr,
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize:
                        AppFont.font18.sp,
                        fontWeight:
                        FontWeight.w700,
                        color: AppColors
                            .homePrimaryText,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'no_vocabulary_available_description'
                          .tr,
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize:
                        AppFont.font14.sp,
                        fontWeight:
                        FontWeight.w400,
                        color:
                        AppColors.bodyText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}