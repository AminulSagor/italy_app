import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../controllers/important_verbs_controller.dart';
import '../../../models/important_verb_detail_models.dart';
import '../../../models/important_verb_models.dart';
import 'important_verb_pronunciation_widgets.dart';

class VerbDetailsTopBar extends GetView<ImportantVerbsController> {
  const VerbDetailsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: controller.onVerbDetailBackTap,
            child: SizedBox(
              width: 30.r,
              height: 30.r,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22.r,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Coniugazione',
            style: TextStyle(
              fontSize: 17.sp,
              height: 1,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF565D62),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.translate_rounded,
            size: 24.r,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class VerbHeroCard extends GetView<ImportantVerbsController> {
  const VerbHeroCard({super.key, required this.verb});

  final ImportantVerbSummaryModel verb;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 162.h),
      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 22.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF236F00), Color(0xFF1C6400)],
        ),
        borderRadius: BorderRadius.circular(38.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1E5F00).withValues(alpha: 0.25),
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            verb.infinitive.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 30.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '(${verb.englishMeaning} / ${verb.banglaMeaning})',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.72),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => controller.toggleVerbSaved(verb),
                child: Obx(
                  () => Icon(
                    controller.isVerbSaved(verb.id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 39.r,
                    color: const Color(0xFFC3F2A5),
                  ),
                ),
              ),
              const Spacer(),
              PronunciationButton(
                tts: verb.tts,
                large: true,
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.white.withValues(alpha: 0.18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VerbInformationCard extends GetView<ImportantVerbsController> {
  const VerbInformationCard({super.key, required this.information});

  final ImportantVerbInformationModel information;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool expanded = controller.isVerbInfoExpanded.value;
      return GestureDetector(
        onTap: controller.toggleVerbInformation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            24.w,
            expanded ? 23.h : 0,
            24.w,
            expanded ? 24.h : 0,
          ),
          constraints: BoxConstraints(minHeight: 72.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(38.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 25.r,
                offset: Offset(0, 11.h),
              ),
            ],
          ),
          child: expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _VerbInfoHeader(
                      title: information.title,
                      expanded: true,
                    ),
                    if (information.badges.isNotEmpty) ...<Widget>[
                      SizedBox(height: 18.h),
                      Wrap(
                        spacing: 9.w,
                        runSpacing: 8.h,
                        children: information.badges
                            .asMap()
                            .entries
                            .map(
                              (MapEntry<int, String> entry) => _InfoPill(
                                label: entry.value,
                                dark: entry.key == 0,
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                    if (information.description.isNotEmpty) ...<Widget>[
                      SizedBox(height: 17.h),
                      Divider(height: 1.h, color: const Color(0xFFE3E6E4)),
                      SizedBox(height: 17.h),
                      Text(
                        information.description,
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF747A80),
                        ),
                      ),
                    ],
                  ],
                )
              : Center(
                  child: _VerbInfoHeader(
                    title: information.title,
                    expanded: false,
                  ),
                ),
        ),
      );
    });
  }
}

class _VerbInfoHeader extends StatelessWidget {
  const _VerbInfoHeader({required this.title, required this.expanded});

  final String title;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.info_outline_rounded,
          size: 22.r,
          color: AppColors.primaryGreen,
        ),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        Icon(
          expanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: 24.r,
          color: const Color(0xFF2E7769),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: dark ? AppColors.primaryGreen : const Color(0xFFDFF8C8),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.sp,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            color: dark ? AppColors.white : AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}

class VerbFormSection extends GetView<ImportantVerbsController> {
  const VerbFormSection({super.key, required this.form});

  final ImportantVerbFormModel form;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool expanded = controller.expandedFormId.value == form.id;
      if (!expanded) {
        return _CollapsedVerbForm(
          form: form,
          onTap: () => controller.toggleVerbForm(form.id),
        );
      }
      return _ExpandedVerbForm(
        form: form,
        onCollapse: () => controller.toggleVerbForm(form.id),
      );
    });
  }
}

class _CollapsedVerbForm extends StatelessWidget {
  const _CollapsedVerbForm({required this.form, required this.onTap});

  final ImportantVerbFormModel form;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 62.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    form.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF34393D),
                    ),
                  ),
                  if (form.titleIt.isNotEmpty && form.titleIt != form.title) ...<Widget>[
                    SizedBox(height: 5.h),
                    Text(
                      form.titleIt,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF777D82),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 23.r,
              color: const Color(0xFF777F82),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedVerbForm extends StatelessWidget {
  const _ExpandedVerbForm({required this.form, required this.onCollapse});

  final ImportantVerbFormModel form;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(38.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 4.w,
            height: 72.h,
            margin: EdgeInsets.only(top: 28.h),
            decoration: BoxDecoration(
              color: const Color(0xFF9DFF67),
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(23.w, 25.h, 21.w, 27.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: onCollapse,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            form.title,
                            style: TextStyle(
                              fontSize: 20.sp,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 24.r,
                          color: const Color(0xFF2E7769),
                        ),
                      ],
                    ),
                  ),
                  if (form.titleIt.isNotEmpty) ...<Widget>[
                    SizedBox(height: 6.h),
                    Text(
                      form.titleIt,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF777D82),
                      ),
                    ),
                  ],
                  if (form.description.isNotEmpty) ...<Widget>[
                    SizedBox(height: 16.h),
                    Text(
                      form.description,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF777D82),
                      ),
                    ),
                  ],
                  SizedBox(height: 17.h),
                  Divider(height: 1.h, color: const Color(0xFFE5E8E6)),
                  SizedBox(height: 19.h),
                  if (form.conjugations.isEmpty)
                    Text(
                      'No conjugations available.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF777D82),
                      ),
                    )
                  else
                    ...form.conjugations.asMap().entries.map(
                      (MapEntry<int, ImportantVerbConjugationModel> entry) =>
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == form.conjugations.length - 1
                                  ? 0
                                  : 14.h,
                            ),
                            child: VerbConjugationCard(
                              conjugation: entry.value,
                              highlighted: entry.key == 0,
                            ),
                          ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

