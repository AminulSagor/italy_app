import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_assistant_models.dart';

class CvValidationPanel extends StatelessWidget {
  const CvValidationPanel({
    required this.generationBlockers,
    required this.missingRequiredFields,
    required this.missingTemplateSections,
    required this.unresolvedOptionalSections,
    required this.pendingSuggestionCount,
    required this.photoDecision,
    required this.qualityIssues,
    required this.onClose,
    super.key,
  });

  final List<String> generationBlockers;
  final List<String> missingRequiredFields;
  final List<String> missingTemplateSections;
  final List<String> unresolvedOptionalSections;
  final int pendingSuggestionCount;
  final CvAssistantPhotoDecision photoDecision;
  final List<String> qualityIssues;
  final VoidCallback onClose;

  bool get _photoDecisionUnresolved {
    return photoDecision ==
        CvAssistantPhotoDecision.unresolved;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAnyIssue =
        generationBlockers.isNotEmpty ||
            missingRequiredFields.isNotEmpty ||
            missingTemplateSections.isNotEmpty ||
            unresolvedOptionalSections.isNotEmpty ||
            pendingSuggestionCount > 0 ||
            _photoDecisionUnresolved ||
            qualityIssues.isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 0.42.sh,
      ),
      margin: EdgeInsets.fromLTRB(
        16.w,
        5.h,
        16.w,
        7.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFFFC66B),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              15.w,
              13.h,
              8.w,
              8.h,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius:
                    BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.fact_check_outlined,
                    size: 21.w,
                    color: const Color(0xFFB86B00),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'cv_validation_title'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color:
                          AppColors.homePrimaryText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'cv_validation_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: AppColors
                              .homeSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15.w),
              child: hasAnyIssue
                  ? Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  if (generationBlockers
                      .isNotEmpty)
                    _ValidationGroup(
                      title:
                      'cv_validation_generation_requirements'.tr,
                      icon: Icons
                          .info_outline_rounded,
                      items:
                      generationBlockers,
                    ),

                  if (missingRequiredFields
                      .isNotEmpty)
                    _ValidationGroup(
                      title:
                      'cv_validation_required_information'.tr,
                      icon: Icons
                          .assignment_late_outlined,
                      items:
                      missingRequiredFields,
                    ),

                  if (missingTemplateSections
                      .isNotEmpty)
                    _ValidationGroup(
                      title:       'cv_validation_template_sections'.tr,
                      icon: Icons
                          .view_agenda_outlined,
                      items:
                      missingTemplateSections,
                    ),

                  if (unresolvedOptionalSections
                      .isNotEmpty)
                    _ValidationGroup(
                      title:
                      'cv_validation_optional_sections'.tr,
                      icon: Icons
                          .playlist_add_check_rounded,
                      items:
                      unresolvedOptionalSections,
                    ),

                  if (pendingSuggestionCount > 0)
                    _ValidationGroup(
                      title: 'cv_validation_suggestions'.tr,
                      icon: Icons
                          .auto_awesome_outlined,
                      items: <String>[
                        pendingSuggestionCount == 1
                            ? 'cv_validation_one_suggestion'.tr
                            : 'cv_validation_multiple_suggestions'
                      ],
                    ),

                  if (_photoDecisionUnresolved)
                     _ValidationGroup(
                      title: 'cv_validation_profile_photo'.tr,
                      icon: Icons
                          .account_circle_outlined,
                      items: <String>[
                        'cv_validation_photo_instruction'.tr,
                      ],
                    ),

                  if (qualityIssues.isNotEmpty)
                    _ValidationGroup(
                      title: 'cv_validation_quality_issues'.tr,
                      icon: Icons
                          .report_problem_outlined,
                      items: qualityIssues,
                    ),
                ],
              )
                  : Text(
                'cv_validation_remaining_steps'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  color:
                  AppColors.homeSecondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationGroup extends StatelessWidget {
  const _ValidationGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final List<String> validItems = items
        .map(
          (String item) => item.trim(),
    )
        .where(
          (String item) => item.isNotEmpty,
    )
        .toSet()
        .toList();

    if (validItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 15.h,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                size: 18.w,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: 7.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color:
                  AppColors.homePrimaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          ...validItems.map(
                (String item) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 4.w,
                  bottom: 6.h,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 6.h,
                      ),
                      child: Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: const BoxDecoration(
                          color:
                          AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          height: 1.4,
                          color: AppColors
                              .homeSecondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}