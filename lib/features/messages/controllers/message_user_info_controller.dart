import 'package:get/get.dart';

import '../models/message_models.dart';
import '../services/messages_mock_service.dart';
import '../views/message_block_success_view.dart';
import '../views/message_unblock_success_view.dart';
import '../views/message_report_view.dart';
import 'message_report_controller.dart';
import '../widgets/block_user_bottom_sheet.dart';
import '../widgets/unblock_user_bottom_sheet.dart';
import '../../../core/themes/app_colors.dart';
import '../../../routes/app_routes.dart';

class MessageUserInfoController extends GetxController {
  final String threadId;
  final MessagesMockService _messagesMockService;

  MessageUserInfoController({
    required this.threadId,
    required MessagesMockService messagesMockService,
  }) : _messagesMockService = messagesMockService;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<MessageUserProfileModel> profile = Rxn<MessageUserProfileModel>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      profile.value = await _messagesMockService.fetchUserProfile(threadId);
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
      profile.value = await _messagesMockService.blockUser(threadId);
      if (Get.isBottomSheetOpen ?? false) {
        Get.back<void>();
      }
      isSubmitting.value = false;
      Get.to<void>(
        () => const MessageBlockSuccessView(),
        transition: Transition.rightToLeft,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> unblockUser() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    try {
      profile.value = await _messagesMockService.unblockUser(threadId);
      if (Get.isBottomSheetOpen ?? false) {
        Get.back<void>();
      }
      isSubmitting.value = false;
      Get.to<void>(
        () => const MessageUnblockSuccessView(),
        transition: Transition.rightToLeft,
      );
    } finally {
      isSubmitting.value = false;
    }
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
