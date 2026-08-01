part of 'quiz_panels.dart';

class _ListeningAssemblyPanel extends StatelessWidget {
  const _ListeningAssemblyPanel({
    required this.question,
    required this.selectedWords,
    required this.showWrongResult,
    required this.onWordTap,
    required this.onSelectedWordTap,
  });

  final QuizQuestionModel question;
  final List<String> selectedWords;
  final bool showWrongResult;
  final ValueChanged<String> onWordTap;
  final ValueChanged<String> onSelectedWordTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TitleBlock(
          title: question.title,
          subtitle: question.subtitle,
        ),

        SizedBox(height: 24.h),

        // Play the audio without displaying the correct sentence.
        AudioPromptCard(
          audioUrl: question.mediaUrl,
          compact: true,
        ),

        SizedBox(height: 28.h),

        _AssemblyLines(
          selectedWords: selectedWords,
          slotCount: question.answerWordCount,
          isWrong: showWrongResult,
          onWordTap: onSelectedWordTap,
        ),

        SizedBox(height: 28.h),

        _WordBank(
          words: question.options,
          selected: selectedWords,
          onWordTap: onWordTap,
        ),
      ],
    );
  }
}

class _MatchingPairsPanel extends StatelessWidget {
  const _MatchingPairsPanel({
    required this.question,
    required this.rightOptions,
    required this.rightKeys,
    required this.isLocked,
    required this.showWrongResult,
    required this.onSwap,
  });

  final QuizQuestionModel question;
  final List<String> rightOptions;
  final List<String> rightKeys;
  final bool isLocked;
  final bool showWrongResult;
  final void Function(int fromIndex, int toIndex) onSwap;

  @override
  Widget build(BuildContext context) {
    final List<String> leftOptions =
    question.matchingLeftTexts.isNotEmpty
        ? question.matchingLeftTexts
        : <String>[
      for (
      int index = 0;
      index < question.options.length;
      index++
      )
        if (index.isEven) question.options[index],
    ];

    final List<String> resolvedRightOptions =
    rightOptions.isNotEmpty
        ? rightOptions
        : <String>[
      for (
      int index = 0;
      index < question.options.length;
      index++
      )
        if (index.isOdd) question.options[index],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TitleBlock(
          title: question.title,
          subtitle: question.subtitle,
          center: true,
        ),

        if ((question.prompt ?? '').trim().isNotEmpty) ...<Widget>[
          SizedBox(height: 16.h),
          _PromptText(
            text: question.prompt!,
            center: true,
          ),
        ],

        SizedBox(height: 18.h),

        const _MatchingInstructionCard(),

        SizedBox(height: 18.h),

        _MatchingPairBoard(
          leftOptions: leftOptions,
          rightOptions: resolvedRightOptions,
          rightKeys: rightKeys,
          isLocked: isLocked,
          showWrongResult: showWrongResult,
          onSwap: onSwap,
        ),
      ],
    );
  }
}
class _MatchingInstructionCard extends StatelessWidget {
  const _MatchingInstructionCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'matching_pairs_drag_instruction'.tr,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.18),
            width: 1.w,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 36.r,
              height: 36.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.open_with_rounded,
                size: 20.r,
                color: AppColors.primaryGreen,
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: Text(
                'matching_pairs_drag_instruction'.tr,
                style: TextStyle(
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchingPairBoard extends StatelessWidget {
  const _MatchingPairBoard({
    required this.leftOptions,
    required this.rightOptions,
    required this.rightKeys,
    required this.isLocked,
    required this.showWrongResult,
    required this.onSwap,
  });

  final List<String> leftOptions;
  final List<String> rightOptions;
  final List<String> rightKeys;
  final bool isLocked;
  final bool showWrongResult;
  final void Function(int fromIndex, int toIndex) onSwap;

  @override
  Widget build(BuildContext context) {
    final int itemCount =
    leftOptions.length < rightOptions.length
        ? leftOptions.length
        : rightOptions.length;

    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        final double gap = 12.w;
        final double tileWidth =
            (constraints.maxWidth - gap) / 2;

        return Column(
          children: List<Widget>.generate(
            itemCount,
                (int index) {
              final String itemKey =
              index < rightKeys.length &&
                  rightKeys[index].trim().isNotEmpty
                  ? rightKeys[index]
                  : '${rightOptions[index]}-$index';

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == itemCount - 1 ? 0 : 14.h,
                ),
                child: _MatchingPairRow(
                  leftText: leftOptions[index],
                  rightText: rightOptions[index],
                  rightKey: itemKey,
                  index: index,
                  tileWidth: tileWidth,
                  gap: gap,
                  isLocked: isLocked,
                  showWrongResult: showWrongResult,
                  onSwap: onSwap,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MatchingPairRow extends StatelessWidget {
  const _MatchingPairRow({
    required this.leftText,
    required this.rightText,
    required this.rightKey,
    required this.index,
    required this.tileWidth,
    required this.gap,
    required this.isLocked,
    required this.showWrongResult,
    required this.onSwap,
  });

  final String leftText;
  final String rightText;
  final String rightKey;
  final int index;
  final double tileWidth;
  final double gap;
  final bool isLocked;
  final bool showWrongResult;
  final void Function(int fromIndex, int toIndex) onSwap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // The left item remains fixed, but accepts a dropped answer.
        SizedBox(
          width: tileWidth,
          child: DragTarget<int>(
            onWillAcceptWithDetails: (
                DragTargetDetails<int> details,
                ) {
              return !isLocked && details.data != index;
            },
            onAcceptWithDetails: (
                DragTargetDetails<int> details,
                ) {
              onSwap(details.data, index);
            },
            builder: (
                BuildContext context,
                List<int?> candidateData,
                List<dynamic> rejectedData,
                ) {
              return _MatchingPairTile(
                label: leftText,
                isDraggable: false,
                isDropTarget: candidateData.isNotEmpty,
              );
            },
          ),
        ),

        SizedBox(width: gap),

        // The right item can be dragged immediately in every direction.
        SizedBox(
          width: tileWidth,
          child: DragTarget<int>(
            onWillAcceptWithDetails: (
                DragTargetDetails<int> details,
                ) {
              return !isLocked && details.data != index;
            },
            onAcceptWithDetails: (
                DragTargetDetails<int> details,
                ) {
              onSwap(details.data, index);
            },
            builder: (
                BuildContext context,
                List<int?> candidateData,
                List<dynamic> rejectedData,
                ) {
              final bool isReceiving = candidateData.isNotEmpty;

              final Widget tile = _MatchingPairTile(
                label: rightText,
                isDraggable: !isLocked,
                isDropTarget: isReceiving,
                isWrong: showWrongResult,
              );

              if (isLocked) {
                return tile;
              }

              return Draggable<int>(
                key: ValueKey<String>(rightKey),
                data: index,

                // No axis means movement in every direction.
                dragAnchorStrategy: pointerDragAnchorStrategy,
                rootOverlay: true,
                maxSimultaneousDrags: 1,
                hitTestBehavior: HitTestBehavior.opaque,

                feedback: Material(
                  color: Colors.transparent,
                  elevation: 10,
                  borderRadius: BorderRadius.circular(kRadius30.r),
                  child: SizedBox(
                    width: tileWidth,
                    child: _MatchingPairTile(
                      label: rightText,
                      isDraggable: true,
                      isDragging: true,
                    ),
                  ),
                ),

                childWhenDragging: Opacity(
                  opacity: 0.25,
                  child: tile,
                ),

                child: tile,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MatchingPairTile extends StatelessWidget {
  const _MatchingPairTile({
    required this.label,
    required this.isDraggable,
    this.isDropTarget = false,
    this.isDragging = false,
    this.isWrong = false,
  });

  final String label;
  final bool isDraggable;
  final bool isDropTarget;
  final bool isDragging;
  final bool isWrong;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;

    if (isWrong) {
      backgroundColor = AppColors.quizWrongLightBg;
    } else if (isDropTarget) {
      backgroundColor =
          AppColors.primaryGreen.withValues(alpha: 0.12);
    } else {
      backgroundColor = AppColors.white;
    }

    final Color borderColor;

    if (isWrong) {
      borderColor = AppColors.quizWrongBorder;
    } else if (isDropTarget || isDragging) {
      borderColor = AppColors.primaryGreen;
    } else {
      borderColor = AppColors.modalBorderGrey;
    }

    return Semantics(
      button: isDraggable,
      enabled: isDraggable,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: kQuizPairButtonHeight,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(kRadius30.r),
          border: Border.all(
            color: borderColor,
            width: isDropTarget || isDragging ? 2.w : 1.5.w,
          ),
          boxShadow: isDragging
              ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12.r,
              offset: Offset(0, 5.h),
            ),
          ]
              : null,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: isWrong
                      ? AppColors.quizWrongBorder
                      : AppColors.homePrimaryText,
                ),
              ),
            ),

            if (isDraggable) ...<Widget>[
              SizedBox(width: 6.w),
              Icon(
                Icons.drag_indicator_rounded,
                size: 20.w,
                color: isWrong
                    ? AppColors.quizWrongBorder
                    : AppColors.bodyText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WritingWordPanel extends StatelessWidget {
  const _WritingWordPanel({
    required this.question,
    required this.answerController,
    required this.showWrongResult,
  });

  final QuizQuestionModel question;
  final TextEditingController answerController;
  final bool showWrongResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TitleBlock(title: question.title, subtitle: question.subtitle),
        if (question.hasImageMedia) ...<Widget>[
          SizedBox(height: 24.h),
          _ImagePlaceholder(
            height: kQuizImageCardHeight,
            imageUrl: question.mediaUrl,
          ),
        ],
        if ((question.prompt ?? '').isNotEmpty) ...<Widget>[
          SizedBox(height: 30.h),
          _PromptText(text: question.prompt!, prominent: true),
        ],
        SizedBox(height: 20.h),
        TextField(
          controller: answerController,
          scrollPadding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 40.h,
          ),
          textInputAction: TextInputAction.done,
          cursorColor: AppColors.primaryGreen,
          style: TextStyle(
            fontSize: AppFont.font18.sp,
            fontWeight: FontWeight.w800,
            color: showWrongResult
                ? AppColors.quizWrongBorder
                : AppColors.homePrimaryText,
          ),
          readOnly: showWrongResult,
          decoration: InputDecoration(
            hintText: 'gen_type_your_answer_in_italian'.tr,
            hintStyle: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.homeSecondaryText,
            ),
            filled: true,
            fillColor: showWrongResult
                ? AppColors.quizWrongLightBg
                : AppColors.legacyColorFFF1F2F2,
            suffixIcon: Icon(
              Icons.edit_note_rounded,
              color: AppColors.bodyText,
              size: 22.w,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 28.w,
              vertical: 22.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
              borderSide: BorderSide(
                color: showWrongResult
                    ? AppColors.quizWrongBorder
                    : AppColors.modalBorderGrey,
                width: 2.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
              borderSide: BorderSide(
                color: showWrongResult
                    ? AppColors.quizWrongBorder
                    : AppColors.primaryGreen,
                width: 2.w,
              ),
            ),
          ),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}

class _IdentifyImagePanel extends StatelessWidget {
  const _IdentifyImagePanel({
    required this.question,
    required this.selectedIndex,
    required this.showWrongResult,
    required this.onOptionTap,
  });

  final QuizQuestionModel question;
  final int selectedIndex;
  final bool showWrongResult;
  final ValueChanged<int> onOptionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _TitleBlock(
          title: question.title,
          subtitle: question.subtitle,
          center: true,
        ),
        if ((question.prompt ?? '').isNotEmpty) ...<Widget>[
          SizedBox(height: 16.h),
          _PromptText(text: question.prompt!, center: true),
        ],
        if (question.hasImageMedia) ...<Widget>[
          SizedBox(height: 30.h),
          _ImagePlaceholder(height: 320, imageUrl: question.mediaUrl),
        ],
        SizedBox(height: 30.h),
        GridView.builder(
          itemCount: question.options.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
          ),
          itemBuilder: (_, int index) => CustomQuizButton(
            radius: kRadius32,
            label: question.options[index],
            isSelected: !showWrongResult && selectedIndex == index,
            isWrong: showWrongResult && selectedIndex == index,
            onTap: () => onOptionTap(index),
          ),
        ),
      ],
    );
  }
}
