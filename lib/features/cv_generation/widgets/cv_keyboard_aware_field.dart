import 'dart:async';

import 'package:flutter/material.dart';

/// Gives every editable CV field the same keyboard behavior.
///
/// Once the keyboard starts opening, the focused field is moved into the upper
/// safe area of the builder instead of being left behind the keyboard or the
/// bottom PDF action bar.
class CvKeyboardAwareField extends StatefulWidget {
  const CvKeyboardAwareField({
    super.key,
    required this.builder,
    this.alignment = 0.22,
  });

  final Widget Function(BuildContext context, FocusNode focusNode) builder;
  final double alignment;

  @override
  State<CvKeyboardAwareField> createState() => _CvKeyboardAwareFieldState();
}

class _CvKeyboardAwareFieldState extends State<CvKeyboardAwareField> {
  late final FocusNode _focusNode;
  Timer? _ensureVisibleTimer;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) return;

    _ensureVisibleTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());

    // Android/iOS keyboard animations are not always complete in the first
    // frame. A short second pass prevents fields near the bottom from settling
    // underneath the keyboard.
    _ensureVisibleTimer = Timer(
      const Duration(milliseconds: 260),
      _ensureVisible,
    );
  }

  Future<void> _ensureVisible() async {
    if (!mounted || !_focusNode.hasFocus) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: widget.alignment,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _focusNode);

  @override
  void dispose() {
    _ensureVisibleTimer?.cancel();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }
}
