import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/features/drawer_features/settings/settings_controller.dart';
import 'package:italir_pothe/features/drawer_features/settings/widgets/settings_ui_widgets.dart';
import 'package:italir_pothe/routes/routes.dart';

class ProfileSecurityView extends GetView<SettingsController> {
  const ProfileSecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 58.h),
          child: Column(
            children: <Widget>[
              const SettingsTopBar(title: 'Edit Profile'),
              SizedBox(height: 49.h),
              _ProfileAvatar(onTap: () => Get.toNamed(AppRoutes.profilePhoto)),
              SizedBox(height: 19.h),
              Text(
                'LEVEL 12 LINGUIST',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF5B5B5B),
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 27.h),
              const _ProfileTextField(
                label: 'Full Name',
                value: 'Alessandro Rossi',
                icon: Icons.person_outline_rounded,
              ),
              SizedBox(height: 24.h),
              Obx(() {
                final bool isEmail = controller.editProfileTab.value == 'email';

                return _SegmentedSwitch(
                  isEmail: isEmail,
                  onEmailTap: () => controller.setEditProfileTab('email'),
                  onPhoneTap: () => controller.setEditProfileTab('phone'),
                );
              }),
              SizedBox(height: 13.h),
              Obx(() {
                final bool isEmail = controller.editProfileTab.value == 'email';

                return _ProfileTextField(
                  label: isEmail ? 'Email' : 'Phone',
                  value: isEmail
                      ? 'alessandro.r@shikhi.it'
                      : '+88 013 5462 489',
                  icon: isEmail
                      ? Icons.alternate_email_rounded
                      : Icons.phone_rounded,
                );
              }),
              SizedBox(height: 24.h),
              Obx(() {
                final bool isEmail = controller.editProfileTab.value == 'email';

                return _VerifiedCard(
                  title: isEmail ? 'Email Verified' : 'Phone Verified',
                  subtitle: 'Your account is secure',
                );
              }),
              SizedBox(height: 36.h),
              SettingsPrimaryButton(
                text: 'SAVE CHANGES',
                icon: Icons.save_rounded,
                onTap: () {
                  final String mode = controller.editProfileTab.value;
                  Get.toNamed(
                    AppRoutes.verifyContact,
                    arguments: {'mode': mode},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileAvatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128.r,
      height: 128.r,
      child: Stack(
        children: <Widget>[
          Container(
            width: 128.r,
            height: 128.r,
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SettingsUi.lightGreen, width: 4.w),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/profile_images/Fahid Hasan.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1B242D),
                  child: Icon(
                    Icons.person_rounded,
                    size: 72.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 9.h,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: SettingsUi.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.w),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 22.r,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileTextField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 24.w, bottom: 10.h),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: const Color(0xFF666666),
            ),
          ),
        ),
        Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22.r, color: SettingsUi.green),
              SizedBox(width: 18.w),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: SettingsUi.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SegmentedSwitch extends StatelessWidget {
  final bool isEmail;
  final VoidCallback onEmailTap;
  final VoidCallback onPhoneTap;

  const _SegmentedSwitch({
    required this.isEmail,
    required this.onEmailTap,
    required this.onPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: const Color(0xFFD9DADA),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SegmentItem(
              text: 'Email',
              selected: isEmail,
              onTap: onEmailTap,
            ),
          ),
          Expanded(
            child: _SegmentItem(
              text: 'Phone',
              selected: !isEmail,
              onTap: onPhoneTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4C4C4C),
          ),
        ),
      ),
    );
  }
}

class _VerifiedCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _VerifiedCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFF),
        borderRadius: BorderRadius.circular(38.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: Color(0xFFA9D0FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_outlined,
              size: 25.r,
              color: const Color(0xFF0064A8),
            ),
          ),
          SizedBox(width: 18.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF005A97),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF005A97),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
