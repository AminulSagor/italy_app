import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerbLibrarySkeleton extends StatelessWidget {
  const VerbLibrarySkeleton({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return _VerbLoadingPulse(
      child: Column(
        children: List<Widget>.generate(
          itemCount,
              (int index) => Padding(
            padding: EdgeInsets.only(
              bottom: index == itemCount - 1 ? 0 : 14.h,
            ),
            child: const _VerbCardSkeleton(),
          ),
        ),
      ),
    );
  }
}

class VerbLoadMoreSkeleton extends StatelessWidget {
  const VerbLoadMoreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const _VerbLoadingPulse(
      child: _VerbCardSkeleton(),
    );
  }
}

class SearchSuggestionSkeleton extends StatelessWidget {
  const SearchSuggestionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _VerbLoadingPulse(
      child: Column(
        children: List<Widget>.generate(
          2,
              (int index) => Container(
            height: 66.h,
            padding: EdgeInsets.symmetric(
              horizontal: 17.w,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: index == 0
                    ? const BorderSide(
                  color: Color(0xFFECEDED),
                )
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: <Widget>[
                _SkeletonBox(
                  width: 35.r,
                  height: 35.r,
                  borderRadius: 100,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      _SkeletonBox(
                        width: 105.w,
                        height: 13.h,
                        borderRadius: 8,
                      ),
                      SizedBox(height: 8.h),
                      _SkeletonBox(
                        width: 170.w,
                        height: 9.h,
                        borderRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SavedVerbPreviewSkeleton extends StatelessWidget {
  const SavedVerbPreviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _VerbLoadingPulse(
      child: SizedBox(
        height: 164.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, _) => SizedBox(width: 16.w),
          itemBuilder: (_, _) {
            return Container(
              width: 125.w,
              height: 164.h,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: const Color(0xFFE5E7E8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SkeletonBox(
                    width: 30.r,
                    height: 30.r,
                    borderRadius: 100,
                  ),
                  const Spacer(),
                  _SkeletonBox(
                    width: 84.w,
                    height: 15.h,
                    borderRadius: 8,
                  ),
                  SizedBox(height: 10.h),
                  _SkeletonBox(
                    width: 65.w,
                    height: 9.h,
                    borderRadius: 8,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class VerbDetailsSkeleton extends StatelessWidget {
  const VerbDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _VerbLoadingPulse(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,

            // Do not give this container a fixed height.
            // Let its content determine the required height.
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 20.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SkeletonBox(
                  width: 180.w,
                  height: 20.h,
                  borderRadius: 10,
                ),
                SizedBox(height: 18.h),
                _SkeletonBox(
                  width: 125.w,
                  height: 24.h,
                  borderRadius: 999,
                ),
                SizedBox(height: 16.h),
                _SkeletonBox(
                  width: double.infinity,
                  height: 12.h,
                  borderRadius: 8,
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          _SkeletonBox(
            width: 150.w,
            height: 19.h,
            borderRadius: 9,
          ),

          SizedBox(height: 24.h),

          ...List<Widget>.generate(
            3,
                (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == 2 ? 0 : 14.h,
                ),
                child: _SkeletonBox(
                  width: double.infinity,
                  height: 64.h,
                  borderRadius: 32,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VerbCardSkeleton extends StatelessWidget {
  const _VerbCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 134.h,
      padding: EdgeInsets.fromLTRB(
        19.w,
        17.h,
        17.w,
        17.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _SkeletonBox(
                      width: 62.w,
                      height: 19.h,
                      borderRadius: 999,
                    ),
                    SizedBox(width: 7.w),
                    _SkeletonBox(
                      width: 44.w,
                      height: 19.h,
                      borderRadius: 999,
                    ),
                  ],
                ),
                SizedBox(height: 13.h),
                _SkeletonBox(
                  width: 130.w,
                  height: 22.h,
                  borderRadius: 10,
                ),
                SizedBox(height: 11.h),
                _SkeletonBox(
                  width: 180.w,
                  height: 11.h,
                  borderRadius: 8,
                ),
                SizedBox(height: 9.h),
                _SkeletonBox(
                  width: 145.w,
                  height: 11.h,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _SkeletonBox(
            width: 40.r,
            height: 40.r,
            borderRadius: 100,
          ),
          SizedBox(width: 9.w),
          _SkeletonBox(
            width: 40.r,
            height: 40.r,
            borderRadius: 100,
          ),
        ],
      ),
    );
  }
}

class _VerbLoadingPulse extends StatefulWidget {
  const _VerbLoadingPulse({
    required this.child,
  });

  final Widget child;

  @override
  State<_VerbLoadingPulse> createState() =>
      _VerbLoadingPulseState();
}

class _VerbLoadingPulseState
    extends State<_VerbLoadingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 850,
      ),
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.45,
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEA),
        borderRadius: BorderRadius.circular(
          borderRadius.r,
        ),
      ),
    );
  }
}