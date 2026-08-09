import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeBottomInset extends StatefulWidget {
  const NativeBottomInset({
    required this.child,
    this.additionalBottom = 0,
    this.ignoreWhenKeyboardVisible = true,
    this.collapseWhenKeyboardVisible = false,
    super.key,
  });

  final Widget child;
  final double additionalBottom;
  final bool ignoreWhenKeyboardVisible;

  // When true, removes all custom bottom padding while keyboard is open.
  final bool collapseWhenKeyboardVisible;

  @override
  State<NativeBottomInset> createState() =>
      _NativeBottomInsetState();
}

class _NativeBottomInsetState extends State<NativeBottomInset>
    with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel(
    'italir_pothe/system_insets',
  );

  double _nativeBottomInset = 0;
  bool _requestInProgress = false;
  bool _refreshPending = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNativeBottomInset();
      }
    });
  }

  @override
  void didChangeMetrics() {
    if (_requestInProgress) {
      _refreshPending = true;
      return;
    }

    _loadNativeBottomInset();
  }

  Future<void> _loadNativeBottomInset() async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    if (_requestInProgress) {
      _refreshPending = true;
      return;
    }

    _requestInProgress = true;

    try {
      final num? result = await _channel.invokeMethod<num>(
        'getNavigationBarBottomInset',
      );

      final double updatedInset = (result?.toDouble() ?? 0)
          .clamp(0, 200)
          .toDouble();

      if (!mounted || updatedInset == _nativeBottomInset) {
        return;
      }

      setState(() {
        _nativeBottomInset = updatedInset;
      });
    } on MissingPluginException {
      // MediaQuery inset will be used as fallback.
    } on PlatformException {
      // MediaQuery inset will be used as fallback.
    } finally {
      _requestInProgress = false;

      if (_refreshPending && mounted) {
        _refreshPending = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadNativeBottomInset();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool keyboardVisible =
        View.of(context).viewInsets.bottom > 0;

    final double systemBottomInset;

    if (widget.ignoreWhenKeyboardVisible && keyboardVisible) {
      systemBottomInset = 0;
    } else if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      systemBottomInset = math.max(
        mediaQuery.viewPadding.bottom,
        _nativeBottomInset,
      );
    } else {
      systemBottomInset = mediaQuery.viewPadding.bottom;
    }

    final double bottomPadding =
    widget.collapseWhenKeyboardVisible && keyboardVisible
        ? 0
        : systemBottomInset + widget.additionalBottom;

    // Always retain Padding so the TextField does not lose focus.
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: widget.child,
    );
  }
}