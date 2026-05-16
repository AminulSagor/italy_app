import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvTemplateCard extends StatelessWidget {
  final double width;
  final String title;
  final String? tag;
  final Color? tagColor;
  final bool isSelected;
  final bool isComingSoon;
  final VoidCallback onTap;

  const CvTemplateCard({
    super.key,
    required this.width,
    required this.title,
    this.tag,
    this.tagColor,
    required this.isSelected,
    this.isComingSoon = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: isComingSoon ? 0.42 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 124.h,
                width: width,
                padding: EdgeInsets.all(9.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(kRadius24.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.homeSecondaryText.withOpacity(0.12),
                    width: isSelected ? 2.4.w : 1.w,
                  ),
                ),
                child: isComingSoon ? _comingSoon() : _templatePreview(),
              ),
              SizedBox(height: 7.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              if (tag != null) ...<Widget>[
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor!.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                  ),
                  child: Text(
                    tag!,
                    style: TextStyle(
                      color: tagColor,
                      fontSize: AppFont.font7.sp,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _templatePreview() {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          top: 0,
          child: CircleAvatar(
            radius: 11.r,
            backgroundColor: AppColors.legacyColorFFD4DEE8,
            child: Icon(
              Icons.person_rounded,
              size: AppFont.font12.sp,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        Positioned(
          left: 28.w,
          top: 6.h,
          child: Container(
            width: 34.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.homeSecondaryText,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 34.h,
          right: 18.w,
          child: Column(
            children: List<Widget>.generate(
              3,
                  (int index) => Container(
                margin: EdgeInsets.only(bottom: 7.h),
                height: 3.h,
                decoration: BoxDecoration(
                  color: AppColors.legacyColorFFE0E1E1,
                  borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 2.h,
          child: Container(
            width: 54.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.homePaleGreen,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: AppFont.font14.sp,
              ),
            ),
          ),
        if (!isSelected)
          Positioned(
            right: 4.w,
            top: 4.h,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFE0E1E1,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _comingSoon() {
    return Center(
      child: Icon(
        Icons.add_rounded,
        size: AppFont.font30.sp,
        color: AppColors.homeSecondaryText,
      ),
    );
  }
}