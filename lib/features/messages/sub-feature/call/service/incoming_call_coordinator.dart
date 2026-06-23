import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controllers/message_incoming_call_controller.dart';
import '../views/message_incoming_call_view.dart';
import 'call_socket_service.dart';

class IncomingCallCoordinator extends GetxService {
  IncomingCallCoordinator({
    required CallSocketService callSocketService,
  }) : _callSocketService = callSocketService;

  final CallSocketService _callSocketService;

  String? _activeIncomingCallId;

  late final void Function(Map<String, dynamic>)
  _incomingCallListener;

  @override
  void onInit() {
    super.onInit();

    _incomingCallListener =
        _handleIncomingCall;

    _callSocketService.addIncomingCallListener(
      _incomingCallListener,
    );
  }

  @override
  void onReady() {
    super.onReady();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        unawaited(_connectCallSocket());
      },
    );
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

  void _handleIncomingCall(
      Map<String, dynamic> payload,
      ) {
    unawaited(
      _openIncomingCall(payload),
    );
  }

  Future<void> _openIncomingCall(
      Map<String, dynamic> payload,
      ) async {
    final Map<String, dynamic> call =
    _toMap(payload['call']);

    final String callId =
        call['id']?.toString() ?? '';

    if (callId.isEmpty) {
      debugPrint(
        '[IncomingCallCoordinator] Incoming call ID is missing',
      );

      return;
    }

    if (_activeIncomingCallId == callId) {
      return;
    }

    /*
     * Only one incoming call screen should be
     * displayed at a time.
     */
    if (_activeIncomingCallId != null) {
      debugPrint(
        '[IncomingCallCoordinator] Another incoming call is already open',
      );

      return;
    }

    _activeIncomingCallId = callId;

    if (Get.isRegistered<
        MessageIncomingCallController>()) {
      await Get.delete<
          MessageIncomingCallController>(
        force: true,
      );
    }

    Get.put<MessageIncomingCallController>(
      MessageIncomingCallController(
        payload: payload,
        callSocketService:
        _callSocketService,
      ),
    );

    try {
      await Get.to<void>(
            () => const MessageIncomingCallView(),
        transition: Transition.downToUp,
        fullscreenDialog: true,
      );
    } finally {
      if (Get.isRegistered<
          MessageIncomingCallController>()) {
        await Get.delete<
            MessageIncomingCallController>(
          force: true,
        );
      }

      _activeIncomingCallId = null;
    }
  }

  Future<void> reconnectAfterLogin() async {
    await _callSocketService
        .refreshConnectionAfterLogin();
  }

  static Map<String, dynamic> _toMap(
      dynamic value,
      ) {
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
    _callSocketService
        .removeIncomingCallListener(
      _incomingCallListener,
    );

    super.onClose();
  }
}