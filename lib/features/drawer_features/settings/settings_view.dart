import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import 'widgets/settings_profile_summary_card.dart';
import 'widgets/settings_ui_widgets.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  static const Color _bg = Color(0xFFF7F7F7);

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
              const SettingsTopBar(title: 'Settings'),

              SizedBox(height: 18.h),

              const SettingsProfileSummaryCard(),

              SizedBox(height: 32.h),

              Obx(
                () => _StreakFreezeCard(
                  count: controller.streakFreezeCount,
                ),
              ),

              SizedBox(height: 36.h),

              const _SectionTitle(title: 'PROFILE & SECURITY'),

              SizedBox(height: 20.h),

              Obx(
                () => _ProfileSecurityCard(
                  contactLabel: controller.primaryContact,
                  onTap: controller.openProfileSecurity,
                ),
              ),

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

class _StreakFreezeCard extends StatelessWidget {
  const _StreakFreezeCard({required this.count});

  final int count;

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
                  '$count Streak ${count == 1 ? 'Freeze' : 'Freezes'}',
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

class _ProfileSecurityCard extends StatelessWidget {
  const _ProfileSecurityCard({
    required this.contactLabel,
    required this.onTap,
  });

  final String contactLabel;
  final VoidCallback onTap;

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
                  contactLabel,
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
