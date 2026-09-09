import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvBuilderLoadingSkeleton extends StatefulWidget {
  const CvBuilderLoadingSkeleton({super.key});

  @override
  State<CvBuilderLoadingSkeleton> createState() => _CvBuilderLoadingSkeletonState();
}

class _CvBuilderLoadingSkeletonState extends State<CvBuilderLoadingSkeleton>
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
    _opacity = Tween<double>(begin: 0.4, end: 0.78).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 120.h),
        children: <Widget>[
          const _Box(height: 54),
          SizedBox(height: 14.h),
          const _Box(height: 132),
          SizedBox(height: 14.h),
          const _Box(height: 210),
          SizedBox(height: 14.h),
          const _Box(height: 170),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E9E7),
        borderRadius: BorderRadius.circular(18.r),
      ),
    );
  }
}
