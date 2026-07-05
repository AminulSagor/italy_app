part of 'message_call_controller.dart';

extension MessageCallControllerPresentation on MessageCallController {
  Future<void> openCallScreen({bool replaceCurrent = false}) async {
    if (_routeClosed ||
        isClosed ||
        _callCoordinator.isPresentedScreenVisibleFor(_presentationId)) {
      return;
    }

    _callCoordinator.setPresentedCallScreenVisible(
      ownerId: _presentationId,
      isVisible: true,
    );

    try {
      if (replaceCurrent) {
        await Get.off<void>(() => const MessageCallView());
      } else {
        await Get.to<void>(
          () => const MessageCallView(),
          transition: Transition.rightToLeft,
        );
      }
    } finally {
      if (!_routeClosed) {
        _callCoordinator.setPresentedCallScreenVisible(
          ownerId: _presentationId,
          isVisible: false,
        );
      }
    }
  }

  void _closeRoute() {
    if (_routeClosed) {
      return;
    }

    final bool shouldCloseVisibleRoute =
        _callCoordinator.isPresentedScreenVisibleFor(_presentationId) &&
        Get.key.currentState?.canPop() == true;

    _routeClosed = true;
    _stopAllTimers();
    _callCoordinator.clearPresentedCall(_presentationId);

    if (shouldCloseVisibleRoute) {
      Get.back<void>();
    }

    final MessageCallController completedController = this;
    Future<void>.delayed(const Duration(milliseconds: 350), () async {
      if (Get.isRegistered<MessageCallController>() &&
          identical(
            Get.find<MessageCallController>(),
            completedController,
          )) {
        await Get.delete<MessageCallController>(force: true);
      }
    });
  }
}
