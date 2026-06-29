import 'package:get/get.dart';

import '../models/message_models.dart';
import '../services/messages_service.dart';
import '../services/chat_socket_service.dart';
import '../sub-feature/user-block/service/user_block_api_service.dart';
import '../sub-feature/user-block/models/user_block_models.dart';
import '../../../core/services/api_error_handler.dart';
import '../views/message_block_success_view.dart';
import '../views/message_unblock_success_view.dart';
import '../views/message_report_view.dart';
import 'message_chat_controller.dart';
import 'message_report_controller.dart';
import 'messages_controller.dart';
import '../widgets/block_user_bottom_sheet.dart';
import '../widgets/unblock_user_bottom_sheet.dart';
import '../../../core/themes/app_colors.dart';
import '../../../routes/app_routes.dart';

class MessageUserInfoController extends GetxController {
  final String threadId;
  final String? fallbackName;
  final String? fallbackAvatarUrl;
  final MessagesMockService _messagesMockService;
  final UserBlockApiService _userBlockApiService;

  MessageUserInfoController({
    required this.threadId,
    this.fallbackName,
    this.fallbackAvatarUrl,
    required MessagesMockService messagesMockService,
    required UserBlockApiService userBlockApiService,
  }) : _messagesMockService = messagesMockService,
       _userBlockApiService = userBlockApiService;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<MessageUserProfileModel> profile = Rxn<MessageUserProfileModel>();
  final RxString blockStatus = 'none'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    _initSocketListeners();
  }

  void _initSocketListeners() {
    try {
      if (Get.isRegistered<ChatSocketService>()) {
        Get.find<ChatSocketService>().addBlockListener(_handleBlockChange);
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    try {
      if (Get.isRegistered<ChatSocketService>()) {
        Get.find<ChatSocketService>().removeBlockListener(_handleBlockChange);
      }
    } catch (_) {}
    super.onClose();
  }

  void _handleBlockChange(Map<String, dynamic> data) {
    try {
      final String userId = data['userId']?.toString() ?? data['blockedUserId']?.toString() ?? '';
      final String status = data['status']?.toString() ?? data['blockStatus']?.toString() ?? '';
      if (userId == threadId && status.isNotEmpty) {
        blockStatus.value = status;
        final MessageUserProfileModel? p = profile.value;
        if (p != null) {
          profile.value = p.copyWith(isBlocked: status != 'none');
        }
      }
    } catch (_) {}
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      // Fetch block status from real API
      bool isBlocked = false;
      try {
        final ApiHandledResponse<BlockStatusModel> blockRes =
            await _userBlockApiService.getBlockStatus(threadId);
        if (blockRes.success && blockRes.data != null) {
          blockStatus.value = blockRes.data!.status;
          isBlocked =
              blockRes.data!.status == 'blocked_by_me' ||
              blockRes.data!.status == 'both_blocked';
        }
      } catch (_) {
        // If block status check fails, continue with default
      }

      profile.value = await _messagesMockService.fetchUserProfile(
        threadId,
        isBlocked: isBlocked,
        fallbackName: fallbackName,
        fallbackAvatarUrl: fallbackAvatarUrl,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openBlockUserSheet() {
    final MessageUserProfileModel? currentProfile = profile.value;
    if (currentProfile == null) {
      return;
    }

    Get.bottomSheet<void>(
      BlockUserBottomSheet(userName: currentProfile.name),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void openUnblockUserSheet() {
    final MessageUserProfileModel? currentProfile = profile.value;
    if (currentProfile == null) {
      return;
    }

    Get.bottomSheet<void>(
      UnblockUserBottomSheet(userName: currentProfile.name),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void openReportUser() {
    final MessageUserProfileModel? currentProfile = profile.value;
    if (currentProfile == null) {
      return;
    }

    Get.to<void>(
      () => const MessageReportView(),
      binding: BindingsBuilder(() {
        Get.put<MessageReportController>(
          MessageReportController(
            threadId: threadId,
            profile: currentProfile,
            messagesMockService: _messagesMockService,
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> blockUser() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    try {
      final ApiHandledResponse<UserBlockModel> res = await _userBlockApiService
          .blockUser(threadId);

      if (res.success) {
        blockStatus.value = 'blocked_by_me';

        // Sync blockStatus into the active chat controller so the chat
        // input bar, call buttons, and blocked banner update instantly.
        _syncBlockStatusToChatController('blocked_by_me');

        // Notify server/other clients (if socket present)
        try {
          if (Get.isRegistered<ChatSocketService>()) {
            Get.find<ChatSocketService>().emitUserBlockChange(
              userId: threadId,
              status: 'blocked_by_me',
            );
          }
        } catch (_) {}

        // Refresh profile with blocked state
        profile.value = await _messagesMockService.fetchUserProfile(
          threadId,
          isBlocked: true,
          fallbackName: fallbackName,
          fallbackAvatarUrl: fallbackAvatarUrl,
        );

        // Remove conversation from messages list
        _removeThreadFromList();

        if (Get.isBottomSheetOpen ?? false) {
          Get.back<void>();
        }

        isSubmitting.value = false;
        Get.to<void>(
          () => const MessageBlockSuccessView(),
          transition: Transition.rightToLeft,
        );
      } else {
        isSubmitting.value = false;
        Get.snackbar(
          'Block Failed',
          res.errorCode ?? 'Could not block this user. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> unblockUser() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    try {
      final ApiHandledResponse<void> res = await _userBlockApiService
          .unblockUser(threadId);

      if (res.success) {
        blockStatus.value = 'none';

        // Sync unblock into the active chat controller so the input bar
        // and call buttons re-enable immediately.
        _syncBlockStatusToChatController('none');

        // Notify server/other clients (if socket present)
        try {
          if (Get.isRegistered<ChatSocketService>()) {
            Get.find<ChatSocketService>().emitUserBlockChange(
              userId: threadId,
              status: 'none',
            );
          }
        } catch (_) {}

        // Refresh profile with unblocked state
        profile.value = await _messagesMockService.fetchUserProfile(
          threadId,
          isBlocked: false,
          fallbackName: fallbackName,
          fallbackAvatarUrl: fallbackAvatarUrl,
        );

        if (Get.isBottomSheetOpen ?? false) {
          Get.back<void>();
        }

        isSubmitting.value = false;
        Get.to<void>(
          () => const MessageUnblockSuccessView(),
          transition: Transition.rightToLeft,
        );
      } else {
        isSubmitting.value = false;
        Get.snackbar(
          'Unblock Failed',
          res.errorCode ?? 'Could not unblock this user. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Push a new blockStatus into [MessageChatController] (if alive) so the
  /// chat screen reacts immediately — no screen reload needed.
  void _syncBlockStatusToChatController(String status) {
    try {
      if (Get.isRegistered<MessageChatController>()) {
        Get.find<MessageChatController>().blockStatus.value = status;
      }
    } catch (_) {}
  }

  /// Remove the conversation thread from the messages list after blocking.
  void _removeThreadFromList() {
    try {
      if (Get.isRegistered<MessagesController>()) {
        final MessagesController mc = Get.find<MessagesController>();
        mc.removeThread(threadId);
      }
    } catch (_) {}
  }

  void backToMessage() {
    Get.back<void>();
    Get.back<void>();
  }

  void backToMessages() {
    Get.until(
      (route) => route.settings.name == AppRoutes.wrapper || route.isFirst,
    );
  }
}
