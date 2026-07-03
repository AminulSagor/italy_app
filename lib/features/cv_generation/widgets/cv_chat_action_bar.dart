import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';

class CvChatActionBar extends StatelessWidget {
  const CvChatActionBar({
    required this.isSkipping,
    required this.isGenerating,
    required this.onSkip,
    required this.onGenerate,
    super.key,
  });

  final bool isSkipping;
  final bool isGenerating;
  final VoidCallback onSkip;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 7.h,
      ),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          TextButton(
            onPressed:
            isSkipping || isGenerating
                ? null
                : onSkip,
            child: isSkipping
                ? SizedBox(
              width: 18.w,
              height: 18.w,
              child:
              const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Text('Skip Question'),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed:
            isSkipping || isGenerating
                ? null
                : onGenerate,
            icon: isGenerating
                ? SizedBox(
              width: 18.w,
              height: 18.w,
              child:
              const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(
              Icons.auto_awesome_rounded,
            ),
            label: const Text('Generate CV'),
            style: TextButton.styleFrom(
              foregroundColor:
              AppColors.primaryGreen,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}