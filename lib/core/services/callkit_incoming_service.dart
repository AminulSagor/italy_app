import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';

import 'callkit_pending_action_store.dart';

typedef CallkitActionCallback =
    Future<void> Function(String callId, Map<String, dynamic> data);

class CallkitIncomingService {
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<dynamic>? _callkitSubscription;
  static final Set<String> _remoteTerminationCallIds = <String>{};
  static final Set<String> _shownCallIds = <String>{};
  static final Set<String> _processedDeclineCallIds = <String>{};
  static bool _iosAudioSessionActive = false;
  static Completer<void>? _iosAudioSessionActivation;

  static Future<void> initialize({
    required CallkitActionCallback onIncoming,
    required CallkitActionCallback onAccept,
    required CallkitActionCallback onDecline,
    required CallkitActionCallback onEnded,
    required CallkitActionCallback onTimeout,
  }) async {
    await _foregroundSubscription?.cancel();
    await _callkitSubscription?.cancel();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      showIncomingCallFromForegroundMessage,
    );

    _callkitSubscription = FlutterCallkitIncoming.onEvent.listen((
      CallEvent? event,
    ) async {
      if (event == null) {
        return;
      }

      if (event is CallEventActionCallToggleAudioSession) {
        _iosAudioSessionActive = event.isActive;
        if (event.isActive) {
          final Completer<void>? activation = _iosAudioSessionActivation;
          if (activation != null && !activation.isCompleted) {
            activation.complete();
          }
        }
        return;
      }

      if (event is CallEventActionCallIncoming) {
        final Map<String, dynamic> extra = _extractExtra(
          event.callKitParams.extra,
        );
        final String callId = _eventCallId(
          extra: extra,
          fallbackId: event.callKitParams.id,
        );

        if (callId.isNotEmpty) {
          _processedDeclineCallIds.remove(callId);
          await onIncoming(callId, extra);
        }
        return;
      }

      if (event is CallEventActionCallAccept) {
        _iosAudioSessionActive = false;
        final Map<String, dynamic> extra = _extractExtra(
          event.callKitParams.extra,
        );
        final String callId = _eventCallId(
          extra: extra,
          fallbackId: event.callKitParams.id,
        );

        if (callId.isNotEmpty) {
          _shownCallIds.remove(callId);
          await onAccept(callId, extra);
        }
        return;
      }

      if (event is CallEventActionCallDecline) {
        final Map<String, dynamic> extra = _extractExtra(
          event.callKitParams.extra,
        );
        final String callId = _eventCallId(
          extra: extra,
          fallbackId: event.callKitParams.id,
        );

        if (callId.isNotEmpty) {
          _shownCallIds.remove(callId);
          if (!_processedDeclineCallIds.add(callId)) {
            return;
          }
          Timer(
            const Duration(minutes: 2),
            () => _processedDeclineCallIds.remove(callId),
          );
          await onDecline(callId, extra);
        }
        return;
      }

      if (event is CallEventActionCallEnded) {
        final Map<String, dynamic> extra = _extractExtra(
          event.callKitParams.extra,
        );
        final String callId = _eventCallId(
          extra: extra,
          fallbackId: event.callKitParams.id,
        );

        if (callId.isNotEmpty) {
          _shownCallIds.remove(callId);
          await onEnded(callId, extra);
        }
        return;
      }

      if (event is CallEventActionCallTimeout) {
        final String callId = event.id.trim();
        if (callId.isNotEmpty) {
          _shownCallIds.remove(callId);
          await onTimeout(callId, <String, dynamic>{
            'callId': callId,
            'reason': 'timeout',
          });
        }
      }
    });
  }

  static Future<void> showIncomingCallFromForegroundMessage(
    RemoteMessage message,
  ) async {
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    await _handleIncomingData(data, showFullScreen: false);
  }

  static Future<void> showIncomingCallFromBackgroundMessage(
    RemoteMessage message,
  ) async {
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);

    // Background and terminated-state calls must be posted as a call
    // notification with a full-screen intent. Android then keeps the
    // notification visible and opens the native incoming-call activity when
    // full-screen intent access is allowed for the app.
    await _handleIncomingData(data, showFullScreen: true);
  }

  static Future<void> showIncomingCallFromSocketPayload(
    Map<String, dynamic> payload,
  ) async {
    final Map<String, dynamic> call = _extractExtra(payload['call']);
    final Map<String, dynamic> caller = _extractExtra(payload['caller']);

    final Map<String, dynamic> data = <String, dynamic>{
      'type': 'incoming_call',
      'callId': call['id']?.toString() ?? '',
      'conversationId': call['directConversationId']?.toString() ?? '',
      'callType': call['callType']?.toString() ?? 'audio',
      'callerId':
          caller['id']?.toString() ?? call['callerId']?.toString() ?? '',
      'callerName': caller['fullName']?.toString() ?? 'incoming_call'.tr,
      'callerAvatarUrl': caller['avatarUrl']?.toString() ?? '',
    };

    // The Flutter incoming-call page is already visible in foreground. The
    // native notification is used here for the real device ringtone only.
    await _handleIncomingData(data, showFullScreen: false);
  }

  static Future<void> _handleIncomingData(
    Map<String, dynamic> data, {
    required bool showFullScreen,
  }) async {
    final String type = data['type']?.toString() ?? '';
    final String callId = data['callId']?.toString().trim() ?? '';

    if (callId.isEmpty) {
      return;
    }

    if (type == 'call_cancelled' ||
        type == 'call_rejected' ||
        type == 'call_ended') {
      _shownCallIds.remove(callId);
      // A cancellation can race a lock-screen answer. Never restore an old
      // accepted/declined action after CallKit has been told the call ended.
      await CallkitPendingActionStore.clear();
      _remoteTerminationCallIds.add(callId);
      Timer(
        const Duration(seconds: 30),
        () => _remoteTerminationCallIds.remove(callId),
      );
      await endNativeSubsystemOnly(callId);
      return;
    }

    if (type != 'incoming_call' || !_shownCallIds.add(callId)) {
      return;
    }

    final String callerName =
        data['callerName']?.toString().trim().isNotEmpty == true
        ? data['callerName'].toString().trim()
        : 'incoming_call';
    final String callType = data['callType']?.toString() ?? 'audio';

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

      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),

      callingNotification: const NotificationParams(showNotification: false),

      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955FA',
        actionColor: '#4CAF50',
        textColor: '#FFFFFF',
        textAccept: 'Answer',
        textDecline: 'Decline',
        incomingCallNotificationChannelName: 'incoming_call'.tr,
        missedCallNotificationChannelName: 'missed_call'.tr,
        isShowCallID: false,
        isShowFullLockedScreen: true,
        isImportant: true,
        isFullScreen: showFullScreen,
      ),

      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: callType == 'video',
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: callType == 'video' ? 'videoChat' : 'voiceChat',
        audioSessionActive: true,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    try {
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    } catch (_) {
      _shownCallIds.remove(callId);
      rethrow;
    }
  }

  static bool consumeRemoteTermination(String callId) {
    return _remoteTerminationCallIds.remove(callId.trim());
  }

  static Future<List<CallKitParams>> activeNativeCalls() async {
    return FlutterCallkitIncoming.activeCalls();
  }

  static Future<List<CallKitParams>> acceptedNativeCalls() async {
    final List<CallKitParams> calls =
        await FlutterCallkitIncoming.activeCalls();
    return calls
        .where((CallKitParams call) => call.isAccepted)
        .toList(growable: false);
  }

  static Future<void> markCallConnected(String callId) async {
    await FlutterCallkitIncoming.setCallConnected(callId);
  }

  static Future<void> endNativeSubsystemOnly(String callId) async {
    final String normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) {
      return;
    }

    _shownCallIds.remove(normalizedCallId);
    await FlutterCallkitIncoming.endNativeSubsystemOnly(normalizedCallId);
  }

  static Future<bool> completeNativeAnswer(String callId) async {
    final String normalizedCallId = callId.trim();
    if (!Platform.isIOS || normalizedCallId.isEmpty) {
      return false;
    }

    return FlutterCallkitIncoming.completeAnswer(normalizedCallId);
  }

  static Future<bool> resumeIosCallAudio() async {
    if (!Platform.isIOS) {
      return true;
    }

    if (!await FlutterCallkitIncoming.isAudioSessionActive()) {
      return false;
    }

    _iosAudioSessionActive = true;
    return FlutterCallkitIncoming.resumeCallAudio();
  }

  /// Waits for CallKit's provider to activate AVAudioSession before the RTC
  /// engine starts capture. The timeout keeps foreground and restoration paths
  /// usable if iOS has already activated the session before Dart attached.
  static Future<bool> waitForIosAudioSessionActivation({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    if (!Platform.isIOS) {
      return true;
    }

    if (_iosAudioSessionActive ||
        await FlutterCallkitIncoming.isAudioSessionActive()) {
      _iosAudioSessionActive = true;
      return true;
    }

    final Completer<void> activation = Completer<void>();
    _iosAudioSessionActivation = activation;

    // Close the small race between the native query and installing the waiter.
    if (await FlutterCallkitIncoming.isAudioSessionActive()) {
      _iosAudioSessionActive = true;
      activation.complete();
    }

    try {
      await activation.future.timeout(timeout);
      return true;
    } on TimeoutException {
      return false;
    } finally {
      if (identical(_iosAudioSessionActivation, activation)) {
        _iosAudioSessionActivation = null;
      }
    }
  }

  static Future<void> failNativeAnswer(String callId) async {
    final String normalizedCallId = callId.trim();
    if (!Platform.isIOS || normalizedCallId.isEmpty) {
      return;
    }

    await FlutterCallkitIncoming.failAnswer(normalizedCallId);
  }

  static Future<void> endCall(String callId) async {
    _shownCallIds.remove(callId.trim());
    await FlutterCallkitIncoming.endCall(callId);
  }

  static Future<void> endAllCalls() async {
    _shownCallIds.clear();
    await FlutterCallkitIncoming.endAllCalls();
  }

  static String _eventCallId({
    required Map<String, dynamic> extra,
    required String fallbackId,
  }) {
    final String extraCallId = extra['callId']?.toString().trim() ?? '';
    return extraCallId.isNotEmpty ? extraCallId : fallbackId.trim();
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
