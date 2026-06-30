import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:get/get.dart';

import '../../../../../core/services/callkit_incoming_service.dart';
import '../../../../../core/services/callkit_pending_action_store.dart';
import '../controllers/message_incoming_call_controller.dart';
import '../views/message_incoming_call_view.dart';
import 'call_socket_service.dart';

typedef AcceptedCallHandler = Future<void> Function({
  required String callId,
  required Map<String, dynamic> callData,
  required Map<String, dynamic> answerResponse,
});

class IncomingCallCoordinator extends GetxService with WidgetsBindingObserver {
  IncomingCallCoordinator({
    required CallSocketService callSocketService,
    required AcceptedCallHandler acceptedCallHandler,
  }) : _callSocketService = callSocketService,
       _acceptedCallHandler = acceptedCallHandler;

  final CallSocketService _callSocketService;
  final AcceptedCallHandler _acceptedCallHandler;

  final RxBool isCallTransitioning = false.obs;

  String? _activeIncomingCallId;
  bool _isOpeningAcceptedCall = false;
  bool _restoreInProgress = false;

  late final void Function(Map<String, dynamic>) _incomingCallListener;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _incomingCallListener = _handleIncomingCall;
    _callSocketService.addIncomingCallListener(_incomingCallListener);
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_connectCallSocket());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    // A CallKit action can be handled while Android is bringing the existing
    // activity back to foreground. Re-check pending/native accepted calls as
    // soon as the navigator is usable.
    unawaited(restorePendingAcceptedCall());
  }

  Future<void> _connectCallSocket() async {
    try {
      await _callSocketService.connect();
      debugPrint('[IncomingCallCoordinator] Call socket connected');
    } on CallSocketException catch (error) {
      debugPrint(
        '[IncomingCallCoordinator] Connection failed: '
        '${error.code} ${error.message}',
      );
    } catch (error) {
      debugPrint('[IncomingCallCoordinator] Connection failed: $error');
    }
  }

  void _handleIncomingCall(Map<String, dynamic> payload) {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      debugPrint(
        '[IncomingCallCoordinator] App is not in foreground. '
        'FCM/CallKit will handle the incoming call.',
      );
      return;
    }

    unawaited(_openIncomingCall(payload));
  }

  Future<void> _openIncomingCall(Map<String, dynamic> payload) async {
    final Map<String, dynamic> call = _toMap(payload['call']);
    final String callId = call['id']?.toString().trim() ?? '';

    if (callId.isEmpty ||
        _activeIncomingCallId == callId ||
        _activeIncomingCallId != null ||
        _isOpeningAcceptedCall) {
      return;
    }

    _activeIncomingCallId = callId;

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      _activeIncomingCallId = null;
      return;
    }

    try {
      // ACK immediately so the server does not send a duplicate FCM fallback.
      try {
        await _callSocketService.acknowledgeIncomingCall(callId: callId);
      } catch (error) {
        debugPrint('[IncomingCallCoordinator] Incoming ACK failed: $error');
      }

      // Use the native incoming-call notification for the actual device
      // ringtone even while the Flutter application is in foreground.
      try {
        await CallkitIncomingService.showIncomingCallFromSocketPayload(payload);
      } catch (error) {
        debugPrint('[IncomingCallCoordinator] Native ringtone failed: $error');
      }

      if (Get.isRegistered<MessageIncomingCallController>()) {
        await Get.delete<MessageIncomingCallController>(force: true);
      }

      final MessageIncomingCallController controller =
          MessageIncomingCallController(
            payload: payload,
            callSocketService: _callSocketService,
          );
      Get.put<MessageIncomingCallController>(controller);

      await Get.to<void>(
        () => MessageIncomingCallView(controller: controller),
        transition: Transition.downToUp,
        fullscreenDialog: true,
      );
    } finally {
      await CallkitIncomingService.endNativeSubsystemOnly(callId);

      if (Get.isRegistered<MessageIncomingCallController>()) {
        await Get.delete<MessageIncomingCallController>(force: true);
      }

      _activeIncomingCallId = null;
    }
  }

  void dismissIncomingCall(String callId) {
    if (_activeIncomingCallId != callId.trim() ||
        !Get.isRegistered<MessageIncomingCallController>()) {
      return;
    }

    Get.find<MessageIncomingCallController>().closeFromNativeAction();
  }

  Future<void> openAcceptedCall({
    required String callId,
    required Map<String, dynamic> callData,
    required Map<String, dynamic> answerResponse,
  }) async {
    final String normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty || _isOpeningAcceptedCall) {
      return;
    }

    _isOpeningAcceptedCall = true;
    isCallTransitioning.value = true;
    _activeIncomingCallId = normalizedCallId;

    try {
      await _waitForForeground();

      if (Get.isRegistered<MessageIncomingCallController>()) {
        if (Get.key.currentState?.canPop() == true) {
          Get.back<void>();
          await Future<void>.delayed(const Duration(milliseconds: 80));
        }
        await Get.delete<MessageIncomingCallController>(force: true);
      }

      await CallkitPendingActionStore.clear();
      await CallkitIncomingService.endNativeSubsystemOnly(normalizedCallId);

      await _acceptedCallHandler(
        callId: normalizedCallId,
        callData: callData,
        answerResponse: answerResponse,
      );
    } finally {
      // A background isolate may finish persisting the same accept action
      // after the foreground isolate has already opened the call. Clear it
      // again when the call route closes so it cannot be restored twice.
      await CallkitPendingActionStore.clear();
      _activeIncomingCallId = null;
      _isOpeningAcceptedCall = false;
      isCallTransitioning.value = false;
    }
  }

  Future<bool> restorePendingAcceptedCall({
    Duration waitForBackgroundHandler = Duration.zero,
  }) async {
    if (_restoreInProgress || _isOpeningAcceptedCall) {
      return false;
    }

    _restoreInProgress = true;
    final DateTime deadline = DateTime.now().add(waitForBackgroundHandler);

    try {
      do {
        final PendingAcceptedCall? pending =
            await CallkitPendingActionStore.takeAcceptedCall();

        if (pending != null) {
          await _openRestoredAcceptedCall(
            callId: pending.callId,
            callData: pending.callData,
            answerResponse: pending.answerResponse,
          );
          return true;
        }

        List<CallKitParams> acceptedNativeCalls = <CallKitParams>[];
        try {
          acceptedNativeCalls = await CallkitIncomingService.acceptedNativeCalls();
        } catch (error) {
          debugPrint(
            '[IncomingCallCoordinator] Unable to inspect native calls: $error',
          );
        }

        if (acceptedNativeCalls.isNotEmpty) {
          final CallKitParams nativeCall = acceptedNativeCalls.first;
          final String nativeCallId = nativeCall.id.trim();

          if (nativeCallId.isNotEmpty) {
            try {
              final Map<String, dynamic> answerResponse =
                  await _callSocketService.answerCallOverHttp(
                    callId: nativeCallId,
                  );
              await _openRestoredAcceptedCall(
                callId: nativeCallId,
                callData: _toMap(nativeCall.extra),
                answerResponse: answerResponse,
              );
              return true;
            } catch (error, stackTrace) {
              debugPrint(
                '[IncomingCallCoordinator] Native accepted-call recovery '
                'failed: $error',
              );
              debugPrintStack(stackTrace: stackTrace);
              await CallkitIncomingService.endNativeSubsystemOnly(nativeCallId);
              return false;
            }
          }
        }

        if (!DateTime.now().isBefore(deadline)) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      } while (true);

      return false;
    } finally {
      _restoreInProgress = false;
    }
  }

  Future<void> _openRestoredAcceptedCall({
    required String callId,
    required Map<String, dynamic> callData,
    required Map<String, dynamic> answerResponse,
  }) async {
    try {
      await CallkitIncomingService.markCallConnected(callId);
      await openAcceptedCall(
        callId: callId,
        callData: callData,
        answerResponse: answerResponse,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[IncomingCallCoordinator] Unable to restore accepted call: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
      rethrow;
    }
  }

  Future<void> _waitForForeground() async {
    for (int attempt = 0; attempt < 20; attempt++) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          Get.key.currentState != null) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> reconnectAfterLogin() async {
    await _callSocketService.refreshConnectionAfterLogin();
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _callSocketService.removeIncomingCallListener(_incomingCallListener);
    super.onClose();
  }
}
