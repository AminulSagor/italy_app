import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/chapter_detail_models.dart';

class LessonContentCard extends StatefulWidget {
  final LessonContentModel lesson;

  const LessonContentCard({super.key, required this.lesson});

  @override
  State<LessonContentCard> createState() => _LessonContentCardState();
}

class _LessonContentCardState extends State<LessonContentCard> {
  double sliderValue = 43;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(34.w, 36.h, 34.w, 30.h),
      decoration: BoxDecoration(
        color: AppColors.chapterContentCardBg,
        borderRadius: BorderRadius.circular(kChapterContentCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            lesson.title,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 24.h),

          /// REAL SLIDER
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: AppColors.primaryGreen,
              inactiveTrackColor: AppColors.legacyColorFFD0D1D2,
              thumbColor: AppColors.primaryGreen,
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: sliderValue,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),
          ),

          SizedBox(height: 26.h),
          _AudioControls(),
          SizedBox(height: 24.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.chapterTextPanelBg,
              borderRadius: BorderRadius.circular(kRadius20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  lesson.italianText,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                    height: 1.45,
                  ),
                ),
                Text(
                  lesson.italianHighlightText,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                    height: 1.25,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 16.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.bodyText,
                      height: 1.4,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: 'Mancano le lettere: '),
                      TextSpan(
                        text: lesson.italianMissingText.replaceFirst(
                          'Mancano le lettere: ',
                          '',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.blockDangerRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              '—বাংলা অনুবাদ—',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyText.withAlpha(150),
                height: 1.45,
              ),
            ),
          ),
          8.h.verticalSpace,
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1.4,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: 'ইতালীয় বর্ণমালার ২১টি অক্ষর\nব্যবহৃতহয়। অক্ষর:',
                ),
                TextSpan(
                  text: ' A B\nC D E F G H I L M N O P Q R S T U V Z',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _CircleIcon(icon: Icons.volume_up_rounded),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Row(
            children: <Widget>[
              _SpeedPill(label: '0.75×'),
              4.w.horizontalSpace,
              _SpeedPill(label: '1×', isSelected: true),
              4.w.horizontalSpace,
              _SpeedPill(label: '1.25×'),
            ],
          ),
        ),
        _CircleIcon(icon: Icons.play_arrow_rounded),
      ],
    );
  }
}

class _SpeedPill extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _SpeedPill({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGreen : AppColors.white,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppFont.font11.sp,
          fontWeight: FontWeight.w800,
          color: isSelected ? AppColors.white : AppColors.homePrimaryText,
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;

  const _CircleIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 25.w),
    );
  }
}
