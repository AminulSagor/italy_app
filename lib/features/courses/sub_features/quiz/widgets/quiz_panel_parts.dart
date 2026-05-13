part of 'quiz_panels.dart';

class _ListeningPanel extends StatelessWidget {
  final QuizQuestionModel question;
  final int selectedIndex;
  final bool showWrongResult;
  final ValueChanged<int> onOptionTap;

  const _ListeningPanel({
    required this.question,
    required this.selectedIndex,
    required this.showWrongResult,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const AudioPromptCard(),
        SizedBox(height: 56.h),
        _TitleBlock(
          title: question.title,
          subtitle: question.subtitle,
          center: true,
        ),
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
  final QuizQuestionModel question;
  final int selectedIndex;
  final bool showWrongResult;
  final ValueChanged<int> onOptionTap;

  const _WordTranslationPanel({
    required this.question,
    required this.selectedIndex,
    required this.showWrongResult,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Eyebrow(question.eyebrow),
        SizedBox(height: 20.h),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: AppFont.font34.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
              height: 1.22,
            ),
            children: const <TextSpan>[
              TextSpan(text: 'How do you say\n'),
              TextSpan(
                text: '"Hello"',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
              TextSpan(text: ' in Italian?'),
            ],
          ),
        ),
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
  final QuizQuestionModel question;
  final List<String> selectedWords;
  final bool showWrongResult;
  final ValueChanged<String> onWordTap;
  final ValueChanged<String> onSelectedWordTap;

  const _SentenceTranslationPanel({
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
        _Eyebrow(question.eyebrow),
        SizedBox(height: 22.h),
        Row(
          children: <Widget>[
            Container(
              width: 92.w,
              height: 92.w,
              decoration: const BoxDecoration(
                color: AppColors.homeLime,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('🇮🇹', style: TextStyle(fontSize: 44.sp)),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 26.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    kCourseDetailCardRadius.r,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.homeNeutralShadow,
                      blurRadius: 0,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Text(
                  question.title,
                  style: TextStyle(
                    fontSize: AppFont.font28.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 74.h),
        _WordDropArea(
          selectedWords: selectedWords,
          slotCount: question.answerWordCount,
          isWrong: showWrongResult,
          onWordTap: onSelectedWordTap,
        ),
        SizedBox(height: 60.h),
        _WordBank(
          words: question.options,
          selected: selectedWords,
          hideDisabledText: true,
          onWordTap: onWordTap,
        ),
      ],
    );
  }
}

class _TrueFalsePanel extends StatelessWidget {
  final QuizQuestionModel question;
  final int selectedIndex;
  final bool showWrongResult;
  final ValueChanged<int> onOptionTap;

  const _TrueFalsePanel({
    required this.question,
    required this.selectedIndex,
    required this.showWrongResult,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Eyebrow(question.eyebrow),
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
                question.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.homePrimaryText,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 55.h),
              Text(
                question.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 48.h),
        Row(
          children: <Widget>[
            Expanded(
              child: CustomQuizButton(
                label: '✓\nTrue',
                height: kQuizTrueFalseButtonHeight,
                isSelected: !showWrongResult && selectedIndex == 0,
                isWrong: showWrongResult && selectedIndex == 0,
                onTap: () => onOptionTap(0),
              ),
            ),
            SizedBox(width: 32.w),
            Expanded(
              child: CustomQuizButton(
                label: '✕\nFalse',
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
  final QuizQuestionModel question;
  final int selectedIndex;
  final bool showWrongResult;
  final ValueChanged<int> onOptionTap;

  const _FillBlankPanel({
    required this.question,
    required this.selectedIndex,
    required this.showWrongResult,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        selectedIndex >= 0 && selectedIndex < question.options.length;
    final String selectedText = hasSelection
        ? question.options[selectedIndex]
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TitleBlock(title: question.title, subtitle: question.subtitle),
        SizedBox(height: 30.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 34.w, vertical: 32.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Io',
                style: TextStyle(
                  fontSize: AppFont.font22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.homePrimaryText,
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: showWrongResult && hasSelection
                      ? AppColors.quizWrongLightBg
                      : hasSelection
                      ? AppColors.white
                      : AppColors.legacyColorFFF1F2F2,
                  borderRadius: BorderRadius.circular(kRadius22.r),
                  border: Border.all(
                    color: showWrongResult && hasSelection
                        ? AppColors.quizWrongBorder
                        : hasSelection
                        ? AppColors.homeLime
                        : AppColors.quizBlankBorder,
                    width: 2.w,
                  ),
                ),
                child: Text(
                  selectedText,
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    fontWeight: FontWeight.w900,
                    color: showWrongResult
                        ? AppColors.quizWrongBorder
                        : AppColors.primaryGreen,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'un caffé.',
                style: TextStyle(
                  fontSize: AppFont.font22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 150.h),
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
