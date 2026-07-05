import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_assistant_models.dart';

class CvChatActionBar extends StatefulWidget {
  const CvChatActionBar({
    required this.isGenerating,
    required this.isBusy,
    required this.status,
    required this.backendCanGenerate,
    required this.validationComplete,
    required this.qualityCheckPassed,
    required this.hasCurrentQuestion,
    required this.hasGenerationBlockers,
    required this.onGenerate,
    super.key,
  });

  final bool isGenerating;
  final bool isBusy;

  final CvAssistantSessionStatus status;

  final bool backendCanGenerate;
  final bool validationComplete;
  final bool qualityCheckPassed;
  final bool hasCurrentQuestion;
  final bool hasGenerationBlockers;

  final VoidCallback onGenerate;

  @override
  State<CvChatActionBar> createState() =>
      _CvChatActionBarState();
}

class _CvChatActionBarState
    extends State<CvChatActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  bool get _isEligible {
    return widget.status ==
        CvAssistantSessionStatus.readyToGenerate &&
        widget.backendCanGenerate &&
        widget.validationComplete &&
        widget.qualityCheckPassed &&
        !widget.hasCurrentQuestion &&
        !widget.hasGenerationBlockers;
  }

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 950,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.18,
      end: 0.62,
    ).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _glowController.repeat(
      reverse: true,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 320,
      ),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (
          Widget child,
          Animation<double> animation,
          ) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: 1,
            child: child,
          ),
        );
      },
      child: !_isEligible
          ? const SizedBox.shrink(
        key: ValueKey<String>(
          'generate-button-hidden',
        ),
      )
          : AnimatedBuilder(
        key: const ValueKey<String>(
          'generate-button-visible',
        ),
        animation: _glowAnimation,
        builder: (
            BuildContext context,
            Widget? child,
            ) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(
              14.w,
              8.h,
              14.w,
              4.h,
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(16.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primaryGreen
                      .withValues(
                    alpha: _glowAnimation.value,
                  ),
                  blurRadius: 24,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: AppColors.primaryGreen
                      .withValues(
                    alpha:
                    _glowAnimation.value * 0.55,
                  ),
                  blurRadius: 38,
                  spreadRadius: 7,
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: widget.isBusy || widget.isGenerating
                    ? null
                    : widget.onGenerate,
                icon: widget.isGenerating
                    ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.primaryGreen,
                  ),
                )
                    : Icon(
                  Icons.auto_awesome_rounded,
                  size: 20.sp,
                  color: AppColors.primaryGreen,
                ),
                label: Text(
                  widget.isGenerating
                      ? 'cv_chat_action_generating'.tr
                      : 'cv_chat_action_generate'.tr,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  disabledForegroundColor: AppColors.primaryGreen,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 10.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}