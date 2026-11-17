import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../themes/app_colors.dart';

class RewardedAdProgressOverlay {
  RewardedAdProgressOverlay._(this._entry);

  final OverlayEntry _entry;
  bool _isDismissed = false;

  static RewardedAdProgressOverlay? show({
    required BuildContext? context,
    required String title,
    required String message,
  }) {
    if (context == null) return null;
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _RewardedAdProgressView(title: title, message: message),
    );
    overlay.insert(entry);
    return RewardedAdProgressOverlay._(entry);
  }

  void dismiss() {
    if (_isDismissed) return;
    _isDismissed = true;
    _entry.remove();
    _entry.dispose();
  }
}

class _RewardedAdProgressView extends StatelessWidget {
  const _RewardedAdProgressView({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const ModalBarrier(dismissible: false, color: Color(0x99000000)),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300.w,
              padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 42.r,
                    height: 42.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF27302A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.35,
                      color: const Color(0xFF68706A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
