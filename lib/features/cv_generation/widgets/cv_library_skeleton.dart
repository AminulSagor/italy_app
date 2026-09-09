import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvLibrarySkeleton extends StatelessWidget {
  const CvLibrarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        4,
        (int index) => Container(
          height: 142.h,
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE6EBE8)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 76.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E9E7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 148.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E8E6),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 104.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF0EE),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8ECEA),
                              borderRadius: BorderRadius.circular(11.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Container(
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4E8E6),
                              borderRadius: BorderRadius.circular(11.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
