part of 'quiz_panels.dart';

class _ListeningAssemblyPanel extends StatelessWidget {
  final QuizQuestionModel question;
  final List<String> selectedWords;
  final bool showWrongResult;
  final ValueChanged<String> onWordTap;
  final ValueChanged<String> onSelectedWordTap;

  const _ListeningAssemblyPanel({
    required this.question,
    required this.selectedWords,
    required this.showWrongResult,
    required this.onWordTap,
    required this.onSelectedWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          question.title,
          style: TextStyle(
            fontSize: AppFont.font34.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.homePrimaryText,
            height: 1.2,
          ),
        ),
        SizedBox(height: 42.h),
        const AudioPromptCard(compact: true),
        SizedBox(height: 58.h),
        _AssemblyLines(
          selectedWords: selectedWords,
          slotCount: question.answerWordCount,
          isWrong: showWrongResult,
          onWordTap: onSelectedWordTap,
        ),
        SizedBox(height: 46.h),
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
        _TitleBlock(title: question.title, subtitle: question.subtitle, center: true),
        SizedBox(height: 58.h),
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
            SizedBox(width: 32.w),
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
  final QuizQuestionModel question;
  final TextEditingController answerController;
  final bool showWrongResult;

  const _WritingWordPanel({
    required this.question,
    required this.answerController,
    required this.showWrongResult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ImagePlaceholder(height: kQuizImageCardHeight, showBook: true),
        SizedBox(height: 48.h),
        Container(
          height: 92.h,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
                blurRadius: 24.r,
                offset: Offset(0, 14.h),
              ),
            ],
          ),
          child: Text(
            question.objectLabel ?? '',
            style: TextStyle(
              fontSize: AppFont.font34.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        SizedBox(height: 46.h),
        _TitleBlock(title: question.title, subtitle: question.subtitle),
        SizedBox(height: 30.h),
        TextField(
          controller: answerController,
          cursorColor: AppColors.primaryGreen,
          style: TextStyle(
            fontSize: AppFont.font20.sp,
            fontWeight: FontWeight.w900,
            color: showWrongResult ? AppColors.quizWrongBorder : AppColors.homePrimaryText,
          ),
          readOnly: showWrongResult,
          decoration: InputDecoration(
            hintText: 'Type in Italian...',
            hintStyle: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homeSecondaryText,
            ),
            filled: true,
            fillColor: showWrongResult ? AppColors.quizWrongLightBg : AppColors.legacyColorFFF1F2F2,
            suffixIcon: Icon(
              Icons.edit_note_rounded,
              color: AppColors.bodyText,
              size: 30.w,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 22.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
              borderSide: BorderSide(
                color: showWrongResult ? AppColors.quizWrongBorder : AppColors.modalBorderGrey,
                width: 2.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
              borderSide: BorderSide(
                color: showWrongResult ? AppColors.quizWrongBorder : AppColors.primaryGreen,
                width: 2.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentifyImagePanel extends StatelessWidget {
  final QuizQuestionModel question;
  final int selectedIndex;
  final bool showWrongResult;
  final ValueChanged<int> onOptionTap;

  const _IdentifyImagePanel({
    required this.question,
    required this.selectedIndex,
    required this.showWrongResult,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _TitleBlock(title: question.title, subtitle: question.subtitle, center: true),
        SizedBox(height: 58.h),
        _ImagePlaceholder(height: 320),
        SizedBox(height: 60.h),
        GridView.builder(
          itemCount: question.options.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.95,
            crossAxisSpacing: 28.w,
            mainAxisSpacing: 28.h,
          ),
          itemBuilder: (_, int index) => CustomQuizButton(
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

class _TitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool center;

  const _TitleBlock({required this.title, this.subtitle = '', this.center = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(fontSize: AppFont.font34.sp, fontWeight: FontWeight.w900, color: AppColors.homePrimaryText, height: 1.22),
        ),
        if (subtitle.isNotEmpty) ...<Widget>[
          SizedBox(height: 14.h),
          Text(
            subtitle,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontSize: AppFont.font20.sp, fontWeight: FontWeight.w500, color: AppColors.bodyText, height: 1.35),
          ),
        ],
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;

  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: AppFont.font16.sp, fontWeight: FontWeight.w900, color: AppColors.primaryGreen, letterSpacing: 2.6),
    );
  }
}

class _WordDropArea extends StatelessWidget {
  final List<String> selectedWords;
  final int slotCount;
  final bool isWrong;
  final ValueChanged<String> onWordTap;

  const _WordDropArea({
    required this.selectedWords,
    required this.slotCount,
    required this.isWrong,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final int remainingSlots = (slotCount - selectedWords.length).clamp(0, slotCount).toInt();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: kQuizSentenceDropHeight.h),
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(kRadius30.r),
        border: Border.all(color: AppColors.modalBorderGrey, width: 2.w),
      ),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 18.h,
        alignment: WrapAlignment.center,
        children: <Widget>[
          ...selectedWords.map(
            (String word) => _WordChip(
              word: word,
              isSelected: true,
              isWrong: isWrong,
              onTap: () => onWordTap(word),
            ),
          ),
          ...List<Widget>.generate(remainingSlots, (int index) {
            return _DashedBlank(width: index.isEven ? 112 : 96);
          }),
        ],
      ),
    );
  }
}

class _AssemblyLines extends StatelessWidget {
  final List<String> selectedWords;
  final int slotCount;
  final bool isWrong;
  final ValueChanged<String> onWordTap;

  const _AssemblyLines({
    required this.selectedWords,
    required this.slotCount,
    required this.isWrong,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final int remainingSlots = (slotCount - selectedWords.length).clamp(0, slotCount).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 14.w,
          runSpacing: 16.h,
          children: <Widget>[
            ...selectedWords.map(
              (String word) => _WordChip(
                word: word,
                isSelected: true,
                isWrong: isWrong,
                onTap: () => onWordTap(word),
              ),
            ),
            ...List<Widget>.generate(remainingSlots, (int index) {
              return _DashedBlank(width: index.isEven ? 112 : 96);
            }),
          ],
        ),
        SizedBox(height: 28.h),
        Divider(color: AppColors.legacyColorFFE0E1E1, thickness: 4.h),
      ],
    );
  }
}

class _WordBank extends StatelessWidget {
  final List<String> words;
  final List<String> selected;
  final ValueChanged<String> onWordTap;
  final bool hideDisabledText;

  const _WordBank({
    required this.words,
    required this.selected,
    required this.onWordTap,
    this.hideDisabledText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 18.w,
        runSpacing: 22.h,
        children: words.map((String word) {
          final bool isDisabled = selected.contains(word);
          return _WordChip(
            word: hideDisabledText && isDisabled ? '' : word,
            isDisabled: isDisabled,
            onTap: isDisabled ? null : () => onWordTap(word),
          );
        }).toList(),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool isSelected;
  final bool isDisabled;
  final bool isWrong;
  final VoidCallback? onTap;

  const _WordChip({
    required this.word,
    this.isSelected = false,
    this.isDisabled = false,
    this.isWrong = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBlank = word.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kQuizSmallWordChipHeight.h,
        constraints: BoxConstraints(minWidth: isBlank ? 112.w : 0),
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        decoration: BoxDecoration(
          color: isWrong
              ? AppColors.quizWrongLightBg
              : isDisabled
                  ? AppColors.legacyColorFFD4D6D7
                  : AppColors.white,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          border: Border.all(
            color: isWrong
                ? AppColors.quizWrongBorder
                : isSelected
                    ? AppColors.homeLime
                    : AppColors.modalBorderGrey,
            width: 1.5.w,
          ),
          boxShadow: isSelected || isDisabled || isWrong
              ? const <BoxShadow>[]
              : <BoxShadow>[
                  BoxShadow(color: AppColors.quizAnswerShadow, blurRadius: 0, offset: Offset(0, 4.h)),
                ],
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            word,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: isWrong
                  ? AppColors.quizWrongBorder
                  : isDisabled
                      ? AppColors.homeMutedText
                      : AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBlank extends StatelessWidget {
  final double width;

  const _DashedBlank({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: kQuizSmallWordChipHeight.h,
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(kRadius22.r),
        border: Border.all(color: AppColors.legacyColorFFABABAB, width: 2.w),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double height;
  final bool showBook;

  const _ImagePlaceholder({required this.height, this.showBook = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius28.r),
        border: Border.all(color: AppColors.modalBorderGrey, width: 2.w),
        boxShadow: <BoxShadow>[BoxShadow(color: AppColors.quizAnswerShadow, blurRadius: 0, offset: Offset(0, 10.h))],
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: showBook ? 150.w : 278.w,
              height: showBook ? 150.w : 248.w,
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFF1F2F2,
                borderRadius: BorderRadius.circular(kRadius24.r),
              ),
              alignment: Alignment.center,
              child: Text('🍎', style: TextStyle(fontSize: showBook ? 92.sp : 160.sp)),
            ),
          ),
          if (showBook)
            Positioned(
              right: 24.w,
              top: 24.h,
              child: Icon(Icons.menu_book_rounded, color: AppColors.modalBorderGrey, size: 34.w),
            ),
        ],
      ),
    );
  }
}

TextStyle _bigPromptStyle(BuildContext context) {
  return TextStyle(
    fontSize: AppFont.font34.sp,
    fontWeight: FontWeight.w900,
    color: AppColors.homePrimaryText,
  );
}
