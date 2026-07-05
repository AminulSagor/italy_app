import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';

class CvThinkingBubble extends StatefulWidget {
  const CvThinkingBubble({
    this.message,
    super.key,
  });

  final String? message;

  @override
  State<CvThinkingBubble> createState() =>
      _CvThinkingBubbleState();
}

class _CvThinkingBubbleState
    extends State<CvThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String displayedMessage =
    widget.message?.trim().isNotEmpty == true
        ? widget.message!.trim()
        : 'cv_thinking_default'.tr;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 0.82.sw,
        ),
        margin: EdgeInsets.only(
          bottom: 12.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 13.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
            bottomLeft: Radius.circular(5.r),
            bottomRight: Radius.circular(20.r),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.auto_awesome_rounded,
              size: 18.w,
              color: AppColors.primaryGreen,
            ),
            SizedBox(width: 9.w),
            Flexible(
              child: Text(
                displayedMessage,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            AnimatedBuilder(
              animation: _controller,
              builder: (
                  BuildContext context,
                  Widget? child,
                  ) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                    3,
                        (int index) {
                      final double position =
                          (_controller.value -
                              (index * 0.18)) %
                              1;

                      final double opacity =
                      position < 0.5
                          ? 0.35 + (position * 1.3)
                          : 1 -
                          ((position - 0.5) *
                              1.3);

                      return Container(
                        width: 5.w,
                        height: 5.w,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : 3.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen
                              .withValues(
                            alpha: opacity.clamp(
                              0.3,
                              1,
                            ),
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}