import 'dart:async';
import 'package:italir_pothe/core/utils/app_logger.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_drawer_controller.dart';
import '../views/league_system_promotion_view.dart';
import '../views/popup_insider_view.dart';
import '../views/score_system_info_view.dart';
import '../views/widgets/leaderboard_chat_dialogue.dart';
import '../services/leaderboard_service.dart';
import '../models/leaderboard_models.dart';

class LeaderboardController extends GetxController {
  final LeaderboardService _leaderboardService;

  LeaderboardController({required LeaderboardService leaderboardService})
    : _leaderboardService = leaderboardService;

  final RxInt selectedTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;

  final RxInt selectedScoreInfoIndex = 0.obs;
  final RxInt selectedLeagueIndex = 1.obs;
  final RxBool isPromotionExpanded = true.obs;

  final TextEditingController searchController = TextEditingController();

  // Reactive lists exposed as Map<String,dynamic> to keep the existing view unchanged
  final RxList<Map<String, dynamic>> entries = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> podium = <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasAttemptedLoad = false.obs;
  final Rx<LeaderboardMetaModel?> meta = Rxn<LeaderboardMetaModel>();
  final Rxn<ProfileModel?> currentUser = Rxn<ProfileModel>();
  final Rxn<Map<String, dynamic>?> milestoneData = Rxn<Map<String, dynamic>?>();
  final RxList<LeagueModel> leagues = <LeagueModel>[].obs;

  bool get isMyLeagueSelected => selectedTabIndex.value == 0;
  bool get isGlobalSelected => selectedTabIndex.value == 1;

  List<Map<String, dynamic>> get scoreInfoTabs => <Map<String, dynamic>>[
    {
      'title': 'xp'.tr,
      'icon': Icons.bolt_rounded,
      'headline': 'xp_decides_your_leaderboard_position'.tr,
      'description':
          'Complete lessons, quizzes, vocabulary cards, and speaking tasks to earn XP every day.',
      'points': <String>[
        '+10 XP for completing a lesson',
        '+20 XP for perfect quiz score',
        '+5 XP for vocabulary practice',
      ],
    },
    {
      'title': 'streak'.tr,
      'icon': Icons.local_fire_department_rounded,
      'headline': 'daily_streak_gives_bonus_rewards'.tr,
      'description':
          'Keep learning daily to protect your streak and multiply your weekly progress.',
      'points': <String>[
        '+15 XP daily streak bonus',
        '+50 XP for 7 day streak',
        'Use freeze shield to save missed days',
      ],
    },
    {
      'title': 'bonus'.tr,
      'icon': Icons.stars_rounded,
      'headline': 'bonus_xp_helps_you_climb_faster'.tr,
      'description':
          'Extra XP appears from challenges, milestones, and special learning events.',
      'points': <String>[
        '+100 XP weekly challenge',
        '+80 XP milestone completion',
        '+30 XP surprise learning task',
      ],
    },
  ];

  List<Map<String, dynamic>> get leagueCards => <Map<String, dynamic>>[
    {
      'title': 'bronze'.tr,
      'range': '0 - 2,499 XP',
      'icon': Icons.workspace_premium_rounded,
      'color': const Color(0xFFB66B24),
      'bg': const Color(0xFFFFE6CB),
    },
    {
      'title': 'silver'.tr,
      'range': '2,500 - 4,999 XP',
      'icon': Icons.emoji_events_rounded,
      'color': AppColorsBridge.primaryGreen,
      'bg': const Color(0xFFE9FFDD),
    },
    {
      'title': 'gold'.tr,
      'range': '5,000 - 8,999 XP',
      'icon': Icons.star_rounded,
      'color': const Color(0xFFFFA500),
      'bg': const Color(0xFFFFF0CC),
    },
  ];

  // Fallback static data shown when the service hasn't returned anything yet
  List<Map<String, dynamic>> get _myLeaguePodiumUsers => <Map<String, dynamic>>[
    {'rank': 1, 'name': 'sarah_ahmed', 'xp': '4.9k', 'league': 'silver'.tr},
    {'rank': 2, 'name': 'rahul_dev', 'xp': '4.7k', 'league': 'silver'.tr},
    {'rank': 3, 'name': 'nalia_khan', 'xp': '4.6k', 'league': 'silver'.tr},
  ];

  List<Map<String, dynamic>> get _globalPodiumUsers => <Map<String, dynamic>>[
    {'rank': 1, 'name': 'sarah_ahmed', 'xp': '14.9k', 'league': '1ST'},
    {'rank': 2, 'name': 'rahul_dev', 'xp': '12.7k', 'league': '2ND'},
    {'rank': 3, 'name': 'nalia_khan', 'xp': '11.8k', 'league': '3RD'},
  ];

  List<Map<String, dynamic>> get _users => <Map<String, dynamic>>[
    {
      'rank': 13,
      'name': 'sofia_nrossi',
      'xp': '4,380',
      'league': 'silver'.tr,
      'isCurrentUser': false,
    },
    {
      'rank': 14,
      'name': 'arif_you',
      'xp': '4,299',
      'league': 'silver'.tr,
      'isCurrentUser': true,
    },
    {
      'rank': 15,
      'name': 'giulia_nbianchi',
      'xp': '3,380',
      'league': 'silver'.tr,
      'isCurrentUser': false,
    },
    {
      'rank': 16,
      'name': 'luca_nmoretti',
      'xp': '2,380',
      'league': 'silver'.tr,
      'isCurrentUser': false,
    },
    {
      'rank': 17,
      'name': 'elena_nmoretti',
      'xp': '1,380',
      'league': 'silver'.tr,
      'isCurrentUser': false,
    },
  ];

  List<Map<String, dynamic>> get podiumUsers {
    // Only show the static fallback podium before the first load attempt.
    if (!hasAttemptedLoad.value) {
      return podium.isNotEmpty
          ? podium.toList(growable: false)
          : (isGlobalSelected ? _globalPodiumUsers : _myLeaguePodiumUsers);
    }

    return podium.toList(growable: false);
  }

  List<Map<String, dynamic>> get filteredUsers {
    final String query = searchQuery.value.trim().toLowerCase();

    // Build the source list to display. If the server returned an empty
    // `entries` array but provided a `podium`, prefer showing the podium
    // users in the list so the UI doesn't show an empty state while there
    // are visible podium users. Keep the fallback static `_users` when the
    // backend hasn't been contacted yet or when a load failed.
    final List<Map<String, dynamic>> source;
    if (query.isEmpty) {
      if (!hasAttemptedLoad.value && entries.isEmpty) {
        source = _users;
      } else if (entries.isEmpty && podium.isNotEmpty) {
        source = podium.toList(growable: false);
      } else if (entries.isEmpty && hasError.value) {
        source = _users;
      } else {
        source = entries.toList(growable: false);
      }
    } else {
      // For searches, always filter the server-provided entries.
      source = entries.toList(growable: false);
    }

    if (query.isEmpty) return source;

    return source.where((Map<String, dynamic> user) {
      final String name = (user['name'] as String).toLowerCase();
      final String league = (user['league'] as String).toLowerCase();
      return name.contains(query) || league.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(loadLeaderboard());
    unawaited(loadLeagues());
    unawaited(loadScoringGuide());
    unawaited(loadPendingPromotion());

    // debounce the search query and call the backend search when user pauses typing
    debounce<String>(searchQuery, (String value) {
      unawaited(loadLeaderboard(page: 1, search: value));
    }, time: const Duration(milliseconds: 400));
  }

  final Rxn<Map<String, dynamic>> scoringGuide = Rxn<Map<String, dynamic>>();

  Future<void> loadScoringGuide() async {
    try {
      final Map<String, dynamic>? data = await _leaderboardService
          .fetchScoringGuide();
      scoringGuide.value = data;
    } catch (_) {}
  }

  Future<void> loadPendingPromotion() async {
    try {
      final Map<String, dynamic>? data = await _leaderboardService
          .fetchPendingPromotion();
      if (data != null && data['hasPendingPromotion'] == true) {
        final Map<String, dynamic>? promotion = data['promotion'];
        if (promotion != null) {
          Get.dialog<void>(
            Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.orange,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      promotion['title'] as String? ?? 'gen_congratulations'.tr,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      promotion['message'] as String? ??
                          'you_have_been_promoted'.tr,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (promotion['benefit'] != null) ...<Widget>[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (promotion['benefit']
                                      as Map<String, dynamic>)['type'] ==
                                  'xp_boost'
                              ? 'Reward: ${(promotion['benefit'] as Map<String, dynamic>)['multiplier']}x XP Boost!'
                              : 'reward_bonus_unlocked'.tr,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorsBridge.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        Get.back<void>();
                        _leaderboardService.acknowledgePromotion(
                          promotion['id'].toString(),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Text(
                          'awesome'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> loadLeagues() async {
    try {
      final List<LeagueModel> resp = await _leaderboardService.fetchLeagues();
      leagues.assignAll(resp);
    } catch (_) {
      // ignore league load failures for now
    }
  }

  Future<void> refreshLeaderboard() async {
    final String search = searchQuery.value.trim();
    await Future.wait<void>(<Future<void>>[
      loadLeaderboard(page: 1, search: search),
      loadLeagues(),
      loadScoringGuide(),
    ]);
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    searchQuery.value = '';
    searchController.clear();
    unawaited(loadLeaderboard(page: 1, search: ''));
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

  /// Load leaderboard data from the service and map to the view-friendly shapes.
  Future<void> loadLeaderboard({int page = 1, String search = ''}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final LeaderboardQueryDto dto = LeaderboardQueryDto(
        scope: isMyLeagueSelected
            ? LeaderboardScope.myLeague
            : LeaderboardScope.global,
        page: page,
        limit: 20,
        search: search.isNotEmpty ? search : null,
      );
      AppLogger.log(
        'Fetching leaderboard with ${dto.toQueryParameters()}',
        name: 'LeaderboardController',
      );

      final LeaderboardResponseModel resp = await _leaderboardService
          .fetchLeaderboard(dto: dto);
      final ProfileModel? profile =
          resp.currentUser ?? await _leaderboardService.fetchMe();

      AppLogger.log(
        'Fetched podium=${resp.podium.length} entries=${resp.entries.length}',
        name: 'LeaderboardController',
      );

      meta.value = resp.meta;
      currentUser.value = profile;
      currentUser.refresh();
      if (profile != null && Get.isRegistered<AppDrawerController>()) {
        Get.find<AppDrawerController>().updateLeague(
          profile.league.name,
          rank: profile.leagueRank,
        );
      }
      milestoneData.value = resp.milestone;

      // Map podium and entries to the small map shape the view expects
      podium.assignAll(
        resp.podium
            .map<Map<String, dynamic>>(
              (RankedProfileModel r) => _rankedToMap(r, compactXp: true),
            )
            .toList(growable: false),
      );

      entries.assignAll(
        resp.entries
            .map<Map<String, dynamic>>(
              (RankedProfileModel r) => _rankedToMap(r, compactXp: false),
            )
            .toList(growable: false),
      );
    } catch (_) {
      hasError.value = true;
      errorMessage.value = 'Failed to load leaderboard.';
    } finally {
      isLoading.value = false;
      hasAttemptedLoad.value = true;
    }
  }

  Map<String, dynamic> _rankedToMap(
    RankedProfileModel r, {
    bool compactXp = false,
  }) {
    return <String, dynamic>{
      'rank': r.rank,
      'name': r.displayName,
      'xp': compactXp
          ? _formatCompact(r.totalXp)
          : _formatWithCommas(r.totalXp),
      'league': (r.league.name).toUpperCase(),
      'isCurrentUser': r.isCurrentUser,
      'userId': r.userId,
      'avatarUrl': r.avatarUrl,
      'streakDays': r.streakDays,
      'totalXp': r.totalXp,
    };
  }

  String get myRankLabel {
    final ProfileModel? p = currentUser.value;
    if (p == null) return '-';
    final int? rank = p.scopeRank ?? p.leagueRank ?? p.globalRank;
    final String name = p.displayName + (p.isCurrentUser ? ' (You)' : '');
    return '#${rank ?? '-'} | $name';
  }

  String get myXpLabel {
    final ProfileModel? p = currentUser.value;
    if (p == null) return '- XP';
    return '${_formatWithCommas(p.totalXp)} XP';
  }

  String _formatCompact(int n) {
    if (n < 1000) return n.toString();
    if (n < 10000) return (n / 1000).toStringAsFixed(1) + 'k';
    return (n / 1000).toStringAsFixed(0) + 'k';
  }

  String _formatWithCommas(int n) {
    final String s = n.toString();
    final StringBuffer sb = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      sb.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        sb.write(',');
        count = 0;
      }
    }
    return sb.toString().split('').reversed.join();
  }

  Future<void> onMessageTap(Map<String, dynamic> user) async {
    final bool isCurrentUser = (user['isCurrentUser'] as bool?) ?? false;

    if (isCurrentUser) {
      return;
    }

    final String userId = user['userId']?.toString().trim() ?? '';

    if (userId.isEmpty) {
      return;
    }

    final ProfileModel? preview = await _leaderboardService.fetchUserPreview(
      userId,
    );

    if (preview == null || preview.canChat != true) {
      final BuildContext? snackbarContext = Get.overlayContext;
      if (snackbarContext != null && snackbarContext.mounted) {
        ScaffoldMessenger.maybeOf(snackbarContext)?.showSnackBar(
          SnackBar(content: Text('this_user_cannot_be_messaged_right_now'.tr)),
        );
      }
      return;
    }

    final BuildContext? dialogContext = Get.overlayContext;
    if (isClosed || dialogContext == null || !dialogContext.mounted) {
      return;
    }

    await showDialog<void>(
      context: dialogContext,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (BuildContext context) => LeaderboardChatDialog(
        user: <String, dynamic>{
          ...user,
          'chatTargetUserId': preview.chatTargetUserId,
          'totalXp': preview.totalXp,
          'streakDays': preview.streakDays,
          'avatarUrl': preview.avatarUrl,
        },
      ),
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
