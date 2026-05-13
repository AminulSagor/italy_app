import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/league_system_promotion_view.dart';
import '../views/popup_insider_view.dart';
import '../views/score_system_info_view.dart';
import '../views/widgets/leaderboard_chat_dialogue.dart';

class LeaderboardController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;

  final RxInt selectedScoreInfoIndex = 0.obs;
  final RxInt selectedLeagueIndex = 1.obs;
  final RxBool isPromotionExpanded = true.obs;

  final TextEditingController searchController = TextEditingController();

  bool get isMyLeagueSelected => selectedTabIndex.value == 0;
  bool get isGlobalSelected => selectedTabIndex.value == 1;

  final List<Map<String, dynamic>> scoreInfoTabs = <Map<String, dynamic>>[
    {
      'title': 'XP',
      'icon': Icons.bolt_rounded,
      'headline': 'XP decides your leaderboard position',
      'description':
          'Complete lessons, quizzes, vocabulary cards, and speaking tasks to earn XP every day.',
      'points': <String>[
        '+10 XP for completing a lesson',
        '+20 XP for perfect quiz score',
        '+5 XP for vocabulary practice',
      ],
    },
    {
      'title': 'Streak',
      'icon': Icons.local_fire_department_rounded,
      'headline': 'Daily streak gives bonus rewards',
      'description':
          'Keep learning daily to protect your streak and multiply your weekly progress.',
      'points': <String>[
        '+15 XP daily streak bonus',
        '+50 XP for 7 day streak',
        'Use freeze shield to save missed days',
      ],
    },
    {
      'title': 'Bonus',
      'icon': Icons.stars_rounded,
      'headline': 'Bonus XP helps you climb faster',
      'description':
          'Extra XP appears from challenges, milestones, and special learning events.',
      'points': <String>[
        '+100 XP weekly challenge',
        '+80 XP milestone completion',
        '+30 XP surprise learning task',
      ],
    },
  ];

  final List<Map<String, dynamic>> leagueCards = <Map<String, dynamic>>[
    {
      'title': 'Bronze',
      'range': '0 - 2,499 XP',
      'icon': Icons.workspace_premium_rounded,
      'color': const Color(0xFFB66B24),
      'bg': const Color(0xFFFFE6CB),
    },
    {
      'title': 'Silver',
      'range': '2,500 - 4,999 XP',
      'icon': Icons.emoji_events_rounded,
      'color': AppColorsBridge.primaryGreen,
      'bg': const Color(0xFFE9FFDD),
    },
    {
      'title': 'Gold',
      'range': '5,000 - 8,999 XP',
      'icon': Icons.star_rounded,
      'color': const Color(0xFFFFA500),
      'bg': const Color(0xFFFFF0CC),
    },
  ];

  final List<Map<String, dynamic>> _myLeaguePodiumUsers =
      <Map<String, dynamic>>[
        {'rank': 1, 'name': 'Sarah Ahmed', 'xp': '4.9k', 'league': 'SILVER'},
        {'rank': 2, 'name': 'Rahul Dev', 'xp': '4.7k', 'league': 'SILVER'},
        {'rank': 3, 'name': 'Nalia Khan', 'xp': '4.6k', 'league': 'SILVER'},
      ];

  final List<Map<String, dynamic>> _globalPodiumUsers = <Map<String, dynamic>>[
    {'rank': 1, 'name': 'Sarah Ahmed', 'xp': '14.9k', 'league': '1ST'},
    {'rank': 2, 'name': 'Rahul Dev', 'xp': '12.7k', 'league': '2ND'},
    {'rank': 3, 'name': 'Nalia Khan', 'xp': '11.8k', 'league': '3RD'},
  ];

  final List<Map<String, dynamic>> _users = <Map<String, dynamic>>[
    {
      'rank': 13,
      'name': 'Sofia\nRossi',
      'xp': '4,380',
      'league': 'SILVER',
      'isCurrentUser': false,
    },
    {
      'rank': 14,
      'name': 'Arif (You)',
      'xp': '4,299',
      'league': 'SILVER',
      'isCurrentUser': true,
    },
    {
      'rank': 15,
      'name': 'Giulia\nBianchi',
      'xp': '3,380',
      'league': 'SILVER',
      'isCurrentUser': false,
    },
    {
      'rank': 16,
      'name': 'Luca\nMoretti',
      'xp': '2,380',
      'league': 'SILVER',
      'isCurrentUser': false,
    },
    {
      'rank': 17,
      'name': 'Elena\nMoretti',
      'xp': '1,380',
      'league': 'SILVER',
      'isCurrentUser': false,
    },
  ];

  List<Map<String, dynamic>> get podiumUsers {
    return isGlobalSelected ? _globalPodiumUsers : _myLeaguePodiumUsers;
  }

  List<Map<String, dynamic>> get filteredUsers {
    final String query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) return _users;

    return _users.where((Map<String, dynamic> user) {
      final String name = (user['name'] as String).toLowerCase();
      final String league = (user['league'] as String).toLowerCase();
      return name.contains(query) || league.contains(query);
    }).toList();
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    searchQuery.value = '';
    searchController.clear();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void onScoreInfoChanged(int index) {
    selectedScoreInfoIndex.value = index;
  }

  void onLeagueChanged(int index) {
    selectedLeagueIndex.value = index;
  }

  void togglePromotionExpanded() {
    isPromotionExpanded.toggle();
  }

  void onHelpTap() {
    Get.to<void>(
      () => const ScoreSystemInfoView(),
      transition: Transition.rightToLeft,
    );
  }

  void onRankInfoTap() {
    Get.dialog<void>(
      const LeagueSystemPromotionView(),
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  void openPopupInsiderPage() {
    Get.to<void>(
      () => const PopupInsiderView(),
      transition: Transition.rightToLeft,
    );
  }

  void onMessageTap(Map<String, dynamic> user) {
    if ((user['isCurrentUser'] as bool?) ?? false) return;

    Get.dialog<void>(
      LeaderboardChatDialog(user: user),
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class AppColorsBridge {
  static const Color primaryGreen = Color(0xFF2A6900);
}
