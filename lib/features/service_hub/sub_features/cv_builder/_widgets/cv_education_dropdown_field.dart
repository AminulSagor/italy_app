import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvEducationDropdownField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CvEducationDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AppColors.homeSecondaryText,
            fontSize: AppFont.font8.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
            height: 1,
          ),
        ),
        SizedBox(height: 7.h),
        Container(
          height: 39.h,
          padding: EdgeInsets.only(left: 14.w, right: 12.w),
          decoration: BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.homeSecondaryText,
                size: AppFont.font17.sp,
              ),
              hint: Text(
                hintText,
                style: TextStyle(
                  color: AppColors.homeSecondaryText.withValues(alpha: 0.55),
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              items: items
                  .map(
                    (String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          color: AppColors.homePrimaryText,
                          fontSize: AppFont.font10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
