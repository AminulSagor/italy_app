import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';

class CvAttachmentSheet extends StatelessWidget {
  const CvAttachmentSheet({
    required this.onProfilePhoto,
    required this.onReferenceImages,
    super.key,
  });

  final VoidCallback onProfilePhoto;
  final VoidCallback onReferenceImages;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          14.h,
          20.w,
          24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Add CV Image',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.homePrimaryText,
              ),
            ),
            SizedBox(height: 18.h),
            _AttachmentOption(
              icon: Icons.person_outline_rounded,
              title: 'Upload Profile Photo',
              description:
              'Add the candidate photo that should appear in the CV.',
              onTap: () {
                Navigator.of(context).pop();
                onProfilePhoto();
              },
            ),
            SizedBox(height: 12.h),
            _AttachmentOption(
              icon: Icons
                  .collections_outlined,
              title:
              'Upload Reference CV or Design',
              description:
              'Add a CV, layout, color, or design image for visual reference.',
              onTap: () {
                Navigator.of(context).pop();
                onReferenceImages();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  const _AttachmentOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F7F1),
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: <Widget>[
              Container(
                width: 48.w,
                height: 48.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE1F5D8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.35,
                        color: AppColors
                            .homeSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}