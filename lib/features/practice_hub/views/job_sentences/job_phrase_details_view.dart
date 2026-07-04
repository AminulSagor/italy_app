import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/job_sentences_controller.dart';
import '../../models/job_sentence_models.dart';

class JobPhraseDetailsScreen extends GetView<JobSentencesController> {
  const JobPhraseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.jobSentences,
      sourceId: 'job_phrase_details_view',
      child: Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () => controller.loadModuleSentences(showError: false),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 48.h),
            child: Column(
              children: <Widget>[
                const _PhraseDetailsHeader(),
                SizedBox(height: 25.h),
                const _PhraseSearchField(),
                SizedBox(height: 31.h),
                const _PhraseList(),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _PhraseDetailsHeader extends GetView<JobSentencesController> {
  const _PhraseDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final JobModuleSentenceSummaryModel? summary =
          controller.moduleSummary.value;
      final String title = summary?.name ??
          controller.selectedModule.value?.name ??
          'Job Sentences';
      final int learned = summary?.learnedSentences ??
          controller.selectedModule.value?.learnedSentenceCount ??
          0;
      final int total = summary?.totalSentences ??
          controller.selectedModule.value?.sentenceCount ??
          0;

      return Row(
        children: <Widget>[
          GestureDetector(
            onTap: controller.onPhraseBackTap,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 25.r,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            constraints: BoxConstraints(minWidth: 88.w),
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 13.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE5FFD7),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: const Color(0xFFBDEDA6), width: 1.w),
            ),
            child: Center(
              child: Text(
                '$learned / $total',
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _PhraseSearchField extends GetView<JobSentencesController> {
  const _PhraseSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57.h,
      padding: EdgeInsets.symmetric(horizontal: 19.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            size: 24.r,
            color: const Color(0xFFAFB2B5),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              cursorColor: AppColors.primaryGreen,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'gen_search_phrases'.tr.tr,
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFC0C2C4),
                ),
              ),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3236),
              ),
            ),
          ),
          Obx(
            () => controller.searchQuery.value.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: controller.clearSearch,
                    child: Icon(
                      Icons.close_rounded,
                      size: 21.r,
                      color: const Color(0xFF9EA2A5),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PhraseList extends GetView<JobSentencesController> {
  const _PhraseList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSentencesLoading.value && controller.sentences.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 100.h),
          child: const CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        );
      }

      if (controller.sentencesError.value.isNotEmpty &&
          controller.sentences.isEmpty) {
        return _PhraseMessageState(
          message: controller.sentencesError.value,
          onRetry: () => controller.loadModuleSentences(),
        );
      }

      if (controller.sentences.isEmpty) {
        return _PhraseMessageState(
          message: controller.searchQuery.value.isEmpty
              ? 'No sentences are available in this module.'
              : 'No sentences match your search.',
        );
      }

      return Column(
        children: controller.sentences
            .map(
              (JobSentenceModel phrase) => Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: _PhraseCard(
                  key: ValueKey<String>(phrase.id),
                  phrase: phrase,
                ),
              ),
            )
            .toList(growable: false),
      );
    });
  }
}

class _PhraseCard extends StatefulWidget {
  const _PhraseCard({super.key, required this.phrase});

  final JobSentenceModel phrase;

  @override
  State<_PhraseCard> createState() => _PhraseCardState();
}

class _PhraseCardState extends State<_PhraseCard> {
  ScrollPosition? _scrollPosition;
  bool _visibilityCheckScheduled = false;
  bool _isSubmittingView = false;
  bool _hasMarkedFromView = false;

  JobSentencesController get controller =>
      Get.find<JobSentencesController>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ScrollPosition? position = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != position) {
      _scrollPosition?.removeListener(_scheduleVisibilityCheck);
      _scrollPosition = position;
      _scrollPosition?.addListener(_scheduleVisibilityCheck);
    }
    _scheduleVisibilityCheck();
  }

  @override
  void didUpdateWidget(covariant _PhraseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phrase.id != widget.phrase.id) {
      _hasMarkedFromView = false;
      _isSubmittingView = false;
    }
    if (widget.phrase.isLearned) {
      _hasMarkedFromView = true;
    }
    _scheduleVisibilityCheck();
  }

  void _scheduleVisibilityCheck() {
    if (_visibilityCheckScheduled || !mounted) return;
    _visibilityCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityCheckScheduled = false;
      if (mounted) {
        unawaited(_markNoAudioPhraseWhenVisible());
      }
    });
  }

  Future<void> _markNoAudioPhraseWhenVisible() async {
    final JobSentenceModel phrase = widget.phrase;
    if (phrase.hasAudio ||
        phrase.isLearned ||
        _hasMarkedFromView ||
        _isSubmittingView) {
      return;
    }

    final RenderObject? cardObject = context.findRenderObject();
    final BuildContext? viewportContext =
        _scrollPosition?.context.storageContext;
    final RenderObject? viewportObject = viewportContext?.findRenderObject();
    if (cardObject is! RenderBox ||
        viewportObject is! RenderBox ||
        !cardObject.attached ||
        !viewportObject.attached ||
        !cardObject.hasSize ||
        !viewportObject.hasSize ||
        cardObject.size.height <= 0) {
      return;
    }

    final Rect cardBounds =
        cardObject.localToGlobal(Offset.zero) & cardObject.size;
    final Rect viewportBounds =
        viewportObject.localToGlobal(Offset.zero) & viewportObject.size;
    if (!cardBounds.overlaps(viewportBounds)) return;

    final Rect visibleBounds = cardBounds.intersect(viewportBounds);
    final double visibleFraction =
        visibleBounds.height / cardObject.size.height;
    if (visibleFraction < 0.5) return;

    _isSubmittingView = true;
    final bool wasMarked =
        await controller.markSentenceLearnedWhenVisible(phrase);
    if (!mounted) return;
    _isSubmittingView = false;
    _hasMarkedFromView = wasMarked;
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_scheduleVisibilityCheck);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final JobSentenceModel phrase = widget.phrase;
      final bool isCurrent =
          controller.currentAudioSentenceId.value == phrase.id;
      final bool isLoading = isCurrent && controller.isAudioLoading.value;
      final bool isPlaying = isCurrent && controller.isAudioPlaying.value;
      final Duration duration = isCurrent
          ? controller.audioDuration.value
          : Duration(seconds: phrase.voiceDurationSeconds);
      final Duration position = isCurrent
          ? controller.audioPosition.value
          : Duration.zero;
      final double maxMilliseconds = duration.inMilliseconds <= 0
          ? 1
          : duration.inMilliseconds.toDouble();
      final double currentMilliseconds = position.inMilliseconds
          .clamp(0, maxMilliseconds.round())
          .toDouble();

      return GestureDetector(
        onTap: phrase.hasAudio
            ? () => controller.toggleSentenceAudio(phrase)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          constraints: BoxConstraints(minHeight: isCurrent ? 220.h : 145.h),
          padding: EdgeInsets.fromLTRB(28.w, 27.h, 28.w, 24.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(40.r),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFF70FF35)
                  : AppColors.white,
              width: 2.w,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 18.r,
                offset: Offset(0, 9.h),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          phrase.italianSentence,
                          style: TextStyle(
                            fontSize: 24.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        if (phrase.bengaliTranslation.isNotEmpty) ...<Widget>[
                          SizedBox(height: 12.h),
                          Text(
                            phrase.bengaliTranslation,
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF777C80),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  _AudioActionButton(
                    hasAudio: phrase.hasAudio,
                    isLoading: isLoading,
                    isPlaying: isPlaying,
                  ),
                ],
              ),
              if (phrase.isLearned) ...<Widget>[
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5FFD7),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'LEARNED',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
              if (isCurrent && phrase.hasAudio) ...<Widget>[
                SizedBox(height: 22.h),
                Row(
                  children: <Widget>[
                    Text(
                      _formatDuration(position),
                      style: _durationStyle(),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 5.h,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 6.r,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 12.r,
                          ),
                        ),
                        child: Slider(
                          value: currentMilliseconds,
                          max: maxMilliseconds,
                          onChanged: controller.seekAudio,
                          activeColor: AppColors.primaryGreen,
                          inactiveColor: const Color(0xFFE3E5E5),
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: _durationStyle(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  TextStyle _durationStyle() {
    return TextStyle(
      fontSize: AppFont.font11.sp,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF7D8285),
    );
  }

  String _formatDuration(Duration value) {
    final int minutes = value.inMinutes;
    final int seconds = value.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _AudioActionButton extends StatelessWidget {
  const _AudioActionButton({
    required this.hasAudio,
    required this.isLoading,
    required this.isPlaying,
  });

  final bool hasAudio;
  final bool isLoading;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        color: hasAudio ? const Color(0xFFCFFFAD) : const Color(0xFFE8EAE9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryGreen,
                ),
              )
            : Icon(
                !hasAudio
                    ? Icons.volume_off_rounded
                    : isPlaying
                    ? Icons.pause_rounded
                    : Icons.volume_up_rounded,
                size: 29.r,
                color: hasAudio
                    ? AppColors.primaryGreen
                    : const Color(0xFF9EA2A5),
              ),
      ),
    );
  }
}

class _PhraseMessageState extends StatelessWidget {
  const _PhraseMessageState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6D7276),
            ),
          ),
          if (onRetry != null) ...<Widget>[
            SizedBox(height: 10.h),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
