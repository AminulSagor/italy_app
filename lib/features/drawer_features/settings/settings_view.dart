import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'models/settings_localization.dart';
import 'settings_controller.dart';
import 'widgets/settings_profile_summary_card.dart';
import 'widgets/settings_ui_widgets.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.background,
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            onRefresh: () => controller.loadProfile(showError: false),
            color: SettingsUi.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 30.h),
              children: <Widget>[
                SettingsTopBar(title: SettingsL10n.text('settings')),
                SizedBox(height: 16.h),
                if (controller.hasProfileLoadError.value &&
                    controller.profile.value == null)
                  _ProfileLoadErrorCard(onRetry: controller.loadProfile)
                else ...<Widget>[
                  const SettingsProfileSummaryCard(),
                  SizedBox(height: 14.h),
                  _StreakFreezeCard(count: controller.streakFreezeCount),
                  SizedBox(height: 24.h),
                  _SectionTitle(
                    title: SettingsL10n.text('profile_and_security'),
                  ),
                  SizedBox(height: 10.h),
                  _SettingsActionTile(
                    icon: Icons.manage_accounts_outlined,
                    title: SettingsL10n.text('edit_profile'),
                    subtitle: SettingsL10n.text('name_email_phone'),
                    onTap: controller.profile.value == null
                        ? null
                        : controller.openProfileSecurity,
                  ),
                  SizedBox(height: 10.h),
                  _SettingsActionTile(
                    icon: Icons.lock_outline_rounded,
                    title: controller.passwordActionLabel,
                    onTap: controller.changePassword,
                  ),
                  SizedBox(height: 24.h),
                  _SectionTitle(title: SettingsL10n.text('privacy_and_legal')),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(color: SettingsUi.border),
                    ),
                    child: Column(
                      children: <Widget>[
                        _LegalTile(
                          icon: Icons.policy_outlined,
                          title: SettingsL10n.text('privacy_policy'),
                          onTap: controller.openPrivacyPolicy,
                        ),
                        const Divider(height: 1, indent: 62),
                        _LegalTile(
                          icon: Icons.description_outlined,
                          title: SettingsL10n.text('terms_of_service'),
                          onTap: controller.openTerms,
                        ),
                        const Divider(height: 1, indent: 62),
                        _LegalTile(
                          icon: Icons.star_outline_rounded,
                          title: SettingsL10n.text('rate_app'),
                          onTap: controller.rateUs,
                        ),
                        const Divider(height: 1, indent: 62),
                        _LegalTile(
                          icon: Icons.delete_outline_rounded,
                          title: SettingsL10n.text('delete_account'),
                          isDanger: true,
                          onTap: controller.profile.value == null
                              ? null
                              : controller.deleteAccount,
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 26.h),
                Center(
                  child: Text(
                    controller.appVersionLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: SettingsUi.muted,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ProfileLoadErrorCard extends StatelessWidget {
  const _ProfileLoadErrorCard({required this.onRetry});

  final Future<void> Function({bool showError}) onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: SettingsUi.border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 58.r,
            height: 58.r,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0EC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_outlined,
              size: 29.r,
              color: SettingsUi.danger,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            SettingsL10n.text('profile_load_failed'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: SettingsUi.text,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            SettingsL10n.text('profile_load_failed_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5.sp,
              height: 1.45,
              color: SettingsUi.muted,
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: 150.w,
            child: SettingsPrimaryButton(
              text: SettingsL10n.text('retry'),
              icon: Icons.refresh_rounded,
              onTap: () => onRetry(showError: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakFreezeCard extends StatelessWidget {
  const _StreakFreezeCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final String key = count == 1 ? 'streak_freeze' : 'streak_freezes';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD5E7FF)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46.r,
            height: 46.r,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.ac_unit_rounded,
              size: 24.r,
              color: const Color(0xFF2F81FF),
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  SettingsL10n.text(
                    key,
                    params: <String, String>{'count': '$count'},
                  ),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF254E9D),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  SettingsL10n.text('available'),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF5079C3),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
        color: SettingsUi.muted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: SettingsUi.border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F2),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, size: 23.r, color: SettingsUi.primary),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: SettingsUi.text,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      SizedBox(height: 3.h),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: SettingsUi.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24.r,
                color: SettingsUi.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final Color color = isDanger ? SettingsUi.danger : SettingsUi.text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22.r, color: color),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 23.r,
              color: isDanger ? SettingsUi.danger : SettingsUi.muted,
            ),
          ],
        ),
      ),
    );
  }
}
