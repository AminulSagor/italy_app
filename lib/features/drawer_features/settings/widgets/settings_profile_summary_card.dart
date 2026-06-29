import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../settings_controller.dart';

class SettingsProfileSummaryCard extends GetView<SettingsController> {
  const SettingsProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String? avatarUrl = controller.profile.value?.avatarUrl;

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
            _ProfileAvatar(
              avatarUrl: avatarUrl,
              isVerified:
                  controller.profile.value?.isEmailVerified == true ||
                  controller.profile.value?.isPhoneVerified == true,
            ),
            SizedBox(width: 25.w),
            Expanded(
              child: controller.isLoading.value && controller.profile.value == null
                  ? const _ProfileLoadingText()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          controller.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                          controller.primaryContact,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
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
    });
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl, required this.isVerified});

  final String? avatarUrl;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
          child: ClipOval(child: _AvatarImage(avatarUrl: avatarUrl)),
        ),
        if (isVerified)
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
      errorBuilder: (_, _, _) => const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF173D45),
      child: Icon(Icons.person_rounded, size: 54.r, color: Colors.white),
    );
  }
}

class _ProfileLoadingText extends StatelessWidget {
  const _ProfileLoadingText();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 150.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: 115.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ],
    );
  }
}
