import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controllers/message_incoming_call_controller.dart';
import '../views/message_incoming_call_view.dart';
import 'call_socket_service.dart';

typedef AcceptedCallHandler = Future<void> Function({
required String callId,
required Map<String, dynamic> callData,
required Map<String, dynamic> answerResponse,
});

class IncomingCallCoordinator extends GetxService
    with WidgetsBindingObserver {
  IncomingCallCoordinator({
    required CallSocketService callSocketService,
    required AcceptedCallHandler acceptedCallHandler,
  })  : _callSocketService = callSocketService,
        _acceptedCallHandler = acceptedCallHandler;

  final CallSocketService _callSocketService;
  final AcceptedCallHandler _acceptedCallHandler;

  String? _activeIncomingCallId;
  bool _isOpeningAcceptedCall = false;

  late final void Function(Map<String, dynamic>) _incomingCallListener;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    _incomingCallListener = _handleIncomingCall;

    _callSocketService.addIncomingCallListener(
      _incomingCallListener,
    );
  }

  @override
  void onReady() {
    super.onReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_connectCallSocket());
    });
  }

  Future<void> _connectCallSocket() async {
    try {
      await _callSocketService.connect();

      debugPrint(
        '[IncomingCallCoordinator] Call socket connected',
      );
    } on CallSocketException catch (error) {
      debugPrint(
        '[IncomingCallCoordinator] Connection failed: '
            '${error.code} ${error.message}',
      );
    } catch (error) {
      debugPrint(
        '[IncomingCallCoordinator] Connection failed: $error',
      );
    }
  }

  void _handleIncomingCall(Map<String, dynamic> payload) {
    final AppLifecycleState? lifecycleState =
        WidgetsBinding.instance.lifecycleState;

    if (lifecycleState != AppLifecycleState.resumed) {
      debugPrint(
        '[IncomingCallCoordinator] App is not in foreground. '
            'Socket incoming call ignored so FCM fallback can run.',
      );
      return;
    }

    unawaited(_openIncomingCall(payload));
  }

  Future<void> _openIncomingCall(
      Map<String, dynamic> payload,
      ) async {
    final Map<String, dynamic> call = _toMap(payload['call']);

    final String callId = call['id']?.toString() ?? '';

    if (callId.isEmpty) {
      debugPrint(
        '[IncomingCallCoordinator] Incoming call ID is missing',
      );
      return;
    }

    if (_activeIncomingCallId == callId) {
      return;
    }

    if (_activeIncomingCallId != null || _isOpeningAcceptedCall) {
      debugPrint(
        '[IncomingCallCoordinator] Another call screen is already open',
      );
      return;
    }

    _activeIncomingCallId = callId;

    final AppLifecycleState? lifecycleState =
        WidgetsBinding.instance.lifecycleState;

    if (lifecycleState != AppLifecycleState.resumed) {
      debugPrint(
        '[IncomingCallCoordinator] App moved to background. '
            'Incoming call screen and ACK skipped.',
      );

      _activeIncomingCallId = null;
      return;
    }

    if (Get.isRegistered<MessageIncomingCallController>()) {
      await Get.delete<MessageIncomingCallController>(
        force: true,
      );
    }

    Get.put<MessageIncomingCallController>(
      MessageIncomingCallController(
        payload: payload,
        callSocketService: _callSocketService,
      ),
    );

    try {
      final routeFuture = Get.to<void>(
            () => const MessageIncomingCallView(),
        transition: Transition.downToUp,
        fullscreenDialog: true,
      );

      await _callSocketService.acknowledgeIncomingCall(
        callId: callId,
      );

      await routeFuture;
    } finally {
      if (Get.isRegistered<MessageIncomingCallController>()) {
        await Get.delete<MessageIncomingCallController>(
          force: true,
        );
      }

      _activeIncomingCallId = null;
    }
  }

  Future<void> openAcceptedCall({
    required String callId,
    required Map<String, dynamic> callData,
    required Map<String, dynamic> answerResponse,
  }) async {
    if (_isOpeningAcceptedCall) {
      return;
    }

    _isOpeningAcceptedCall = true;
    _activeIncomingCallId = callId;

    try {
      if (Get.currentRoute == '/MessageIncomingCallView' ||
          Get.isOverlaysOpen) {
        Get.back<void>();

        await Future<void>.delayed(
          const Duration(milliseconds: 150),
        );
      }

      if (Get.isRegistered<MessageIncomingCallController>()) {
        await Get.delete<MessageIncomingCallController>(
          force: true,
        );
      }

      await _acceptedCallHandler(
        callId: callId,
        callData: callData,
        answerResponse: answerResponse,
      );
    } finally {
      _activeIncomingCallId = null;
      _isOpeningAcceptedCall = false;
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

    _callSocketService.removeIncomingCallListener(
      _incomingCallListener,
    );

    super.onClose();
  }
}