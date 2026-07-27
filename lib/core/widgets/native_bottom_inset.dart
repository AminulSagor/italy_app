import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeBottomInset extends StatefulWidget {
  const NativeBottomInset({
    required this.child,
    this.additionalBottom = 0,
    this.ignoreWhenKeyboardVisible = true,
    super.key,
  });

  final Widget child;
  final double additionalBottom;
  final bool ignoreWhenKeyboardVisible;

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNativeBottomInset();
    });
  }

  @override
  void didChangeMetrics() {
    _loadNativeBottomInset();
  }

  Future<void> _loadNativeBottomInset() async {
    if (kIsWeb ||
        _requestInProgress ||
        defaultTargetPlatform != TargetPlatform.android) {
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
      // Keep zero on Android when the native channel is unavailable.
    } on PlatformException {
      // Keep zero on Android when the native channel fails.
    } finally {
      _requestInProgress = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool keyboardVisible =
        mediaQuery.viewInsets.bottom > 0;

    final double systemBottomInset;

    if (widget.ignoreWhenKeyboardVisible && keyboardVisible) {
      systemBottomInset = 0;
    } else if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      // Android:
      // 0 for gesture navigation.
      // Positive value for three-button navigation.
      systemBottomInset = _nativeBottomInset;
    } else {
      // iOS and other platforms use the normal safe area.
      systemBottomInset = mediaQuery.viewPadding.bottom;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: systemBottomInset + widget.additionalBottom,
      ),
      child: widget.child,
    );
  }
}