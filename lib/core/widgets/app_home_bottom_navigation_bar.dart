import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_theme.dart';

class AppBottomNavItem {
  final IconData icon;
  final String semanticLabel;

  const AppBottomNavItem({required this.icon, required this.semanticLabel});
}

class AppHomeBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final List<AppBottomNavItem> items;
  final ValueChanged<int>? onTap;

  const AppHomeBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppTheme.homeHorizontalPadding.w,
          0,
          AppTheme.homeHorizontalPadding.w,
          AppTheme.homeBottomNavOuterPadding.h,
        ),
        child: Container(
          height: AppTheme.homeBottomNavHeight.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: AppTheme.homeBottomNavBg,
            borderRadius: BorderRadius.circular(AppTheme.homeCardRadius.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppTheme.homeNeutralShadow,
                blurRadius: 22.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(items.length, (int index) {
              final bool isActive = selectedIndex == index;
              return Expanded(
                child: Semantics(
                  label: items[index].semanticLabel,
                  button: true,
                  selected: isActive,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      AppTheme.homePillRadius.r,
                    ),
                    onTap: () => onTap?.call(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: AppTheme.homeBottomNavIconBox.h,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.homeBottomNavActiveBg
                            : AppTheme.transparent,
                        borderRadius: BorderRadius.circular(
                          AppTheme.homePillRadius.r,
                        ),
                      ),
                      child: Icon(
                        items[index].icon,
                        color: isActive
                            ? AppTheme.primaryGreen
                            : AppTheme.homeBottomNavInactive,
                        size: AppTheme.homeTopIconSize.w,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
