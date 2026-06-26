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
        _TitleBlock(title: question.title, subtitle: question.subtitle),
        if ((question.prompt ?? '').isNotEmpty) ...<Widget>[
          SizedBox(height: 18.h),
          _PromptText(text: question.prompt!),
        ],
        SizedBox(height: 30.h),
        AudioPromptCard(audioUrl: question.mediaUrl, compact: true),
        SizedBox(height: 30.h),
        _AssemblyLines(
          selectedWords: selectedWords,
          slotCount: question.answerWordCount,
          isWrong: showWrongResult,
          onWordTap: onSelectedWordTap,
        ),
        SizedBox(height: 30.h),
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
    required this.onReorder,
  });

  final QuizQuestionModel question;
  final List<String> rightOptions;
  final List<String> rightKeys;
  final bool isLocked;
  final bool showWrongResult;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final List<String> leftOptions = question.matchingLeftTexts.isNotEmpty
        ? question.matchingLeftTexts
        : <String>[
            for (int index = 0; index < question.options.length; index++)
              if (index.isEven) question.options[index],
          ];
    final List<String> resolvedRightOptions = rightOptions.isNotEmpty
        ? rightOptions
        : <String>[
            for (int index = 0; index < question.options.length; index++)
              if (index.isOdd) question.options[index],
          ];

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
        SizedBox(height: 30.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _StaticPairColumn(words: leftOptions)),
            SizedBox(width: 20.w),
            Expanded(
              child: _ReorderablePairColumn(
                words: resolvedRightOptions,
                itemKeys: rightKeys,
                isLocked: isLocked,
                showWrongResult: showWrongResult,
                onReorder: onReorder,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StaticPairColumn extends StatelessWidget {
  const _StaticPairColumn({required this.words});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: words
          .map(
            (String word) => Padding(
              padding: EdgeInsets.only(bottom: 30.h),
              child: CustomQuizButton(
                label: word,
                onTap: () {},
                height: kQuizPairButtonHeight,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ReorderablePairColumn extends StatelessWidget {
  const _ReorderablePairColumn({
    required this.words,
    required this.itemKeys,
    required this.isLocked,
    required this.showWrongResult,
    required this.onReorder,
  });

  final List<String> words;
  final List<String> itemKeys;
  final bool isLocked;
  final bool showWrongResult;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: words.length,
      onReorder: isLocked ? (_, _) {} : onReorder,
      proxyDecorator: (
        Widget child,
        int index,
        Animation<double> animation,
      ) {
        return Material(
          color: AppColors.transparent,
          elevation: 6,
          borderRadius: BorderRadius.circular(kRadius30.r),
          child: child,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          key: ValueKey<String>(
            index < itemKeys.length && itemKeys[index].isNotEmpty
                ? itemKeys[index]
                : '${words[index]}-$index',
          ),
          padding: EdgeInsets.only(bottom: 30.h),
          child: ReorderableDragStartListener(
            index: index,
            enabled: !isLocked,
            child: CustomQuizButton(
              label: words[index],
              isWrong: showWrongResult,
              onTap: () {},
              height: kQuizPairButtonHeight,
            ),
          ),
        );
      },
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
            hintText: 'Type your answer in Italian...',
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
