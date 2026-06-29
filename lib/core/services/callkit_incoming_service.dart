import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

typedef CallkitActionCallback = Future<void> Function(
    String callId,
    Map<String, dynamic> data,
    );

class CallkitIncomingService {
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<dynamic>? _callkitSubscription;

  static Future<void> initialize({
    required CallkitActionCallback onAccept,
    required CallkitActionCallback onDecline,
    required CallkitActionCallback onEnded,
  }) async {
    await _foregroundSubscription?.cancel();
    await _callkitSubscription?.cancel();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      showIncomingCallFromMessage,
    );

    _callkitSubscription =
        FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
          if (event == null) {
            return;
          }

          if (event is CallEventActionCallAccept) {
            final Map<String, dynamic> extra = _extractExtra(
              event.callKitParams.extra,
            );

            final String callId =
                extra['callId']?.toString() ??
                    event.callKitParams.id?.toString() ??
                    '';

            if (callId.isNotEmpty) {
              await onAccept(callId, extra);
            }

            return;
          }

          if (event is CallEventActionCallDecline) {
            final Map<String, dynamic> extra = _extractExtra(
              event.callKitParams.extra,
            );

            final String callId =
                extra['callId']?.toString() ??
                    event.callKitParams.id?.toString() ??
                    '';

            if (callId.isNotEmpty) {
              await onDecline(callId, extra);
            }

            return;
          }

          if (event is CallEventActionCallEnded) {
            final Map<String, dynamic> extra = _extractExtra(
              event.callKitParams.extra,
            );

            final String callId =
                extra['callId']?.toString() ??
                    event.callKitParams.id?.toString() ??
                    '';

            if (callId.isNotEmpty) {
              await onEnded(callId, extra);
            }

            return;
          }

          if (event is CallEventActionCallTimeout) {
            final String callId = event.id;

            if (callId.isNotEmpty) {
              await onEnded(
                callId,
                <String, dynamic>{
                  'callId': callId,
                  'reason': 'timeout',
                },
              );
            }
          }
        });
  }

  static Future<void> showIncomingCallFromMessage(
      RemoteMessage message,
      ) async {
    final Map<String, dynamic> data =
    Map<String, dynamic>.from(message.data);

    final String type = data['type']?.toString() ?? '';
    final String callId = data['callId']?.toString() ?? '';

    if (callId.isEmpty) {
      return;
    }

    if (type == 'call_cancelled' ||
        type == 'call_rejected' ||
        type == 'call_ended') {
      await FlutterCallkitIncoming.endCall(callId);
      return;
    }

    if (type != 'incoming_call') {
      return;
    }

    final String callerName =
        data['callerName']?.toString() ?? 'Incoming call';

    final String callType =
        data['callType']?.toString() ?? 'audio';

    final CallKitParams params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'Italir Pothe',
      avatar: data['callerAvatarUrl']?.toString() ?? '',
      handle: callerName,
      type: callType == 'video' ? 1 : 0,
      duration: 60000,
      isAccepted: false,
      extra: data,
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955FA',
        actionColor: '#4CAF50',
        textColor: '#FFFFFF',
        textAccept: 'Answer',
        textDecline: 'Decline',
        incomingCallNotificationChannelName: 'Incoming Calls',
        missedCallNotificationChannelName: 'Missed Calls',
        isShowCallID: false,
      ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: callType == 'video',
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  static Future<void> markCallConnected(String callId) async {
    await FlutterCallkitIncoming.setCallConnected(callId);
  }

  static Future<void> endCall(String callId) async {
    await FlutterCallkitIncoming.endCall(callId);
  }

  static Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }


  static Map<String, dynamic> _extractExtra(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}