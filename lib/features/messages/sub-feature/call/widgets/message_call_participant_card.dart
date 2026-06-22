import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../widgets/message_avatar.dart';
import '../models/message_call_models.dart';

class MessageCallParticipantCard extends StatelessWidget {
  final MessageCallParticipantModel participant;
  final String durationLabel;
  final bool isVideoCall;

  const MessageCallParticipantCard({
    super.key,
    required this.participant,
    required this.durationLabel,
    required this.isVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isVideoCall
        ? AppColors.white
        : AppColors.homePrimaryText;

    final Color subtitleColor = isVideoCall
        ? AppColors.white.withValues(alpha: 0.72)
        : AppColors.bodyText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MessageAvatar(
          imageUrl: participant.avatarUrl,
          size: 118.w,
          showStatus: true,
          isOnline: participant.isOnline,
        ),
        SizedBox(height: 22.h),
        Text(
          participant.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppFont.font28.sp,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          durationLabel,
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}
