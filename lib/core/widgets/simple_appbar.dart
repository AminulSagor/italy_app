import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SimpleAppbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackTap;
  final String? title;
  final IconData? icon;
  const SimpleAppbar({
    required this.onBackTap,
    this.title,
    this.icon,
    super.key,
  });

  @override
  Size get preferredSize => Size.fromHeight(76.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        color: const Color(0xFFF8F8F8),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBackTap,
              child: Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon ?? Icons.arrow_back_ios,
                  size: 24.r,
                  color: const Color(0xFF267A05),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Text(
                  title ?? '',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF236B05),
                  ),
                ),
              ),
            ),

            SizedBox(width: 48.r),
          ],
        ),
      ),
    );
  }
}
