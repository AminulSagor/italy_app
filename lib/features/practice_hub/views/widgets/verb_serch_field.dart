import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_colors.dart';

class VerbSearchField extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const VerbSearchField({
    super.key,
    required this.textController,
    required this.hintText,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSearching = query.trim().isNotEmpty;

    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(31.r),
        border: Border.all(
          color: isSearching ? AppColors.primaryGreen : AppColors.transparent,
          width: 1.1.w,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        onChanged: onChanged,
        cursorColor: AppColors.primaryGreen,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2E3337),
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 17.w, right: 10.w),
            child: Icon(
              Icons.search_rounded,
              size: 22.r,
              color: AppColors.primaryGreen,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 50.w,
            minHeight: 58.h,
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: 44.w,
            minHeight: 58.h,
          ),
          suffixIcon: isSearching
              ? GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.close_rounded,
                    size: 23.r,
                    color: const Color(0xFF74797D),
                  ),
                )
              : null,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB4B6B8),
          ),
        ),
      ),
    );
  }
}
