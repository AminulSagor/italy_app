import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/routes/routes.dart';

import 'app_drawer_controller.dart';
import 'custom_button.dart';

class AppDrawer extends GetView<AppDrawerController> {
  const AppDrawer({
    super.key,
    this.onShopTap,
    this.onGuideTap,
    this.onRewardTap,
    this.onSupportTap,
    this.onLanguageTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  final VoidCallback? onShopTap;
  final VoidCallback? onGuideTap;
  final VoidCallback? onRewardTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

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
          boxShadow: <BoxShadow>[
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
                    children: <Widget>[
                      SizedBox(height: 30.h),
                      Obx(
                        () => _DrawerProfileHeader(
                          name: controller.displayName,
                          league: controller.leagueLabel,
                          rank: controller.leagueRank,
                          avatarUrl: controller.avatarUrl,
                          onRefresh: controller.refreshProfile,
                        ),
                      ),
                      SizedBox(height: 35.h),
                      _DrawerItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Shop',
                        onTap: onShopTap,
                      ),
                      _DrawerItem(
                        icon: Icons.menu_book_outlined,
                        title: 'Guide',
                        onTap:
                            onGuideTap ??
                            () {
                              Get.back<void>();
                              Get.toNamed(AppRoutes.guide);
                            },
                      ),
                      _DrawerItem(
                        icon: Icons.card_giftcard_outlined,
                        title: 'Reward',
                        onTap:
                            onRewardTap ??
                            () {
                              Get.back<void>();
                              Get.toNamed(AppRoutes.rewards);
                            },
                      ),
                      _DrawerItem(
                        icon: Icons.help_outline,
                        title: 'Support',
                        onTap:
                            onSupportTap ??
                            () {
                              Get.back<void>();
                              Get.toNamed(AppRoutes.contactSupport);
                            },
                      ),
                      _DrawerItem(
                        icon: Icons.translate,
                        title: 'Language',
                        onTap: onLanguageTap,
                      ),
                      _DrawerItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap:
                            onSettingsTap ??
                            () {
                              Get.back<void>();
                              Get.toNamed(AppRoutes.settings);
                            },
                      ),
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

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader({
    required this.name,
    required this.league,
    required this.rank,
    required this.avatarUrl,
    required this.onRefresh,
  });

  final String name;
  final String league;
  final int? rank;
  final String? avatarUrl;
  final Future<void> Function({bool showError}) onRefresh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onRefresh(showError: true),
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 80.r,
                height: 80.r,
                padding: EdgeInsets.all(3.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2DB600),
                ),
                child: ClipOval(child: _DrawerAvatar(avatarUrl: avatarUrl)),
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
                    border: Border.all(color: Colors.white, width: 2),
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
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _backgroundColorForRank(rank),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              league,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: _textColorForRank(rank),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Color _backgroundColorForRank(int? currentRank) {
    switch (currentRank) {
      case 1:
        return const Color(0xFF77F53E);
      case 2:
        return const Color(0xFFE92886);
      case 3:
        return const Color(0xFFE98B00);
      default:
        return const Color(0xFFE6E7E8);
    }
  }

  Color _textColorForRank(int? currentRank) {
    switch (currentRank) {
      case 1:
        return const Color(0xFF287C12);
      case 2:
      case 3:
        return Colors.white;
      default:
        return const Color(0xFF6E7275);
    }
  }
}

class _DrawerAvatar extends StatelessWidget {
  const _DrawerAvatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final String url = avatarUrl?.trim() ?? '';
    if (url.isEmpty) return const _DrawerAvatarFallback();

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _DrawerAvatarFallback(),
    );
  }
}

class _DrawerAvatarFallback extends StatelessWidget {
  const _DrawerAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: 46.r,
        color: const Color(0xFF2A7D00),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(100.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100.r)),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22.r, color: const Color(0xFF5D5D5D)),
              SizedBox(width: 17.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5D5D5D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
