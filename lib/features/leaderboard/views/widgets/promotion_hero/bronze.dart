import 'package:flutter/material.dart';

import '../../league_promotion_view.dart';

class BronzeLeaguePromotionView extends StatelessWidget {
  const BronzeLeaguePromotionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeaguePromotionScreen(
      headerAssetPath: 'assets/images/promotion/bronze_promotion_header.png',
      leagueName: 'Bronze',
      xpRange: '400–1,000 XP',
      accentColor: Color(0xFF9A5A08),
      lightAccentColor: Color(0xFFFFE8D2),
      leagueIcon: Icons.workspace_premium_rounded,
    );
  }
}
