part of 'quiz_panels.dart';

class _TitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool center;

  const _TitleBlock({
    required this.title,
    this.subtitle = '',
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: AppFont.font26.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.homePrimaryText,
            height: 1.22,
          ),
        ),
        if (subtitle.isNotEmpty) ...<Widget>[
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.bodyText,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _PromptText extends StatelessWidget {
  const _PromptText({
    required this.text,
    this.center = false,
    this.prominent = false,
  });

  final String text;
  final bool center;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: prominent ? AppFont.font28.sp : AppFont.font18.sp,
        fontWeight: prominent ? FontWeight.w900 : FontWeight.w700,
        color: AppColors.homePrimaryText,
        height: 1.35,
      ),
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
      style: TextStyle(
        fontSize: AppFont.font14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGreen,
        letterSpacing: 1.5,
      ),
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
    final int remainingSlots = (slotCount - selectedWords.length)
        .clamp(0, slotCount)
        .toInt();

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
    final int remainingSlots = (slotCount - selectedWords.length)
        .clamp(0, slotCount)
        .toInt();

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
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
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
                  BoxShadow(
                    color: AppColors.quizAnswerShadow,
                    blurRadius: 0,
                    offset: Offset(0, 3.h),
                  ),
                ],
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            word,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(kRadius48.r),
        border: Border.all(color: AppColors.legacyColorFFABABAB, width: 2.w),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.height, required this.imageUrl});

  final double height;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius48.r),
        border: Border.all(color: AppColors.modalBorderGrey, width: 2.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.quizAnswerShadow,
            blurRadius: 0,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius32.r),
        child: SizedBox(
          height: height.h,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            },
            errorBuilder: (_, __, ___) => Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.bodyText,
                size: 48.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

