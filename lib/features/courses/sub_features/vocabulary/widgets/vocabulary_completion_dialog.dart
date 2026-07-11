import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../models/vocabulary_models.dart';

class VocabularyCompletionDialog extends StatelessWidget {
  final VocabularyCompletionModel complete;
  final VoidCallback onCloseTap;

  const VocabularyCompletionDialog({
    super.key,
    required this.complete,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: AppColors.lessonShareOverlay,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (
                  BuildContext context,
                  BoxConstraints constraints,
                  ) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    22.w,
                    20.h,
                    22.w,
                    24.h,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 44.h,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: onCloseTap,
                                behavior: HitTestBehavior.opaque,
                                child: SizedBox(
                                  width: 40.w,
                                  height: 40.w,
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: AppColors.white,
                                    size: 22.sp,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'lesson_complete'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppFont.font18.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 40.w),
                            ],
                          ),

                          Expanded(
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(
                                  24.w,
                                  34.h,
                                  24.w,
                                  38.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(
                                    kVocabularyCompletionDialogRadius.r,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: 28.w,
                                          height: 28.w,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primaryGreen,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.menu_book_rounded,
                                            color: AppColors.limeTextColor,
                                            size: 16.sp,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Flexible(
                                          child: Text(
                                            complete.appName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: AppFont.font18.sp,
                                              fontWeight: FontWeight.w800,
                                              color:
                                              AppColors.homePrimaryText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Image.asset(
                                      'assets/decor_png/celebration_confetti.png',
                                      height: 188.h,
                                      width: 188.w,
                                    ),
                                    Text(
                                      'great_job'.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: AppFont.font42.sp,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryGreen,
                                        height: 1,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'you_reviewed_complete_reviewedcount_words'
                                          .trParams(
                                        <String, String>{
                                          'reviewedcount': complete
                                              .reviewedCount
                                              .toString(),
                                        },
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: AppFont.font16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.bodyText,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: _VocabularyResultPill(
                                            icon:
                                            Icons.check_circle_rounded,
                                            value:
                                            '${complete.rightCount} Words',
                                            label: 'gen_right'.tr,
                                            color: AppColors
                                                .vocabularyCompletionRightBg,
                                            textColor:
                                            AppColors.primaryGreen,
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        Expanded(
                                          child: _VocabularyResultPill(
                                            icon: Icons.refresh_rounded,
                                            value:
                                            '${complete.wrongCount} Words',
                                            label: 'gen_wrong'.tr,
                                            color: AppColors
                                                .vocabularyCompletionWrongBg,
                                            textColor: AppColors
                                                .vocabularyStreakText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    CustomButton(
                                      onPressed: _openCommunity,
                                      text:
                                      'join_the_italian_journey'.tr,
                                      height: 44.h,
                                      showShadow: false,
                                      fontSize: 14.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCommunity() async {
    final String url =
        dotenv.env['FACEBOOK_COMMUNITY_URL']?.trim() ?? '';

    final Uri? uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      Get.snackbar(
        'community_link_error'.tr,
        'community_link_not_available'.tr,
      );
      return;
    }

    final bool didOpen = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didOpen) {
      Get.snackbar(
        'community_link_error'.tr,
        'community_link_could_not_open'.tr,
      );
      return;
    }

    // Preserves the existing behavior after opening the community.
    onCloseTap();
  }

}

class _VocabularyResultPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _VocabularyResultPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9999.r),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: textColor, size: 20.w),
          SizedBox(height: 4.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
              color: textColor.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}


