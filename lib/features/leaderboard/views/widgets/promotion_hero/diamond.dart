import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../league_promotion_view.dart';

class DiamondLeaguePromotionView extends StatelessWidget {
  const DiamondLeaguePromotionView({super.key});

  @override
  Widget build(BuildContext context) {
    return LeaguePromotionScreen(
      headerAssetPath: 'assets/images/promotion/diamond_promotion_header.png',
      leagueName: 'diamond'.tr,
      xpRange: '10000+ XP',
      accentColor: Color(0xFF009AAA),
      lightAccentColor: Color(0xFFD8FAFA),
      leagueIcon: Icons.diamond_rounded,
      hasBenefit: true,
      boostTitle: '3.0× XP Boost',
      boostSubtitle: 'gen_earn_xp_faster'.tr,
      boostFooter: '3 days',
    );
  }
}
