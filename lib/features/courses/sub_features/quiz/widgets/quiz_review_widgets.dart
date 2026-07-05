import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/quiz_models.dart';

class ReviewAnswerCard extends StatelessWidget {
  final QuizQuestionModel question;
  final QuizAnswerReviewModel? review;

  const ReviewAnswerCard({
    super.key,
    required this.question,
    required this.review,
  });

  bool get _isCorrect => review?.isCorrect ?? false;

  @override
  Widget build(BuildContext context) {
    final bool isWrong = review != null && !_isCorrect;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: kLessonReviewCardMinHeight.h),
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: isWrong ? AppColors.lessonReviewWrongBg : AppColors.white,
        borderRadius: BorderRadius.circular(kRadius48.r),
        border: Border.all(
          color: isWrong
              ? AppColors.notificationWarningBorder
              : AppColors.legacyColorFFE8F4DF,
          width: 1.5.w,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _labelForType(question.type),
                  style: TextStyle(
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.bodyText,
                  ),
                ),
              ),
              Icon(
                _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: _isCorrect
                    ? AppColors.primaryGreen
                    : AppColors.blockDangerRed,
                size: 20.w,
              ),
            ],
          ),
          SizedBox(height: 18.h),
          _ReviewBody(question: question, review: review),
        ],
      ),
    );
  }

  String _labelForType(QuizQuestionType type) {
    switch (type) {
      case QuizQuestionType.listening:
        return 'gen_listening'.tr;
      case QuizQuestionType.wordTranslation:
        return 'word_translation'.tr;
      case QuizQuestionType.sentenceTranslation:
        return 'sentence_translation'.tr;
      case QuizQuestionType.trueFalse:
        return 'true_false'.tr;
      case QuizQuestionType.fillBlank:
        return 'fill_in_the_blanks'.tr;
      case QuizQuestionType.listeningAssembly:
        return 'audio_transcription'.tr;
      case QuizQuestionType.matchingPairs:
        return 'match_the_pairs'.tr;
      case QuizQuestionType.writingWordTranslation:
        return 'writing_translation'.tr;
      case QuizQuestionType.identifyImage:
        return 'identify_image'.tr;
    }
  }
}

class _ReviewBody extends StatelessWidget {
  final QuizQuestionModel question;
  final QuizAnswerReviewModel? review;

  const _ReviewBody({required this.question, required this.review});

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuizQuestionType.listening:
        return _ListeningReview(question: question, review: review);
      case QuizQuestionType.wordTranslation:
      case QuizQuestionType.trueFalse:
      case QuizQuestionType.identifyImage:
        return _ChoiceReview(question: question, review: review);
      case QuizQuestionType.sentenceTranslation:
      case QuizQuestionType.listeningAssembly:
        return _WordsReview(question: question, review: review);
      case QuizQuestionType.fillBlank:
        return _FillBlankReview(question: question, review: review);
      case QuizQuestionType.matchingPairs:
        return _MatchingReview(review: review);
      case QuizQuestionType.writingWordTranslation:
        return _WritingReview(question: question, review: review);
    }
  }
}

class _ListeningReview extends StatelessWidget {
  final QuizQuestionModel question;
  final QuizAnswerReviewModel? review;

  const _ListeningReview({required this.question, required this.review});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 42.w,
          height: 42.w,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.white,
            size: 26.w,
          ),
        ),
        SizedBox(width: 18.w),
        Expanded(
          child: Text(
            question.title,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        _AnswerChip(
          label: review?.selectedAnswer ?? question.correctAnswer,
          isCorrect: review?.isCorrect ?? true,
        ),
      ],
    );
  }
}

class _ChoiceReview extends StatelessWidget {
  final QuizQuestionModel question;
  final QuizAnswerReviewModel? review;

  const _ChoiceReview({required this.question, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          question.type == QuizQuestionType.identifyImage
              ? '🍎  ${question.objectLabel ?? 'apple'.tr}'
              : question.title.replaceAll('\n', ' '),
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.homePrimaryText,
            height: 1.35,
          ),
        ),
        SizedBox(height: 14.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: <Widget>[
            if ((review?.selectedAnswer ?? '').isNotEmpty)
              _AnswerChip(
                label: review!.selectedAnswer,
                isCorrect: review!.isCorrect,
              ),
            if (review != null && !review!.isCorrect)
              _AnswerChip(
                label: 'correct_answer_value'.trParams(<String, String>{
                  'answer': review!.correctAnswer,
                }),
                isCorrect: true,
              ),
          ],
        ),
      ],
    );
  }
}

class _WordsReview extends StatelessWidget {
  final QuizQuestionModel question;
  final QuizAnswerReviewModel? review;

  const _WordsReview({required this.question, required this.review});

  @override
  Widget build(BuildContext context) {
    final List<String> words = (review?.selectedWords.isNotEmpty ?? false)
        ? review!.selectedWords
        : question.correctWords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          question.title.replaceAll('\n', ' '),
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.homePrimaryText,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: words.map((String word) {
            return _AnswerChip(
              label: word,
              isCorrect: review?.isCorrect ?? true,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FillBlankReview extends StatelessWidget {
  final QuizQuestionModel question;
  final QuizAnswerReviewModel? review;

  const _FillBlankReview({required this.question, required this.review});

  @override
  Widget build(BuildContext context) {
    final String answer = (review?.selectedAnswer ?? '').isEmpty
        ? question.correctAnswer
        : review!.selectedAnswer;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: AppFont.font20.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.homePrimaryText,
        ),
        children: <InlineSpan>[
          TextSpan(text: 'io'.tr),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _AnswerChip(
              label: answer,
              isCorrect: review?.isCorrect ?? true,
            ),
          ),
          TextSpan(text: 'un_caff'.tr),
        ],
      ),
    );
  }
}

class _MatchingReview extends StatelessWidget {
  final QuizAnswerReviewModel? review;

  const _MatchingReview({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _GreyPairChip(label: 'gen_buongiorno'.tr)),
            Container(width: 44.w, height: 2.h, color: AppColors.primaryGreen),
            Expanded(child: _GreyPairChip(label: 'gen_good_nmorning'.tr)),
          ],
        ),
        SizedBox(height: 18.h),
        Row(
          children: <Widget>[
            Expanded(child: _GreyPairChip(label: 'gen_ciao'.tr)),
            Container(
              width: 44.w,
              height: 2.h,
              color: AppColors.blockDangerRed,
            ),
            Expanded(
              child: _GreyPairChip(
                label: review?.selectedAnswer.contains('hello'.tr) ?? false
                    ? 'hello'.tr
                    : 'thank_you'.tr,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WritingReview extends StatelessWidget {
  final QuizQuestionModel question;
  final QuizAnswerReviewModel? review;

  const _WritingReview({required this.question, required this.review});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('🍎', style: TextStyle(fontSize: 46.sp)),
        SizedBox(width: 20.w),
        Expanded(
          child: Text(
            question.objectLabel ?? '',
            style: TextStyle(
              fontSize: AppFont.font22.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        _AnswerChip(
          label: review?.selectedAnswer ?? question.correctAnswer,
          isCorrect: review?.isCorrect ?? true,
        ),
      ],
    );
  }
}

class _AnswerChip extends StatelessWidget {
  final String label;
  final bool isCorrect;

  const _AnswerChip({required this.label, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.lessonReviewGreenPill
            : AppColors.quizWrongLightBg,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        border: Border.all(
          color: isCorrect
              ? AppColors.homeLime
              : AppColors.notificationWarningBorder,
        ),
      ),
      child: Text(
        '${isCorrect ? '✓ ' : '× '}$label',
        style: TextStyle(
          fontSize: AppFont.font14.sp,
          fontWeight: FontWeight.w900,
          color: isCorrect ? AppColors.primaryGreen : AppColors.blockDangerRed,
        ),
      ),
    );
  }
}

class _GreyPairChip extends StatelessWidget {
  final String label;

  const _GreyPairChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppFont.font14.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.homePrimaryText,
        ),
      ),
    );
  }
}
