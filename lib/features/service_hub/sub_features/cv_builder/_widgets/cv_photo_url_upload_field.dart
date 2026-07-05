import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvPhotoUrlUploadField extends StatelessWidget {
  const CvPhotoUrlUploadField({
    super.key,
    required this.textController,
    required this.isUploading,
    required this.onUploadTap,
    this.localPreviewPath,
  });

  final TextEditingController textController;
  final bool isUploading;
  final VoidCallback onUploadTap;
  final String? localPreviewPath;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: textController,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        final String photoUrl = value.text.trim();
        final String? previewPath = localPreviewPath?.trim();
        final bool hasPhoto = photoUrl.isNotEmpty ||
            (previewPath != null && previewPath.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 150.h,
              decoration: BoxDecoration(
                color: AppColors.homeBackground,
                borderRadius: BorderRadius.circular(kRadius20.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadius20.r),
                child: hasPhoto
                    ? _PreviewImage(
                        url: photoUrl,
                        localPath: previewPath,
                        isUploading: isUploading,
                      )
                    : _Placeholder(isUploading: isUploading),
              ),
            ),
            SizedBox(height: 10.h),
            Material(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              child: InkWell(
                onTap: isUploading ? null : onUploadTap,
                borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                child: Container(
                  height: 42.h,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: isUploading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.photo_camera_outlined,
                              color: AppColors.white,
                              size: AppFont.font14.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              hasPhoto ? 'change_photo'.tr : 'select_photo'.tr,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: AppFont.font11.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (hasPhoto) ...<Widget>[
              SizedBox(height: 8.h),
              Text(
                'photo_selected_it_will_upload_when_you_create_the'.tr,
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: AppFont.font9.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({
    required this.url,
    required this.localPath,
    required this.isUploading,
  });

  final String url;
  final String? localPath;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final String? safeLocalPath = localPath?.trim();
    if (safeLocalPath != null && safeLocalPath.isNotEmpty) {
      return Image.file(
        File(safeLocalPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Placeholder(isUploading: isUploading),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _Placeholder(isUploading: isUploading),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.isUploading});

  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isUploading ? Icons.cloud_upload_outlined : Icons.image_outlined,
            color: AppColors.homeSecondaryText,
            size: AppFont.font30.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            isUploading ? 'uploading_photo'.tr : 'no_photo_selected'.tr,
            style: TextStyle(
              color: AppColors.homeSecondaryText,
              fontSize: AppFont.font10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
