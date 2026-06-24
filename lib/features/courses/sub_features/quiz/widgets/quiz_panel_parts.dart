part of 'quiz_panels.dart';

class _ListeningPanel extends StatelessWidget {
  const _ListeningPanel({
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
          SizedBox(height: 18.h),
          _PromptText(text: question.prompt!, center: true),
        ],
        SizedBox(height: 30.h),
        AudioPromptCard(audioUrl: question.mediaUrl),
        SizedBox(height: 46.h),
        ...List<Widget>.generate(question.options.length, (int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 28.h),
            child: CustomQuizButton(
              label: question.options[index],
              isSelected: !showWrongResult && selectedIndex == index,
              isWrong: showWrongResult && selectedIndex == index,
              onTap: () => onOptionTap(index),
            ),
          );
        }),
      ],
    );
  }
}

class _WordTranslationPanel extends StatelessWidget {
  const _WordTranslationPanel({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TitleBlock(title: question.title, subtitle: question.subtitle),
        if ((question.prompt ?? '').isNotEmpty) ...<Widget>[
          SizedBox(height: 24.h),
          _QuotedPromptText(text: question.prompt!),
        ],
        SizedBox(height: 30.h),
        ...List<Widget>.generate(question.options.length, (int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: CustomQuizButton(
              label: question.options[index],
              isSelected: !showWrongResult && selectedIndex == index,
              isWrong: showWrongResult && selectedIndex == index,
              onTap: () => onOptionTap(index),
            ),
          );
        }),
      ],
    );
  }
}

class _SentenceTranslationPanel extends StatelessWidget {
  const _SentenceTranslationPanel({
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
        SizedBox(height: 22.h),
        Row(
          children: <Widget>[
            Container(
              width: 76.w,
              height: 76.w,
              decoration: const BoxDecoration(
                color: AppColors.homeLime,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('🇮🇹', style: TextStyle(fontSize: 34.sp)),
              ),
            ),
            14.w.horizontalSpace,
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 26.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.homeNeutralShadow,
                      blurRadius: 0,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Text(
                  question.prompt ?? '',
                  style: TextStyle(
                    fontSize: AppFont.font22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.homePrimaryText,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 74.h),
        _AssemblyLines(
          selectedWords: selectedWords,
          slotCount: question.answerWordCount,
          isWrong: showWrongResult,
          onWordTap: onSelectedWordTap,
        ),
        SizedBox(height: 60.h),
        _WordBank(
          words: question.options,
          selected: selectedWords,
          onWordTap: onWordTap,
        ),
      ],
    );
  }
}

class _TrueFalsePanel extends StatelessWidget {
  const _TrueFalsePanel({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TitleBlock(title: question.title, subtitle: question.subtitle),
        SizedBox(height: 28.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.quizAnswerShadow,
                blurRadius: 0,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Text(
                question.prompt ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.homePrimaryText,
                  height: 1.3,
                ),
              ),
              if (question.correctMeaning.isNotEmpty) ...<Widget>[
                SizedBox(height: 30.h),
                Text(
                  question.correctMeaning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 48.h),
        Row(
          children: <Widget>[
            Expanded(
              child: CustomQuizButton(
                label: question.options.isNotEmpty
                    ? question.options[0]
                    : 'True',
                height: kQuizTrueFalseButtonHeight,
                isSelected: !showWrongResult && selectedIndex == 0,
                isWrong: showWrongResult && selectedIndex == 0,
                onTap: () => onOptionTap(0),
              ),
            ),
            SizedBox(width: 32.w),
            Expanded(
              child: CustomQuizButton(
                label: question.options.length > 1
                    ? question.options[1]
                    : 'False',
                height: kQuizTrueFalseButtonHeight,
                isSelected: !showWrongResult && selectedIndex == 1,
                isWrong: showWrongResult && selectedIndex == 1,
                onTap: () => onOptionTap(1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FillBlankPanel extends StatelessWidget {
  const _FillBlankPanel({
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
    final bool hasSelection =
        selectedIndex >= 0 && selectedIndex < question.options.length;
    final String selectedText = hasSelection
        ? question.options[selectedIndex]
        : '_____';
    final String prompt = (question.prompt ?? '').replaceFirst(
      RegExp(r'\[[^\]]+\]'),
      selectedText,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TitleBlock(title: question.title, subtitle: question.subtitle),
        SizedBox(height: 30.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 34.w, vertical: 32.h),
          decoration: BoxDecoration(
            color: showWrongResult && hasSelection
                ? AppColors.quizWrongLightBg
                : AppColors.white,
            borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
            border: Border.all(
              color: showWrongResult && hasSelection
                  ? AppColors.quizWrongBorder
                  : AppColors.modalBorderGrey,
              width: 2.w,
            ),
          ),
          child: Text(
            prompt,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font22.sp,
              fontWeight: FontWeight.w800,
              color: showWrongResult
                  ? AppColors.quizWrongBorder
                  : AppColors.homePrimaryText,
            ),
          ),
        ),
        SizedBox(height: 70.h),
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
