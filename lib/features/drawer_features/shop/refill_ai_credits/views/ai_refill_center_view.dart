import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/themes/app_colors.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
import 'package:italir_pothe/core/widgets/simple_appbar.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../models/shop_models.dart';
import '../../shop_controller.dart';

class AiRefillCenterPage extends StatelessWidget {
  const AiRefillCenterPage({super.key});

  static const Color bg = AppColors.scaffoldBackground;
  static const Color green = AppColors.primaryGreen;
  static const Color darkGreen = AppColors.primaryBtnShadow;
  static const Color textDark = AppColors.black;
  static const Color muted = AppColors.bodyText;
  static const Color orange = AppColors.notificationRed;
  static const Color paleOrange = Color(0xFFFFF7E6);

  @override
  Widget build(BuildContext context) {
    final ShopController controller = Get.find<ShopController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: SimpleAppbar(
        onBackTap: () => Navigator.maybePop(context),
        title: 'gen_ai_refill_center'.tr,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: <Widget>[
                    Obx(() => _topStats(controller)),
                    const SizedBox(height: 24),
                    _heroCard(),
                    const SizedBox(height: 24),
                    Obx(() {
                      if (controller.aiPackages.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('no_ai_refill_packages_are_available'.tr),
                        );
                      }
                      return Column(
                        children: controller.aiPackages
                            .asMap()
                            .entries
                            .map((MapEntry<int, StorePackageModel> entry) {
                              final StorePackageModel package = entry.value;
                              final bool warmCard = entry.key.isOdd;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _selectablePlanCard(
                                  title: package.name,
                                  subtitle: package.entitlementSummary,
                                  price: controller.packagePriceText(package),
                                  badgeText: _badgeText(package.marketingBadge),
                                  isSelected: controller.isAiPackageSelected(
                                    package.id,
                                  ),
                                  onTap: () =>
                                      controller.selectAiPackage(package.id),
                                  unselectedBgColor: warmCard
                                      ? paleOrange
                                      : Colors.white,
                                  unselectedBorderColor: warmCard
                                      ? const Color(0xFFFFEBC0)
                                      : const Color(0xFFEDEDED),
                                  unselectedSubtitleColor: warmCard
                                      ? orange
                                      : muted,
                                  unselectedPriceBgColor: warmCard
                                      ? Colors.white
                                      : const Color(0xFFE8E6E6),
                                  unselectedPriceTextColor: warmCard
                                      ? orange
                                      : const Color(0xFF3A3434),
                                  unselectedPriceBorderColor: warmCard
                                      ? const Color(0xFFF8D564)
                                      : Colors.transparent,
                                ),
                              );
                            })
                            .toList(growable: false),
                      );
                    }),
                    const SizedBox(height: 8),
                    _infoCard(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Obx(
                () => CustomButton.primary(
                  text: controller.isLoadingQuote.value
                      ? 'loading'.tr
                      : 'confirm_purchase_1'.tr,
                  onPressed:
                      controller.isLoadingQuote.value ||
                          controller.aiPackages.isEmpty
                      ? () {}
                      : controller.confirmPurchase,
                  btnColor: green,
                  borderRadius: 30,
                  btnShadowColor: darkGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topStats(ShopController controller) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              icon: Icons.mic,
              label: 'voice_minutes_value'.trParams(<String, String>{
                'count': controller.aiVoiceMinutes.toString(),
              }),
              color: green,
            ),
          ),
          Container(height: 34, width: 1, color: const Color(0xFFE7E7E7)),
          Expanded(
            child: _statItem(
              icon: Symbols.deployed_code,
              label: 'text_tokens_value'.trParams(<String, String>{
                'count': controller.aiTextTokens.toString(),
              }),
              color: const Color.fromARGB(255, 202, 114, 42),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: textDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      height: 118,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color(0xFF287A04), Color(0xFF176700)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: green.withValues(alpha: .18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          const Positioned(
            right: -8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.forum_rounded,
                size: 82,
                color: Color(0x38FFFFFF),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ai_mastery'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ai_credit_usage_description'.tr,
                  style: TextStyle(
                    color: Color(0xFFD5E5CC),
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectablePlanCard({
    required String title,
    required String subtitle,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
    String badgeText = '',
    Color unselectedBgColor = Colors.white,
    Color unselectedBorderColor = const Color(0xFFEDEDED),
    Color unselectedSubtitleColor = muted,
    Color unselectedPriceBgColor = const Color(0xFFE8E6E6),
    Color unselectedPriceTextColor = const Color(0xFF3A3434),
    Color unselectedPriceBorderColor = Colors.transparent,
  }) {
    final bool hasBadge = badgeText.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 82),
            padding: EdgeInsets.fromLTRB(16, hasBadge ? 16 : 12, 14, 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : unselectedBgColor,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: isSelected ? green : unselectedBorderColor,
                width: isSelected ? 1.7 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .10),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _planText(
                    title: title,
                    subtitle: subtitle,
                    subtitleColor: isSelected ? green : unselectedSubtitleColor,
                  ),
                ),
                const SizedBox(width: 8),
                _pricePill(
                  price: price,
                  bgColor: isSelected ? green : unselectedPriceBgColor,
                  textColor: isSelected
                      ? Colors.white
                      : unselectedPriceTextColor,
                  borderColor: isSelected
                      ? Colors.transparent
                      : unselectedPriceBorderColor,
                  shadow: isSelected,
                ),
              ],
            ),
          ),

          if (hasBadge)
            Positioned(
              top: -14,
              left: 34,
              child: Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _planText({
    required String title,
    required String subtitle,
    Color subtitleColor = muted,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _pricePill({
    required String price,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    bool shadow = false,
  }) {
    return Container(
      height: 34,
      constraints: const BoxConstraints(minWidth: 68, maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .17),
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          price,
          maxLines: 1,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 27, 26, 27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.mic,
            iconBg: const Color(0xFFEAF5E4),
            iconColor: green,
            title: 'gen_voice_minutes'.tr,
            desc:
                'Consumed during live conversation\nsessions with your AI Speaking Partner.',
          ),
          const SizedBox(height: 22),
          _infoRow(
            icon: Icons.chat_bubble,
            iconBg: const Color(0xFFE9F5FF),
            iconColor: const Color(0xFF006BAA),
            title: 'gen_text_tokens'.tr,
            desc:
                'Used for text based chat, grammar\ncorrections, and writing feedback.',
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                desc,
                style: const TextStyle(
                  color: Color(0xFF414650),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _badgeText(String badge) {
    switch (badge.trim().toLowerCase()) {
      case 'most_popular':
        return 'most_popular'.tr;

      case 'best_value':
        return 'best_value'.tr;

      case 'limited_time':
        return 'limited_time'.tr;

      default:
        return '';
    }
  }
}
