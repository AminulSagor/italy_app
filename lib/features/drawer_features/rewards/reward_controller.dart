import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/routes/routes.dart';

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

  final List<RewardCardItem> rewardCards = const <RewardCardItem>[
    RewardCardItem(
      id: 'a2-course',
      title: 'Level A2\nCourse\nUnlocked',
      subtitle: '',
      buttonText: 'START COURSE',
      icon: Icons.school_outlined,
      bgColor: Color(0xFFDDF8D2),
      iconColor: Color(0xFF267A05),
      textColor: Color(0xFF1D5E07),
      buttonColor: Colors.white,
      buttonTextColor: Color(0xFF267A05),
    ),
    RewardCardItem(
      id: 'streak-freeze',
      title: '3× Streak\nFreeze',
      subtitle: 'Protect your streak if you\nmiss a day',
      icon: Icons.ac_unit_rounded,
      bgColor: Color(0xFFAED2FF),
      iconColor: Color(0xFF0065A8),
      textColor: Color(0xFF111111),
    ),
    RewardCardItem(
      id: 'boat-headphones',
      title: 'Physical Prize:\nBoat\nHeadphones',
      subtitle: '',
      buttonText: 'ENTER SHIPPING INFO',
      icon: Icons.headphones_rounded,
      bgColor: Color(0xFFAED2FF),
      iconColor: Color(0xFF0065A8),
      textColor: Color(0xFF004A75),
      buttonColor: Color(0xFF0067A7),
      buttonTextColor: Colors.white,
    ),
    RewardCardItem(
      id: 'verb-guide',
      title: 'Exclusive:\nAdvanced Verb\nGuide',
      subtitle: '',
      buttonText: 'DOWNLOAD PDF',
      icon: Icons.description_outlined,
      bgColor: Color(0xFFE9D3FF),
      iconColor: Color(0xFF8728D9),
      textColor: Color(0xFF592192),
      buttonColor: Color(0xFF8728D9),
      buttonTextColor: Colors.white,
    ),
  ];

  final List<RewardHistoryItem> historyItems = const <RewardHistoryItem>[
    RewardHistoryItem(
      id: 'bonus-xp',
      title: '+100 Bonus XP',
      date: 'Oct 28,\n2023',
      badge: 'CLAIMED',
      icon: Icons.flash_on_rounded,
      iconBgColor: Color(0xFFFFE8C6),
      iconColor: Color(0xFFFF9700),
      badgeBgColor: Color(0xFF79F535),
      badgeTextColor: Color(0xFF267A05),
    ),
    RewardHistoryItem(
      id: 'streak-freeze',
      title: '3× Streak\nFreeze',
      date: 'Oct 15,\n2023',
      badge: 'CLAIMED',
      icon: Icons.ac_unit_rounded,
      iconBgColor: Color(0xFFE7F3FF),
      iconColor: Color(0xFF0065A8),
      badgeBgColor: Color(0xFF79F535),
      badgeTextColor: Color(0xFF267A05),
    ),
    RewardHistoryItem(
      id: 'a1-certificate',
      title: 'Level A1\nCertificate',
      date: 'Oct 02,\n2023',
      badge: 'ISSUED',
      icon: Icons.school_rounded,
      iconBgColor: Color(0xFFE2FAD8),
      iconColor: Color(0xFF267A05),
      badgeBgColor: Color(0xFFD9D9D9),
      badgeTextColor: Color(0xFF5C5C5C),
    ),
    RewardHistoryItem(
      id: 'boat-headphones',
      title: 'Boat\nHeadphones',
      date: 'Sept 20,\n2023',
      badge: 'DELIVERED',
      icon: Icons.headphones_rounded,
      iconBgColor: Color(0xFFFFF3EA),
      iconColor: Color(0xFFA76500),
      badgeBgColor: Color(0xFFFFE3B7),
      badgeTextColor: Color(0xFFA76500),
    ),
  ];

  void onRewardTap() {
    Get.toNamed(AppRoutes.rewards);
  }

  void openChest() {
    Get.toNamed(AppRoutes.rewardChest);
  }

  void openRewardsHistory() {
    Get.toNamed(AppRoutes.rewardsHistory);
  }

  void openRewardDetails([String id = 'boat-headphones']) {
    Get.toNamed(AppRoutes.rewardDetails, arguments: id);
  }

  void handleRewardCardTap(RewardCardItem item) {
    if (item.id == 'boat-headphones') {
      openRewardDetails(item.id);
      return;
    }

    Get.snackbar(
      'Reward',
      '${item.title.replaceAll('\n', ' ')} selected.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void confirmDelivery() {
    Get.back();

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
