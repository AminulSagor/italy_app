import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';

class HomeSectionSkeleton extends StatefulWidget {
  const HomeSectionSkeleton({
    super.key,
    required this.height,
    this.borderRadius = 18,
  });

  final double height;
  final double borderRadius;

  @override
  State<HomeSectionSkeleton> createState() =>
      _HomeSectionSkeletonState();
}

class _HomeSectionSkeletonState extends State<HomeSectionSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.homeProgressTrack,
          borderRadius: BorderRadius.circular(
            widget.borderRadius.r,
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

class HomeOverviewSkeleton extends StatelessWidget {
  const HomeOverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeSectionSkeleton(
      height: 165,
    );
  }
}

class HomeCurrentChapterSkeleton extends StatelessWidget {
  const HomeCurrentChapterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeSectionSkeleton(
      height: 150,
    );
  }
}

class HomeCareerTracksSkeleton extends StatelessWidget {
  const HomeCareerTracksSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const HomeSectionSkeleton(
          height: 115,
        ),
        SizedBox(height: 12.h),
        const HomeSectionSkeleton(
          height: 115,
        ),
      ],
    );
  }
}

class HomeWebinarSkeleton extends StatelessWidget {
  const HomeWebinarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeSectionSkeleton(
      height: 150,
    );
  }
}