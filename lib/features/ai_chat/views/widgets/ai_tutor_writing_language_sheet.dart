import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_colors.dart';
import '../../models/ai_tutor_models.dart';

class AiTutorWritingLanguageDialog extends StatelessWidget {
  const AiTutorWritingLanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w),
        child: Container(
          padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 22.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'choose_your_help_language'.tr,
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF26312E),
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          'the_tutor_will_explain_briefly_in_this_language'.tr +
                          'and help you write natural Italian.',
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF78817D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22.r,
                      color: const Color(0xFF6D7773),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _WritingLanguageOption(
                title: 'gen_english_italian'.tr,
                subtitle: 'gen_short_english_explanations_for'.tr,
                leadingText: 'gen_en'.tr,
                onTap: () => Navigator.of(context).pop(
                  AiTutorWritingSourceLanguage.english,
                ),
              ),
              SizedBox(height: 12.h),
              _WritingLanguageOption(
                title: 'gen_bangla_italian'.tr,
                subtitle: 'বাংলায় সংক্ষিপ্ত ব্যাখ্যাসহ ইতালীয় লেখা'.tr,
                leadingText: 'বাং'.tr,
                onTap: () => Navigator.of(context).pop(
                  AiTutorWritingSourceLanguage.bangla,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WritingLanguageOption extends StatelessWidget {
  const _WritingLanguageOption({
    required this.title,
    required this.subtitle,
    required this.leadingText,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String leadingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2FAEF),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            children: <Widget>[
              Container(
                width: 46.r,
                height: 46.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  leadingText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF26312E),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF74807B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20.r,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
