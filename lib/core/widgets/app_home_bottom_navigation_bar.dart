import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../themes/app_colors.dart';
import '../themes/app_constants.dart';
import 'native_bottom_inset.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.semanticLabel,
  });

  final IconData icon;
  final String semanticLabel;
}

class AppHomeBottomNavigationBar extends StatelessWidget {
  const AppHomeBottomNavigationBar({
    required this.selectedIndex,
    required this.items,
    this.onTap,
    super.key,
  });

  final int selectedIndex;
  final List<AppBottomNavItem> items;
  final ValueChanged<int>? onTap;

  static List<AppBottomNavItem> get defaultItems =>
      <AppBottomNavItem>[
        AppBottomNavItem(
          icon: Icons.home_rounded,
          semanticLabel: 'home'.tr,
        ),
        AppBottomNavItem(
          icon: Icons.menu_book_outlined,
          semanticLabel: 'courses'.tr,
        ),
        AppBottomNavItem(
          icon: Icons.auto_awesome_rounded,
          semanticLabel: 'ai_tutor_1'.tr,
        ),
        AppBottomNavItem(
          icon: Icons.emoji_events_outlined,
          semanticLabel: 'progress'.tr,
        ),
        AppBottomNavItem(
          icon: Icons.description_outlined,
          semanticLabel: 'gen_cv'.tr,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return NativeBottomInset(
      additionalBottom: kHomeBottomNavOuterPadding,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: kHomeHorizontalPadding.w,
        ),
        child: Container(
          height: kHomeBottomNavHeight,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.homeBottomNavBg,
            borderRadius: BorderRadius.circular(
              kHomeCardRadius.r,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
                blurRadius: 22.r,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List<Widget>.generate(
              items.length,
                  (int index) {
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
                        duration: const Duration(
                          milliseconds: 180,
                        ),
                        height: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: 3.w,
                        ),
                        alignment: Alignment.center,
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
                          size: kHomeTopIconSize,
                          color: isActive
                              ? AppColors.primaryGreen
                              : AppColors.homeBottomNavInactive,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}