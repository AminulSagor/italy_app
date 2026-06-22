import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/message_call_models.dart';
import 'message_call_control_button.dart';

class MessageCallControls extends StatelessWidget {
  final MessageCallType callType;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isCameraOff;
  final bool isEnding;
  final VoidCallback onMuteTap;
  final VoidCallback onSpeakerTap;
  final VoidCallback onCameraTap;
  final VoidCallback onSwitchCameraTap;
  final VoidCallback onEndTap;

  const MessageCallControls({
    super.key,
    required this.callType,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isCameraOff,
    required this.isEnding,
    required this.onMuteTap,
    required this.onSpeakerTap,
    required this.onCameraTap,
    required this.onSwitchCameraTap,
    required this.onEndTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 34.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          MessageCallControlButton(
            icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            isActive: isMuted,
            onTap: onMuteTap,
          ),
          MessageCallControlButton(
            icon: isSpeakerOn
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            isActive: isSpeakerOn,
            onTap: onSpeakerTap,
          ),
          if (callType.isVideo) ...<Widget>[
            MessageCallControlButton(
              icon: isCameraOff
                  ? Icons.videocam_off_rounded
                  : Icons.videocam_rounded,
              isActive: isCameraOff,
              onTap: onCameraTap,
            ),
            MessageCallControlButton(
              icon: Icons.cameraswitch_rounded,
              onTap: onSwitchCameraTap,
            ),
          ],
          MessageCallControlButton(
            icon: isEnding
                ? Icons.hourglass_bottom_rounded
                : Icons.call_end_rounded,
            isDanger: true,
            onTap: onEndTap,
          ),
        ],
      ),
    );
  }
}
