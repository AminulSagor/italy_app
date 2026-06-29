import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/routes/routes.dart';
import 'custom_button.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onShopTap;
  final VoidCallback? onGuideTap;
  final VoidCallback? onRewardTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  const AppDrawer({
    super.key,
    this.onProfileTap,
    this.onShopTap,
    this.onGuideTap,
    this.onRewardTap,
    this.onSupportTap,
    this.onLanguageTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300.w,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(42.r),
            bottomRight: Radius.circular(42.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 28,
              offset: const Offset(8, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.w),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 55.h),

                      // Avatar
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80.r,
                            height: 80.r,
                            padding: EdgeInsets.all(3.r),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2DB600),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                'assets/profile_images/Fahid Hasan.png',
                              ),
                            ),
                          ),
                          Positioned(
                            right: -2.w,
                            bottom: 8.h,
                            child: Container(
                              width: 23.r,
                              height: 23.r,
                              decoration: BoxDecoration(
                                color: const Color(0xFF80ED58),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 14.r,
                                color: const Color(0xFF187400),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 11.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9BEF74),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Text(
                          'LEVEL 24',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF287C12),
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Text(
                        'Alex Rivera',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF333333),
                        ),
                      ),

                      SizedBox(height: 35.h),

                      _DrawerItem(
                        icon: Icons.person,
                        title: 'gen_profile'.tr,
                        isSelected: true,
                        onTap: onProfileTap,
                      ),

                      _DrawerItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Shop',
                        onTap: onShopTap,
                      ),

                      _DrawerItem(
                        icon: Icons.menu_book_outlined,
                        title: 'gen_guide'.tr,
                        onTap:
                            onGuideTap ??
                            () {
                              Get.back();
                              Get.toNamed(AppRoutes.guide);
                            },
                      ),

                      _DrawerItem(
                        icon: Icons.card_giftcard_outlined,
                        title: 'gen_reward'.tr,
                        onTap:
                            onRewardTap ??
                            () {
                              Get.back();
                              Get.toNamed(AppRoutes.rewards);
                            },
                      ),

                      _DrawerItem(
                        icon: Icons.help_outline,
                        title: 'gen_support'.tr,
                        onTap:
                            onSupportTap ??
                            () {
                              Get.back();
                              Get.toNamed(AppRoutes.contactSupport);
                            },
                      ),

                      _DrawerItem(
                        icon: Icons.translate,
                        title: 'gen_language'.tr,
                        onTap: onLanguageTap,
                      ),

                      _DrawerItem(
                        icon: Icons.settings_outlined,
                        title: 'gen_settings'.tr,
                        onTap:
                            onSettingsTap ??
                            () {
                              Get.back();
                              Get.toNamed(AppRoutes.settings);
                            },
                      ),

                      const Spacer(),

                      Divider(
                        color: Colors.grey.withValues(alpha: 0.28),
                        thickness: 1,
                      ),

                      SizedBox(height: 24.h),

                      CustomButton(
                        text: 'Log Out',
                        height: 56.h,
                        isLoading: false,
                        showShadow: false,
                        prefixIcon: Icons.logout,
                        btnColor: const Color(0xFFFBE8E3),
                        borderColor: const Color(0xFFFBE8E3),
                        textColor: const Color(0xFFD9300D),
                        onPressed: onLogoutTap ?? () {},
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        'VERSION 1.0.2',
                        style: TextStyle(
                          fontSize: 10.sp,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.withValues(alpha: 0.55),
                        ),
                      ),

                      SizedBox(height: 28.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF2A7D00);
    final Color inactiveColor = const Color(0xFF5D5D5D);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(100.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22.r,
                color: isSelected ? Colors.white : inactiveColor,
              ),

              SizedBox(width: 18.w),

              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
