import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvTemplateGridSkeleton extends StatefulWidget {
  const CvTemplateGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  State<CvTemplateGridSkeleton> createState() => _CvTemplateGridSkeletonState();
}

class _CvTemplateGridSkeletonState extends State<CvTemplateGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.42, end: 0.82).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 14.h,
          childAspectRatio: 0.63,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE7EBE9),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(9.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE2DF),
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE2DF),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
                SizedBox(height: 7.h),
                Container(
                  width: 65.w,
                  height: 9.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE2DF),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
