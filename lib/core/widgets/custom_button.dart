import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../themes/app_colors.dart';
import '../themes/app_constants.dart';
import '../themes/app_font.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double? width;
  final bool isLoading;
  final bool showShadow;
  final bool isElevated;
  final IconData? prefixIcon;
  final IconData? icon;
  final Color btnColor;
  final Color btnShadowColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.height = kButtonDefaultHeight,
    this.width,
    this.isLoading = false,
    this.showShadow = false,
    this.isElevated = false,
    this.prefixIcon,
    this.icon,
    this.btnColor = AppColors.primaryBtnColor,
    this.btnShadowColor = AppColors.primaryBtnShadow,
    this.borderColor = AppColors.primaryBtnColor,
    this.borderRadius = kButtonDefaultRadius,
    this.borderWidth = kButtonBorderWidth,
    this.textColor = AppColors.white,
  });

  const CustomButton.primary({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.prefixIcon,
    this.icon,
    this.isElevated = false,
    this.btnColor = AppColors.primaryBtnColor,
    this.btnShadowColor = AppColors.primaryBtnShadow,
    this.borderColor = AppColors.primaryBtnColor,
    this.borderRadius = kButtonDefaultRadius,
    this.borderWidth = kButtonBorderWidth,
    this.textColor = AppColors.white,
  }) : height = kButtonDefaultHeight,
       width = double.infinity,
       showShadow = true;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  bool get _isEnabled => !widget.isLoading;

  double? get _buttonWidth {
    if (widget.width == null) {
      return null;
    }

    if (widget.width == double.infinity) {
      return double.infinity;
    }

    return widget.width!.w;
  }

  void _setPressed(bool value) {
    if (!_isEnabled || _isPressed == value) {
      return;
    }

    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowShadow = widget.showShadow && !_isPressed;

    return GestureDetector(
      onTap: _isEnabled ? widget.onPressed : null,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        width: _buttonWidth,
        height: widget.height.h,
        transform: Matrix4.translationValues(
          0,
          widget.showShadow && _isPressed ? kButtonShadowOffsetY.h : 0,
          0,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: widget.isLoading
              ? widget.btnColor.withValues(alpha: 0.72)
              : widget.btnColor,
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth.w,
          ),
          boxShadow: shouldShowShadow
              ? <BoxShadow>[
                  BoxShadow(
                    color: widget.btnShadowColor,
                    offset: Offset(0, kButtonShadowOffsetY.h),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: widget.isLoading
            ? _LoadingIcon(color: widget.textColor)
            : _ButtonContent(widget: widget),
      ),
    );
  }
}

class _LoadingIcon extends StatelessWidget {
  final Color color;

  const _LoadingIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.r,
      height: 20.r,
      alignment: Alignment.center,
      child: CircularProgressIndicator(strokeWidth: 2.w, color: color),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final CustomButton widget;

  const _ButtonContent({required this.widget});

  @override
  Widget build(BuildContext context) {
    final String label = widget.text.tr;
    final bool hasLabel = label.trim().isNotEmpty;

    if (!hasLabel) {
      final IconData? icon = widget.icon ?? widget.prefixIcon;

      if (icon != null) {
        return Icon(icon, size: 24.w, color: widget.textColor);
      }

      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.prefixIcon != null) ...<Widget>[
          Icon(widget.prefixIcon, size: 24.w, color: widget.textColor),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: widget.textColor,
            ),
          ),
        ),
        if (widget.icon != null) ...<Widget>[
          SizedBox(width: 8.w),
          Icon(widget.icon, size: 24.w, color: widget.textColor),
        ],
      ],
    );
  }
}
