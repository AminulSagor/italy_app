import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../settings_controller.dart';
import 'settings_ui_widgets.dart';

class SettingsProfileSummaryCard extends GetView<SettingsController> {
  const SettingsProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String? avatarUrl = controller.profile.value?.avatarUrl;
      final bool verified =
          controller.profile.value?.isEmailVerified == true ||
              controller.profile.value?.isPhoneVerified == true;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: SettingsUi.border),
        ),
        child: Row(
          children: <Widget>[
            _ProfileAvatar(
              avatarUrl: avatarUrl,
              isVerified: verified,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: controller.isLoading.value && controller.profile.value == null
                  ? const _ProfileLoadingText()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          controller.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            color: SettingsUi.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          controller.primaryContact,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: SettingsUi.muted,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Wrap(
                          spacing: 7.w,
                          runSpacing: 6.h,
                          children: <Widget>[
                            _MiniBadge(
                              icon: Icons.school_outlined,
                              text: controller.profile.value?.learnerLevel ?? 'A1',
                            ),
                            _MiniBadge(
                              icon: Icons.local_fire_department_outlined,
                              text:
                                  '${controller.profile.value?.currentStreakDays ?? 0}',
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.avatarUrl,
    required this.isVerified,
  });

  final String? avatarUrl;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: 68.r,
          height: 68.r,
          padding: EdgeInsets.all(2.r),
          decoration: const BoxDecoration(
            color: Color(0xFFD7F2E8),
            shape: BoxShape.circle,
          ),
          child: ClipOval(child: _AvatarImage(avatarUrl: avatarUrl)),
        ),
        if (isVerified)
          Positioned(
            right: -1.w,
            bottom: 2.h,
            child: Container(
              width: 21.r,
              height: 21.r,
              decoration: BoxDecoration(
                color: SettingsUi.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 13.r,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final String url = avatarUrl?.trim() ?? '';
    if (url.isEmpty) return const _AvatarFallback();

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SettingsUi.primaryDark,
      child: Icon(Icons.person_rounded, size: 42.r, color: Colors.white),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6F3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13.r, color: SettingsUi.primary),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: SettingsUi.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingText extends StatelessWidget {
  const _ProfileLoadingText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 138.w,
          height: 17.h,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEEB),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: 105.w,
          height: 11.h,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2F0),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ],
    );
  }
}
