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
  final QuizQuestionModel question;
  final int selectedLeftIndex;
  final int selectedRightIndex;
  final bool showWrongResult;
  final ValueChanged<int> onLeftTap;
  final ValueChanged<int> onRightTap;

  const _MatchingPairsPanel({
    required this.question,
    required this.selectedLeftIndex,
    required this.selectedRightIndex,
    required this.showWrongResult,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> leftOptions = <String>[];
    final List<String> rightOptions = <String>[];

    for (int index = 0; index < question.options.length; index++) {
      if (index.isEven) {
        leftOptions.add(question.options[index]);
      } else {
        rightOptions.add(question.options[index]);
      }
    }

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
            Expanded(
              child: _PairColumn(
                words: leftOptions,
                selectedIndex: selectedLeftIndex,
                showWrongResult: showWrongResult,
                onTap: onLeftTap,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: _PairColumn(
                words: rightOptions,
                selectedIndex: selectedRightIndex,
                showWrongResult: showWrongResult,
                onTap: onRightTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PairColumn extends StatelessWidget {
  final List<String> words;
  final int selectedIndex;
  final bool showWrongResult;
  final ValueChanged<int> onTap;

  const _PairColumn({
    required this.words,
    required this.selectedIndex,
    required this.showWrongResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(words.length, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 30.h),
          child: CustomQuizButton(
            label: words[index],
            isSelected: !showWrongResult && selectedIndex == index,
            isWrong: showWrongResult && selectedIndex == index,
            onTap: () => onTap(index),
            height: kQuizPairButtonHeight,
          ),
        );
      }),
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
