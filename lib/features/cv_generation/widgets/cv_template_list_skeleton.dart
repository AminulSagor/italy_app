import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvTemplateListSkeleton extends StatelessWidget {
  const CvTemplateListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(2, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 210 / 297,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E9E7),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 150.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E5E3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 7.h),
                Container(
                  width: 95.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF0EF),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}
