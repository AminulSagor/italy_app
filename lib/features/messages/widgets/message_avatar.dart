import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';

class MessageAvatar extends StatelessWidget {
  final String imageUrl;
  final bool showStatus;
  final bool isOnline;
  final double size;

  const MessageAvatar({
    super.key,
    required this.imageUrl,
    this.showStatus = false,
    this.isOnline = false,
    this.size = kMessageAvatarSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: size.w,
            height: size.w,
            padding: EdgeInsets.all(2.w),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: ColoredBox(
                color: AppColors.white,
                child: _canLoadImage(imageUrl)
                    ? Image.network(
                        imageUrl.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryGreen,
                      ),
              ),
            ),
          ),
          if (showStatus)
            Positioned(
              right: -1.w,
              bottom: 4.h,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.messageOnlineGreen
                      : AppColors.messageOfflineGrey,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 4.w),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _canLoadImage(String value) {
    final Uri? uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
