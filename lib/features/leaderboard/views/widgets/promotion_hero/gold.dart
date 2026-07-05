import 'package:flutter/material.dart';

import '../../league_promotion_view.dart';
import 'package:get/get.dart';

class GoldLeaguePromotionView extends StatelessWidget {
  const GoldLeaguePromotionView({super.key});

  @override
  Widget build(BuildContext context) {
    return LeaguePromotionScreen(
      headerAssetPath: 'assets/images/promotion/gold_promotion_header.png',
      leagueName: 'gold'.tr,
      xpRange: '5,000 – 9,999 XP',
      accentColor: Color(0xFFFF9300),
      lightAccentColor: Color(0xFFFFE2B5),
      leagueIcon: Icons.star_rounded,
      hasBenefit: true,
      boostTitle: '2.0× XP Boost',
      boostSubtitle: 'gen_earn_xp_faster'.tr,
      boostFooter: '2 days',
    );
  }
}
