import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/routes/routes.dart';
import 'services/reward_service.dart';

class RewardCardItem {
  final String id;
  final String title;
  final String subtitle;
  final String? buttonText;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final Color textColor;
  final Color? buttonColor;
  final Color? buttonTextColor;

  const RewardCardItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.buttonText,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.textColor,
    this.buttonColor,
    this.buttonTextColor,
  });
}

class RewardHistoryItem {
  final String id;
  final String title;
  final String date;
  final String badge;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color badgeBgColor;
  final Color badgeTextColor;

  const RewardHistoryItem({
    required this.id,
    required this.title,
    required this.date,
    required this.badge,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.badgeBgColor,
    required this.badgeTextColor,
  });
}

class RewardController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final RewardService _rewardService;
  RewardController({required RewardService rewardService}) : _rewardService = rewardService;

  final RxList<RewardCardItem> rewardCards = <RewardCardItem>[].obs;
  final RxList<RewardHistoryItem> historyItems = <RewardHistoryItem>[].obs;

  final RxBool isLoadingDashboard = false.obs;
  final RxBool isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    loadHistory();
  }

  Future<void> loadDashboard() async {
    isLoadingDashboard.value = true;
    try {
      final data = await _rewardService.fetchDashboard();
      if (data != null && data['availableRewards'] != null) {
        final List<dynamic> rewards = data['availableRewards'];
        rewardCards.assignAll(rewards.map((r) => _parseRewardCard(r)).toList());
      } else {
        // Fallback for API structure differences
        if (data != null && data['data'] != null && data['data']['availableRewards'] != null) {
           final List<dynamic> rewards = data['data']['availableRewards'];
           rewardCards.assignAll(rewards.map((r) => _parseRewardCard(r)).toList());
        }
      }
    } catch (_) {}
    isLoadingDashboard.value = false;
  }

  Future<void> loadHistory() async {
    isLoadingHistory.value = true;
    try {
      final data = await _rewardService.fetchHistory();
      if (data != null && data['entries'] != null) {
        final List<dynamic> entries = data['entries'];
        historyItems.assignAll(entries.map((e) => _parseHistoryItem(e)).toList());
      } else if (data != null && data['data'] != null && data['data']['entries'] != null) {
        final List<dynamic> entries = data['data']['entries'];
        historyItems.assignAll(entries.map((e) => _parseHistoryItem(e)).toList());
      }
    } catch (_) {}
    isLoadingHistory.value = false;
  }

  RewardCardItem _parseRewardCard(dynamic r) {
    final type = r['rewardType']?.toString() ?? '';
    return RewardCardItem(
      id: r['id']?.toString() ?? '',
      title: r['title']?.toString() ?? '',
      subtitle: r['description']?.toString() ?? '',
      buttonText: type == 'physical' ? 'gen_enter_shipping_info'.tr.tr : (type == 'digital' ? 'gen_download_pdf'.tr.tr : 'gen_start_course'.tr.tr),
      icon: type == 'physical' ? Icons.headphones_rounded : (type == 'digital' ? Icons.description_outlined : Icons.school_outlined),
      bgColor: type == 'physical' ? const Color(0xFFAED2FF) : const Color(0xFFDDF8D2),
      iconColor: type == 'physical' ? const Color(0xFF0065A8) : const Color(0xFF267A05),
      textColor: type == 'physical' ? const Color(0xFF004A75) : const Color(0xFF1D5E07),
      buttonColor: type == 'physical' ? const Color(0xFF0067A7) : Colors.white,
      buttonTextColor: type == 'physical' ? Colors.white : const Color(0xFF267A05),
    );
  }

  RewardHistoryItem _parseHistoryItem(dynamic e) {
    final status = e['status']?.toString().toUpperCase() ?? 'CLAIMED';
    return RewardHistoryItem(
      id: e['id']?.toString() ?? '',
      title: e['reward'] != null ? (e['reward']['title']?.toString() ?? '') : '',
      date: 'Recent', // Simplification for now, should parse ISO date
      badge: status,
      icon: Icons.card_giftcard,
      iconBgColor: const Color(0xFFFFE8C6),
      iconColor: const Color(0xFFFF9700),
      badgeBgColor: status == 'CLAIMED' ? const Color(0xFF79F535) : const Color(0xFFD9D9D9),
      badgeTextColor: status == 'CLAIMED' ? const Color(0xFF267A05) : const Color(0xFF5C5C5C),
    );
  }

  void onRewardTap() {
    Get.toNamed(AppRoutes.rewards);
  }

  void openChest() async {
    // Currently UI passes no ID, assume getting next available box or simple UI flow
    Get.toNamed(AppRoutes.rewardChest);
  }

  void openRewardsHistory() {
    Get.toNamed(AppRoutes.rewardsHistory);
  }

  void openRewardDetails([String id = 'boat-headphones']) {
    Get.toNamed(AppRoutes.rewardDetails, arguments: id);
  }

  void handleRewardCardTap(RewardCardItem item) async {
    await _rewardService.markAsSeen(item.id);
    
    if (item.buttonText == 'gen_enter_shipping_info'.tr.tr) {
      openRewardDetails(item.id);
      return;
    }

    Get.snackbar(
      'Reward',
      '${item.title.replaceAll('\n', ' ')} selected.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  Future<void> submitShippingAddress() async {
    // Need to get ID from arguments somehow, or pass it
    final String id = Get.arguments?.toString() ?? '';
    if (id.isNotEmpty) {
      final success = await _rewardService.saveShippingAddress(id, {
        'fullName': fullNameController.text,
        'phoneNumber': whatsappController.text,
        'addressLine': addressController.text,
      });
      if (success) {
        Get.back<void>();
        Get.snackbar(
          'Success',
          'Shipping address saved.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not save shipping address.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void confirmDelivery() async {
    final String id = Get.arguments?.toString() ?? '';
    if (id.isNotEmpty) {
      await _rewardService.confirmDelivery(id);
    }
    
    Get.back<void>();

    Get.snackbar(
      'Delivery Confirmed',
      'Our team will contact you on WhatsApp.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
