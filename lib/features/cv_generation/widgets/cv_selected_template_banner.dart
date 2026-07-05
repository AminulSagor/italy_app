import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_template_model.dart';

class CvSelectedTemplateBanner
    extends StatelessWidget {
  const CvSelectedTemplateBanner({
    required this.template,
    super.key,
  });

  final CvTemplateModel template;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        4.h,
      ),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E4),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.primaryGreen
              .withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 44.w,
              height: 58.h,
              color: Colors.white,
              child: Image.network(
                template.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                    ) {
                  return const Icon(
                    Icons.description_outlined,
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'cv_selected_template_label'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:
                    AppColors.homeSecondaryText,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  template.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color:
                    AppColors.homePrimaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.primaryGreen,
            size: 22.w,
          ),
        ],
      ),
    );
  }
}