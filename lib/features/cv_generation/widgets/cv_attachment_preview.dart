import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/themes/app_colors.dart';

class CvAttachmentPreview extends StatelessWidget {
  const CvAttachmentPreview({
    required this.profilePhoto,
    required this.hasUploadedProfilePhoto,
    required this.referenceImages,
    required this.referenceImageCount,
    super.key,
  });

  final XFile? profilePhoto;
  final bool hasUploadedProfilePhoto;
  final List<XFile> referenceImages;
  final int referenceImageCount;

  bool get hasAnything =>
      profilePhoto != null ||
          hasUploadedProfilePhoto ||
          referenceImageCount > 0;

  @override
  Widget build(BuildContext context) {
    if (!hasAnything) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16.w,
        8.h,
        16.w,
        10.h,
      ),
      color: Colors.white,
      child: Wrap(
        spacing: 9.w,
        runSpacing: 8.h,
        crossAxisAlignment:
        WrapCrossAlignment.center,
        children: <Widget>[
          if (hasUploadedProfilePhoto)
            _PreviewChip(
              icon: Icons.person_rounded,
              label: 'Profile photo',
              file: profilePhoto,
            ),
          if (referenceImageCount > 0)
            ...List<Widget>.generate(
              referenceImageCount,
                  (int index) {
                final XFile? file =
                index < referenceImages.length
                    ? referenceImages[index]
                    : null;

                return _PreviewChip(
                  icon: Icons.image_outlined,
                  label: 'Reference ${index + 1}',
                  file: file,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.icon,
    required this.label,
    required this.file,
  });

  final IconData icon;
  final String label;
  final XFile? file;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E4),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                File(file!.path),
                width: 28.w,
                height: 28.w,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(
              icon,
              size: 20.w,
              color: AppColors.primaryGreen,
            ),
          SizedBox(width: 7.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}