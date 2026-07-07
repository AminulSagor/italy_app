import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_colors.dart';
import '../themes/app_constants.dart';
import '../themes/app_font.dart';

class OtpCodeInputRow extends StatelessWidget {
  const OtpCodeInputRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    this.onCompleted,
    this.boxSize,
    super.key,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function({required int index, required String value}) onChanged;
  final VoidCallback? onCompleted;
  final double? boxSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(
        controllers.length,
        (int index) => _OtpCodeInputBox(
          controller: controllers[index],
          focusNode: focusNodes[index],
          index: index,
          isLast: index == controllers.length - 1,
          onChanged: onChanged,
          onCompleted: onCompleted,
          boxSize: boxSize,
        ),
      ),
    );
  }
}

class _OtpCodeInputBox extends StatelessWidget {
  const _OtpCodeInputBox({
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.isLast,
    required this.onChanged,
    required this.onCompleted,
    this.boxSize,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final bool isLast;
  final void Function({required int index, required String value}) onChanged;
  final VoidCallback? onCompleted;
  final double? boxSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (BuildContext context, Widget? child) {
        final bool isFocused = focusNode.hasFocus;
        final double resolvedBoxSize = boxSize ?? 76.w;

        return SizedBox(
          width: resolvedBoxSize,
          height: resolvedBoxSize,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.legacyColorFFF8F8F8,
              border: Border.all(
                color: isFocused
                    ? AppColors.primaryGreen
                    : AppColors.legacyColorFFCDE6BD,
                width: isFocused ? 2.1 : 1.6,
              ),
              boxShadow: <BoxShadow>[
                if (isFocused)
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                  ),
              ],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
              maxLength: 1,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              onChanged: (String value) {
                onChanged(index: index, value: value);
                if (isLast && value.trim().isNotEmpty) {
                  onCompleted?.call();
                }
              },
              onSubmitted: (_) => onCompleted?.call(),
              style: TextStyle(
                color: AppColors.legacyColorFF646C7A,
                fontSize: AppFont.font28.sp,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
