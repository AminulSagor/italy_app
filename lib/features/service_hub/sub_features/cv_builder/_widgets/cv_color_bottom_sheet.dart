import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import 'cv_bottom_button.dart';

void showCvColorBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => const CvColorBottomSheet(),
  );
}

class CvColorBottomSheet extends StatelessWidget {
  const CvColorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kRadius24.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 34.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFE0E1E1,
                borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFF8F8F8,
                borderRadius: BorderRadius.circular(kRadius20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '⊕  SELECT COLOR',
                    style: TextStyle(
                      color: AppColors.homePrimaryText,
                      fontSize: AppFont.font8.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    height: 160.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kRadius10.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: <Color>[
                          AppColors.serviceHubGreenEnd,
                          AppColors.white,
                          AppColors.black,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 3.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: <Widget>[
                      Text(
                        'Hue',
                        style: TextStyle(
                          color: AppColors.homePrimaryText,
                          fontSize: AppFont.font9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '#3C6A12',
                        style: TextStyle(
                          color: AppColors.homePrimaryText,
                          fontSize: AppFont.font9.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 7.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.cyan,
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.legacyColorFFD0D1D2,
                            width: 1.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      _SheetColorDot(color: AppColors.primaryGreen),
                      _SheetColorDot(color: AppColors.serviceHubLightGreen),
                      _SheetColorDot(color: AppColors.homePaleGreen),
                      _SheetColorDot(color: AppColors.homeOrange),
                      _SheetColorDot(color: AppColors.legacyColorFF646C7A),
                      _SheetColorDot(color: AppColors.legacyColorFFD0D1D2),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            CvBottomButton(
              title: 'Confirm Color',
              onTap: Get.back,
              hasOuterPadding: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetColorDot extends StatelessWidget {
  final Color color;

  const _SheetColorDot({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}