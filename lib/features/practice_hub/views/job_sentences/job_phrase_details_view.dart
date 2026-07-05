import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/job_sentences_controller.dart';
import '../../models/job_sentence_models.dart';

class JobPhraseDetailsScreen extends GetView<JobSentencesController> {
  const JobPhraseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () {
            return controller.loadModuleSentences(
              showError: false,
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              24.w,
              24.h,
              24.w,
              48.h,
            ),
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
    );
  }
}

class _PhraseDetailsHeader
    extends GetView<JobSentencesController> {
  const _PhraseDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final JobModuleSentenceSummaryModel? summary =
          controller.moduleSummary.value;

      final String title =
          summary?.name ??
              controller.selectedModule.value?.name ??
              'Job Sentences';

      final int completed =
          summary?.learnedSentences ??
              controller
                  .selectedModule
                  .value
                  ?.learnedSentenceCount ??
              0;

      final int total =
          summary?.totalSentences ??
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

        ],
      );
    });
  }
}

class _PhraseSearchField
    extends GetView<JobSentencesController> {
  const _PhraseSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57.h,
      padding: EdgeInsets.symmetric(
        horizontal: 19.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          999.r,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
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
                hintText: 'gen_search_phrases'.tr,
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
                color: const Color(
                  0xFF9EA2A5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhraseList
    extends GetView<JobSentencesController> {
  const _PhraseList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSentencesLoading.value &&
          controller.sentences.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: 100.h,
          ),
          child: const CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        );
      }

      if (controller.sentencesError.value.isNotEmpty &&
          controller.sentences.isEmpty) {
        return _PhraseMessageState(
          message: controller.sentencesError.value,
          onRetry: () {
            controller.loadModuleSentences();
          },
        );
      }

      if (controller.sentences.isEmpty) {
        return _PhraseMessageState(
          message: controller.searchQuery.value.isEmpty
              ? 'no_sentences_are_available_in_this_module'
              .tr
              : 'no_sentences_match_your_search'.tr,
        );
      }

      return Column(
        children: controller.sentences
            .map(
              (JobSentenceModel phrase) => Padding(
            padding: EdgeInsets.only(
              bottom: 24.h,
            ),
            child: _PhraseCard(
              key: ValueKey<String>(
                phrase.id,
              ),
              phrase: phrase,
            ),
          ),
        )
            .toList(
          growable: false,
        ),
      );
    });
  }
}

class _PhraseCard
    extends GetView<JobSentencesController> {
  const _PhraseCard({
    required this.phrase,
    super.key,
  });

  final JobSentenceModel phrase;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCurrent =
          controller.currentTtsSentenceId.value ==
              phrase.id;

      final bool isSpeaking =
          isCurrent &&
              controller.isTtsSpeaking.value;

      return GestureDetector(
        onTap: () {
          controller.toggleSentenceTts(
            phrase,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 145.h,
          ),
          padding: EdgeInsets.fromLTRB(
            28.w,
            27.h,
            28.w,
            24.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              40.r,
            ),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFF70FF35)
                  : AppColors.white,
              width: 2.w,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 18.r,
                offset: Offset(0, 9.h),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          phrase.italianSentence,
                          style: TextStyle(
                            fontSize: 24.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color:
                            AppColors.primaryGreen,
                          ),
                        ),
                        if (phrase
                            .bengaliTranslation
                            .isNotEmpty) ...<Widget>[
                          SizedBox(height: 12.h),
                          Text(
                            phrase.bengaliTranslation,
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.35,
                              fontWeight:
                              FontWeight.w500,
                              color: const Color(
                                0xFF777C80,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  _TtsActionButton(
                    isSpeaking: isSpeaking,
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
                      color: const Color(
                        0xFFE5FFD7,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        999.r,
                      ),
                    ),
                    child: Text(
                      'completed'.tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight:
                        FontWeight.w900,
                        color:
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _TtsActionButton extends StatelessWidget {
  const _TtsActionButton({
    required this.isSpeaking,
  });

  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.r,
      height: 56.r,
      decoration: const BoxDecoration(
        color: Color(0xFFCFFFAD),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isSpeaking
              ? Icons.stop_rounded
              : Icons.volume_up_rounded,
          size: 29.r,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _PhraseMessageState
    extends StatelessWidget {
  const _PhraseMessageState({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          30.r,
        ),
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
              child: Text('retry'.tr),
            ),
          ],
        ],
      ),
    );
  }
}