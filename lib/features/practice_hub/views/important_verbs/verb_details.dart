import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../controllers/practice_hub_controller.dart';

class VerbDetailsView extends GetView<PracticeHubController> {
  const VerbDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final Map<String, dynamic> verb = controller.currentVerbDetails;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 42.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _VerbDetailsTopBar(),

                SizedBox(height: 13.h),

                _VerbHeroCard(verb: verb),

                SizedBox(height: 20.h),

                _VerbInformationCard(verb: verb),

                SizedBox(height: 32.h),

                Text(
                  'Verb Forms & Tenses',
                  style: TextStyle(
                    fontSize: 20.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.45,
                    color: const Color(0xFF33383C),
                  ),
                ),

                SizedBox(height: 24.h),

                _TenseTile(title: 'Infinitive'),

                SizedBox(height: 14.h),

                const _PresentTenseCard(),

                SizedBox(height: 14.h),

                _TenseTile(title: 'Present Perfect'),

                SizedBox(height: 14.h),

                _TenseTile(title: 'Imperfect'),

                SizedBox(height: 14.h),

                _TenseTile(title: 'Future'),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _VerbDetailsTopBar extends GetView<PracticeHubController> {
  const _VerbDetailsTopBar();

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
          GestureDetector(
            onTap: controller.onVerbTranslateTap,
            child: SizedBox(
              width: 34.r,
              height: 34.r,
              child: Icon(
                Icons.translate_rounded,
                size: 24.r,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerbHeroCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> verb;

  const _VerbHeroCard({required this.verb});

  @override
  Widget build(BuildContext context) {
    final String id = verb['id'] as String? ?? '';
    final String title = (verb['title'] as String? ?? '').toUpperCase();
    final String english = verb['english'] as String? ?? '';
    final String bangla = verb['bangla'] as String? ?? '';

    return Container(
      width: double.infinity,
      height: 162.h,
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
            title,
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
            '($english / $bangla)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              height: 1,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.72),
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: controller.toggleSelectedVerbSaved,
                child: Obx(
                  () => Icon(
                    controller.isVerbSaved(id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 39.r,
                    color: const Color(0xFFC3F2A5),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: controller.playSelectedVerbAudio,
                child: Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.22),
                      width: 1.2.w,
                    ),
                  ),
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: 28.r,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerbInformationCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> verb;

  const _VerbInformationCard({required this.verb});

  @override
  Widget build(BuildContext context) {
    final String typeLabel = verb['typeLabel'] as String? ?? 'Regular Verb';
    final String endingLabel = verb['endingLabel'] as String? ?? '-are Verb';
    final String information =
        verb['information'] as String? ??
        'A regular verb used for speaking or talking.';

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
                    _VerbInfoHeader(expanded: expanded),
                    SizedBox(height: 18.h),
                    Row(
                      children: <Widget>[
                        _InfoPill(label: typeLabel, dark: true),
                        SizedBox(width: 9.w),
                        _InfoPill(label: endingLabel),
                      ],
                    ),
                    SizedBox(height: 17.h),
                    Divider(height: 1.h, color: const Color(0xFFE3E6E4)),
                    SizedBox(height: 17.h),
                    Text(
                      information,
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF747A80),
                      ),
                    ),
                  ],
                )
              : Center(child: _VerbInfoHeader(expanded: expanded)),
        ),
      );
    });
  }
}

class _VerbInfoHeader extends StatelessWidget {
  final bool expanded;

  const _VerbInfoHeader({required this.expanded});

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
            'Verb Information',
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
  final String label;
  final bool dark;

  const _InfoPill({required this.label, this.dark = false});

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
          label,
          style: TextStyle(
            fontSize: 11.sp,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: dark ? AppColors.white : AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}

class _TenseTile extends GetView<PracticeHubController> {
  final String title;

  const _TenseTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.toggleVerbTense(title),
      child: Container(
        width: double.infinity,
        height: 62.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
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
            Text(
              title,
              style: TextStyle(
                fontSize: 19.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: const Color(0xFF34393D),
              ),
            ),
            const Spacer(),
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

class _PresentTenseCard extends GetView<PracticeHubController> {
  const _PresentTenseCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool expanded = controller.isVerbTenseExpanded('Present');

      if (!expanded) {
        return const _TenseTile(title: 'Present');
      }

      final List<Map<String, dynamic>> forms =
          controller.selectedVerbPresentForms;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: 4.w,
                margin: EdgeInsets.only(left: 0.w, top: 28.h, bottom: 28.h),
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
                        onTap: () => controller.toggleVerbTense('Present'),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Present',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
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
                      SizedBox(height: 6.h),
                      Text(
                        controller.selectedVerbTenseSubtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF777D82),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Used to describe actions happening right now or habitual actions.',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          height: 1.32,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF777D82),
                        ),
                      ),
                      SizedBox(height: 17.h),
                      Divider(height: 1.h, color: const Color(0xFFE5E8E6)),
                      SizedBox(height: 21.h),
                      if (forms.isNotEmpty) _FocusedFormCard(form: forms.first),
                      if (forms.length > 1) SizedBox(height: 17.h),
                      ...forms.skip(1).toList().asMap().entries.map((
                        MapEntry<int, Map<String, dynamic>> entry,
                      ) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key == forms.length - 2 ? 0 : 14.h,
                          ),
                          child: _VerbFormRow(
                            form: entry.value,
                            softBackground: entry.key.isOdd,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _FocusedFormCard extends StatelessWidget {
  final Map<String, dynamic> form;

  const _FocusedFormCard({required this.form});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> examples =
        (form['examples'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF4),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: const Color(0xFFE8F1E2), width: 1.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Column(
          children: <Widget>[
            Container(
              height: 51.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              color: const Color(0xFFE9FBD8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            '${form['pronoun']} ${form['form']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20.sp,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.35,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        SizedBox(width: 7.w),
                        _SmallAudioButton(text: form['form'] as String? ?? ''),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Flexible(
                    child: Text(
                      '${form['bangla']} (${form['english']})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 17.h),
              child: Column(
                children: examples
                    .map(
                      (Map<String, dynamic> example) =>
                          _ExampleSentenceTile(example: example),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleSentenceTile extends StatelessWidget {
  final Map<String, dynamic> example;

  const _ExampleSentenceTile({required this.example});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  example['italian'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4A4F53),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _SmallAudioButton(text: example['italian'] as String? ?? ''),
            ],
          ),
          SizedBox(height: 7.h),
          Text(
            '${example['bangla']}  (${example['english']})',
            style: TextStyle(
              fontSize: 12.5.sp,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF747A80),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerbFormRow extends StatelessWidget {
  final Map<String, dynamic> form;
  final bool softBackground;

  const _VerbFormRow({required this.form, required this.softBackground});

  @override
  Widget build(BuildContext context) {
    final String pronoun = form['pronoun'] as String? ?? '';
    final String conjugated = form['form'] as String? ?? '';
    final bool twoLine = pronoun.contains('/');

    return Container(
      height: 58.h,
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: softBackground ? const Color(0xFFF5F8F5) : AppColors.transparent,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 92.w,
            child: Text(
              twoLine ? '$pronoun\n$conjugated' : '$pronoun $conjugated',
              style: TextStyle(
                fontSize: 18.sp,
                height: twoLine ? 1.25 : 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: const Color(0xFF3E4448),
              ),
            ),
          ),
          _SmallAudioButton(text: conjugated),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '${form['bangla']} (${form['english']})',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5.sp,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF737A80),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallAudioButton extends GetView<PracticeHubController> {
  final String text;

  const _SmallAudioButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.playVerbFormAudio(text),
      child: Icon(
        Icons.volume_up_rounded,
        size: 17.r,
        color: AppColors.primaryGreen,
      ),
    );
  }
}
