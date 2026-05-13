import 'package:flutter/material.dart';

import '../../league_promotion_view.dart';

class SilverLeaguePromotionView extends StatelessWidget {
  const SilverLeaguePromotionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeaguePromotionScreen(
      headerAssetPath: 'assets/images/promotion/silver_promotion_header.png',
      leagueName: 'Silver',
      xpRange: '1,000 – 4,999 XP',
      accentColor: Color(0xFF0070B8),
      lightAccentColor: Color(0xFFD9E9FF),
      leagueIcon: Icons.workspace_premium_rounded,
    );
  }
}
