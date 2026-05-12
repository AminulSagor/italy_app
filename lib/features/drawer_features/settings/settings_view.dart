import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'widgets/settings_ui_widgets.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _green = Color(0xFF267A05);
  static const Color _text = Color(0xFF24272A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 58.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SettingsTopBar(),

              SizedBox(height: 18.h),

              const _ProfileCard(),

              SizedBox(height: 32.h),

              const _StreakFreezeCard(),

              SizedBox(height: 36.h),

              const _SectionTitle(title: 'PREFERENCES'),

              SizedBox(height: 18.h),

              _HapticsTile(onTap: controller.toggleHaptics),

              SizedBox(height: 34.h),

              const _SectionTitle(title: 'PROFILE & SECURITY'),

              SizedBox(height: 20.h),

              _ProfileSecurityCard(onTap: controller.openProfileSecurity),

              SizedBox(height: 18.h),

              _SimpleSettingsTile(
                height: 94,
                icon: Icons.lock_outline_rounded,
                iconBgColor: const Color(0xFFAED2FF),
                iconColor: const Color(0xFF0065A8),
                title: 'Change Password',
                onTap: controller.changePassword,
              ),

              SizedBox(height: 33.h),

              _RateUsButton(onTap: controller.rateUs),

              SizedBox(height: 48.h),

              const _SectionTitle(title: 'PRIVACY & LEGAL'),

              SizedBox(height: 19.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 21.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F6),
                  borderRadius: BorderRadius.circular(38.r),
                ),
                child: Column(
                  children: <Widget>[
                    _LegalTile(
                      icon: Icons.flag_outlined,
                      title: 'Reports',
                      onTap: controller.openReports,
                    ),
                    _LegalTile(
                      icon: Icons.policy_outlined,
                      title: 'Privacy Policy',
                      onTap: controller.openPrivacyPolicy,
                    ),
                    _LegalTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: controller.openTerms,
                    ),
                    _LegalTile(
                      icon: Icons.no_accounts_outlined,
                      title: 'Delete Account',
                      isDanger: true,
                      onTap: controller.deleteAccount,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 67.h),

              Center(
                child: Text(
                  'VERSION 1.0.0 (ITALIR POTHE)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.7,
                    color: const Color(0xFF44484D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTopBar extends StatelessWidget {
  const _SettingsTopBar();

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.045),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 25.r,
                  color: _green,
                ),
              ),
            ),
          ),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: _green,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 127.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(25.w, 16.h, 24.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E7EF),
        borderRadius: BorderRadius.circular(38.r),
      ),
      child: Row(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 80.r,
                height: 80.r,
                padding: EdgeInsets.all(2.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF49E900),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/profile_images/Fahid Hasan.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF173D45),
                      child: Icon(
                        Icons.person_rounded,
                        size: 54.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2.w,
                bottom: 6.h,
                child: Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF79F535),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 15.r,
                    color: const Color(0xFF267A05),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 25.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Alex Rivera',
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF24272A),
                    letterSpacing: -0.7,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Pro Scholar • Level 42',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4E5358),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakFreezeCard extends StatelessWidget {
  const _StreakFreezeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108.h,
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFB8D6FF),
        borderRadius: BorderRadius.circular(38.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAF5FF),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.ac_unit_rounded,
              size: 43.r,
              color: const Color(0xFF2F81FF),
            ),
            SizedBox(width: 21.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '2 Streak Freezes',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2549A6),
                    letterSpacing: 0.35,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'AVAILABLE',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4D80FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(Icons.tune_rounded, size: 12.r, color: const Color(0xFF267A05)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.1,
            color: const Color(0xFF4C4F54),
          ),
        ),
      ],
    );
  }
}

class _HapticsTile extends GetView<SettingsController> {
  final VoidCallback onTap;

  const _HapticsTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 0, 14.w, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F6),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE2EA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.vibration_rounded,
              size: 22.r,
              color: const Color(0xFF4D535B),
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Text(
              'Haptics',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF24272A),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Obx(() {
              final bool enabled = controller.hapticsEnabled.value;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 50.w,
                height: 28.h,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xFF79F535)
                      : const Color(0xFFDDE0E7),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  alignment: enabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      color: enabled
                          ? const Color(0xFF267A05)
                          : const Color(0xFFBFC4CC),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProfileSecurityCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileSecurityCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 158.h,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(25.w, 24.h, 21.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(38.r),
          border: Border.all(color: const Color(0xFFECECEC)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 14.r,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 30.r,
                color: const Color(0xFF6D6D6D),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF79F535),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.contact_mail_outlined,
                    size: 24.r,
                    color: const Color(0xFF267A05),
                  ),
                ),
                const Spacer(),
                Text(
                  'EMAIL/PHONE&NAME',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF5D5D5D),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '+39 320...',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF24272A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleSettingsTile extends StatelessWidget {
  final double height;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _SimpleSettingsTile({
    required this.height,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(25.w, 0, 21.w, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(38.r),
          border: Border.all(color: const Color(0xFFECECEC)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 14.r,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24.r, color: iconColor),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF24272A),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 30.r,
              color: const Color(0xFF6D6D6D),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateUsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RateUsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF267A05),
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF155200),
              blurRadius: 0,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.thumb_up_alt_rounded, size: 23.r, color: Colors.white),
            SizedBox(width: 14.w),
            Text(
              'Rate us',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;
  final VoidCallback onTap;

  const _LegalTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconBg = isDanger
        ? const Color(0xFFFFD8D2)
        : const Color(0xFFDDE2EA);
    final Color iconColor = isDanger
        ? const Color(0xFFE73508)
        : const Color(0xFF4D535B);
    final Color textColor = isDanger
        ? const Color(0xFFE73508)
        : const Color(0xFF24272A);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 76.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Row(
            children: <Widget>[
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 21.r, color: iconColor),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                isDanger
                    ? Icons.warning_amber_rounded
                    : Icons.chevron_right_rounded,
                size: isDanger ? 24.r : 30.r,
                color: isDanger
                    ? const Color(0xFFE73508)
                    : const Color(0xFF4D535B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
