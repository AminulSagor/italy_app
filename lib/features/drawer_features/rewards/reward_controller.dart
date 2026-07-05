import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/routes.dart';
import 'models/reward_models.dart';
import 'models/reward_response_models.dart';
import 'services/reward_api_service.dart';

class RewardController extends GetxController {
  RewardController({required RewardApiService apiService})
    : _apiService = apiService;

  final RewardApiService _apiService;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final RxBool isLoadingDashboard = false.obs;
  final RxBool isRefreshingDashboard = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isLoadingMoreHistory = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isOpeningReward = false.obs;
  final RxBool isSavingShippingAddress = false.obs;
  final RxBool isConfirmingDelivery = false.obs;
  final RxBool isDownloadingReward = false.obs;

  final RxString dashboardError = ''.obs;
  final RxString historyError = ''.obs;
  final RxString detailsError = ''.obs;

  final Rxn<RewardDashboardModel> dashboard = Rxn<RewardDashboardModel>();
  final Rxn<RewardChestModel> selectedChest = Rxn<RewardChestModel>();
  final Rxn<RewardModel> selectedReward = Rxn<RewardModel>();
  final RxList<RewardModel> historyItems = <RewardModel>[].obs;

  final RxInt historyPage = 1.obs;
  final RxInt historyTotalPages = 0.obs;
  final RxInt historyTotal = 0.obs;
  final RxString shippingRewardId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  RewardChestModel? get activeChest =>
      selectedChest.value ?? dashboard.value?.pendingChest;

  bool get hasMoreHistory => historyPage.value < historyTotalPages.value;

  Future<void> loadDashboard({bool refresh = false}) async {
    if (isLoadingDashboard.value || isRefreshingDashboard.value) return;

    if (refresh) {
      isRefreshingDashboard.value = true;
    } else {
      isLoadingDashboard.value = true;
    }
    dashboardError.value = '';

    final ApiResult<RewardDashboardModel> result =
        await ApiErrorHandler.call<RewardDashboardModel>(
          _apiService.getDashboard,
          showError: false,
        );

    if (result.isSuccess && result.data != null) {
      dashboard.value = result.data;
      if (selectedChest.value != null &&
          result.data!.pendingChest?.id != selectedChest.value!.id) {
        selectedChest.value = result.data!.pendingChest;
      }
    } else {
      dashboardError.value = result.error ?? 'could_not_load_rewards'.tr;
    }

    isLoadingDashboard.value = false;
    isRefreshingDashboard.value = false;
  }

  Future<void> refreshDashboard() async {
    await loadDashboard(refresh: true);
    if (historyItems.isNotEmpty) {
      await loadHistory(reset: true, showLoader: false);
    }
  }

  void openChest() {
    final RewardChestModel? chest = dashboard.value?.pendingChest;
    if (chest == null) {
      _showMessage('Rewards', 'There is no unopened reward chest right now.');
      return;
    }

    selectedChest.value = chest;
    selectedReward.value = null;
    detailsError.value = '';
    Get.toNamed(AppRoutes.rewardChest, arguments: chest.id);
  }

  Future<void> openSelectedChest() async {
    final RewardChestModel? chest = activeChest;
    if (chest == null || isOpeningReward.value) return;

    isOpeningReward.value = true;
    final ApiResult<RewardOpenResponseModel> result =
        await ApiErrorHandler.call<RewardOpenResponseModel>(
          () => _apiService.openReward(chest.id),
          showError: true,
          errorTitle: 'could_not_open_reward'.tr,
        );

    if (result.isSuccess && result.data != null) {
      selectedReward.value = result.data!.reward;
      _showMessage(
        'Reward unlocked',
        result.data!.message.isEmpty
            ? 'your_reward_has_been_added_successfully'.tr
            : result.data!.message,
      );
      await _reloadAfterMutation();
    }
    isOpeningReward.value = false;
  }

  Future<void> openRewardsHistory() async {
    Get.toNamed(AppRoutes.rewardsHistory);
    await loadHistory(reset: true);
  }

  Future<void> loadHistory({
    bool reset = false,
    bool showLoader = true,
  }) async {
    if (isLoadingHistory.value || isLoadingMoreHistory.value) return;

    final int page = reset ? 1 : historyPage.value;
    if (showLoader) isLoadingHistory.value = true;
    historyError.value = '';

    final ApiResult<RewardHistoryResponseModel> result =
        await ApiErrorHandler.call<RewardHistoryResponseModel>(
          () => _apiService.getHistory(page: page),
          showError: false,
        );

    if (result.isSuccess && result.data != null) {
      historyItems.assignAll(result.data!.items);
      historyPage.value = result.data!.page;
      historyTotalPages.value = result.data!.totalPages;
      historyTotal.value = result.data!.total;
    } else {
      historyError.value = result.error ?? 'could_not_load_reward_history'.tr;
    }
    isLoadingHistory.value = false;
  }

  Future<void> loadMoreHistory() async {
    if (!hasMoreHistory || isLoadingMoreHistory.value) return;
    isLoadingMoreHistory.value = true;

    final int nextPage = historyPage.value + 1;
    final ApiResult<RewardHistoryResponseModel> result =
        await ApiErrorHandler.call<RewardHistoryResponseModel>(
          () => _apiService.getHistory(page: nextPage),
          showError: true,
        );

    if (result.isSuccess && result.data != null) {
      historyItems.addAll(result.data!.items);
      historyPage.value = result.data!.page;
      historyTotalPages.value = result.data!.totalPages;
      historyTotal.value = result.data!.total;
    }
    isLoadingMoreHistory.value = false;
  }

  Future<void> openRewardDetails(String rewardId) async {
    selectedReward.value = null;
    detailsError.value = '';
    Get.toNamed(AppRoutes.rewardDetails, arguments: rewardId);
    await loadRewardDetails(rewardId);
  }

  Future<RewardModel?> loadRewardDetails(String rewardId) async {
    if (rewardId.trim().isEmpty) return null;
    isLoadingDetails.value = true;
    detailsError.value = '';

    final ApiResult<RewardModel> result =
        await ApiErrorHandler.call<RewardModel>(
          () => _apiService.getReward(rewardId),
          showError: false,
        );

    if (result.isSuccess && result.data != null) {
      selectedReward.value = result.data;
    } else {
      detailsError.value = result.error ?? 'could_not_load_reward_details'.tr;
    }
    isLoadingDetails.value = false;
    return result.data;
  }

  Future<bool> prepareShippingAddress(RewardModel reward) async {
    RewardModel? detail = reward;
    if (reward.shippingAddress == null || reward.earnedReason == null) {
      detail = await loadRewardDetails(reward.id);
    }
    if (detail == null) return false;

    selectedReward.value = detail;
    shippingRewardId.value = detail.id;
    fullNameController.text = detail.shippingAddress?.fullName ??
        dashboard.value?.displayName ??
        '';
    whatsappController.text = detail.shippingAddress?.whatsappNumber ?? '';
    addressController.text = detail.shippingAddress?.addressLine ?? '';
    return true;
  }

  Future<void> submitShippingAddress() async {
    final String rewardId = shippingRewardId.value.trim();
    if (rewardId.isEmpty || isSavingShippingAddress.value) return;

    final String? validationError = _validateShippingAddress();
    if (validationError != null) {
      _showMessage('Shipping information', validationError);
      return;
    }

    isSavingShippingAddress.value = true;
    final RewardShippingAddressPayloadModel payload =
        RewardShippingAddressPayloadModel(
          fullName: fullNameController.text,
          whatsappNumber: whatsappController.text,
          addressLine: addressController.text,
        );

    final ApiResult<RewardModel> result =
        await ApiErrorHandler.call<RewardModel>(
          () => _apiService.saveShippingAddress(
            rewardId: rewardId,
            payload: payload,
          ),
          errorTitle: 'could_not_save_shipping_address'.tr,
        );

    if (result.isSuccess && result.data != null) {
      selectedReward.value = result.data;
      if (Get.isDialogOpen == true) Get.back<void>();
      _showMessage(
        'Shipping address saved',
        'Our team will contact you when the reward is dispatched.',
      );
      await _reloadAfterMutation();
    }
    isSavingShippingAddress.value = false;
  }

  Future<void> confirmDelivery(RewardModel reward) async {
    if (!reward.canConfirmDelivery || isConfirmingDelivery.value) return;
    isConfirmingDelivery.value = true;

    final ApiResult<void> result = await ApiErrorHandler.call<void>(
      () => _apiService.confirmDelivery(reward.id),
      errorTitle: 'could_not_confirm_delivery'.tr,
    );

    if (result.isSuccess) {
      _showMessage('Delivery confirmed', 'Thank you for confirming delivery.');
      await loadRewardDetails(reward.id);
      await _reloadAfterMutation();
    }
    isConfirmingDelivery.value = false;
  }

  Future<void> downloadReward(RewardModel reward) async {
    if (isDownloadingReward.value) return;
    isDownloadingReward.value = true;

    final ApiResult<RewardDownloadModel> result =
        await ApiErrorHandler.call<RewardDownloadModel>(
          () => _apiService.getDownload(reward.id),
          errorTitle: 'download_unavailable'.tr,
        );

    if (result.isSuccess && result.data != null) {
      await _launchExternalUrl(result.data!.fileUrl);
    }
    isDownloadingReward.value = false;
  }

  Future<void> handleRewardAction(RewardModel reward) async {
    final RewardActionType action =
        reward.action?.type ?? RewardActionType.unknown;

    switch (action) {
      case RewardActionType.openChest:
        final RewardChestModel? pending = dashboard.value?.pendingChest;
        if (pending?.id == reward.id) {
          selectedChest.value = pending;
          Get.toNamed(AppRoutes.rewardChest, arguments: reward.id);
        } else {
          await openRewardDetails(reward.id);
        }
        return;
      case RewardActionType.downloadFile:
      case RewardActionType.viewCertificate:
        await downloadReward(reward);
        return;
      case RewardActionType.startCourse:
        _showMessage(
          'Course unlocked',
          'Your course access is active. Open the Courses section to begin.',
        );
        return;
      case RewardActionType.shippingAddress:
      case RewardActionType.trackDelivery:
      case RewardActionType.unknown:
        await openRewardDetails(reward.id);
        return;
    }
  }

  Future<void> _reloadAfterMutation() async {
    await loadDashboard(refresh: true);
    if (historyItems.isNotEmpty) {
      await loadHistory(reset: true, showLoader: false);
    }
  }

  String? _validateShippingAddress() {
    if (fullNameController.text.trim().length < 2) {
      return 'enter_the_recipient_full_name'.tr;
    }
    if (whatsappController.text.trim().length < 6) {
      return 'enter_a_valid_whatsapp_number'.tr;
    }
    if (addressController.text.trim().length < 8) {
      return 'enter_the_complete_delivery_address'.tr;
    }
    return null;
  }

  Future<void> _launchExternalUrl(String value) async {
    final Uri? uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) {
      _showMessage('Download unavailable', 'The download link is invalid.');
      return;
    }

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showMessage('Download unavailable', 'Could not open the reward file.');
      }
    } catch (error, stackTrace) {
      dev.log(
        'Failed to launch reward URL.',
        name: 'RewardController',
        error: error,
        stackTrace: stackTrace,
      );
      _showMessage('Download unavailable', 'Could not open the reward file.');
    }
  }

  void _showMessage(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
