import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../themes/app_colors.dart';
import '../themes/app_constants.dart';

class AppBottomNavItem {
  final IconData icon;
  final String semanticLabel;

  const AppBottomNavItem({required this.icon, required this.semanticLabel});
}

class AppHomeBottomNavigationBar extends StatelessWidget {
  static const List<AppBottomNavItem> defaultItems = <AppBottomNavItem>[
    AppBottomNavItem(icon: Icons.home_rounded, semanticLabel: 'Home'),
    AppBottomNavItem(icon: Icons.menu_book_outlined, semanticLabel: 'Courses'),
    AppBottomNavItem(icon: Icons.auto_awesome_rounded, semanticLabel: 'AI Tutor'),
    AppBottomNavItem(icon: Icons.emoji_events_outlined, semanticLabel: 'Progress'),
    AppBottomNavItem(icon: Icons.handyman_outlined, semanticLabel: 'Tools'),
  ];

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
          kHomeHorizontalPadding.w,
          0,
          kHomeHorizontalPadding.w,
          kHomeBottomNavOuterPadding.h,
        ),
        child: Container(
          height: kHomeBottomNavHeight.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: AppColors.homeBottomNavBg,
            borderRadius: BorderRadius.circular(kHomeCardRadius.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
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
                      kHomePillRadius.r,
                    ),
                    onTap: () => onTap?.call(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: kHomeBottomNavIconBox.h,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.homeBottomNavActiveBg
                            : AppColors.transparent,
                        borderRadius: BorderRadius.circular(
                          kHomePillRadius.r,
                        ),
                      ),
                      child: Icon(
                        items[index].icon,
                        color: isActive
                            ? AppColors.primaryGreen
                            : AppColors.homeBottomNavInactive,
                        size: kHomeTopIconSize.w,
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
