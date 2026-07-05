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
                                  isPopular: package.badgeLabel.isNotEmpty,
                                  isSelected: controller.isAiPackageSelected(
                                    package.id,
                                  ),
                                  onTap: () => controller.selectAiPackage(
                                    package.id,
                                  ),
                                  unselectedBgColor:
                                      warmCard ? paleOrange : Colors.white,
                                  unselectedBorderColor: warmCard
                                      ? const Color(0xFFFFEBC0)
                                      : const Color(0xFFEDEDED),
                                  unselectedSubtitleColor:
                                      warmCard ? orange : muted,
                                  unselectedPriceBgColor: warmCard
                                      ? Colors.white
                                      : const Color(0xFFE8E6E6),
                                  unselectedPriceTextColor:
                                      warmCard ? orange : const Color(0xFF3A3434),
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
                  onPressed: controller.isLoadingQuote.value ||
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
              label: '${controller.aiVoiceMinutes} Mins',
              color: green,
            ),
          ),
          Container(height: 34, width: 1, color: const Color(0xFFE7E7E7)),
          Expanded(
            child: _statItem(
              icon: Symbols.deployed_code,
              label: '${controller.aiTextTokens} Tokens',
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
      height: 149,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(42),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF287A04), Color(0xFF176700)],
        ),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: .25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 32,
            top: 31,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ai_mastery'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.1,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Voice for speaking,\nTokens for chatting.',
                  style: TextStyle(
                    color: Color(0xFFD5E5CC),
                    fontSize: 17,
                    height: 1.28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -8,
            top: 22,
            child: Icon(
              Icons.forum_rounded,
              size: 126,
              color: Colors.white.withValues(alpha: .24),
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
    bool isPopular = false,
    Color unselectedBgColor = Colors.white,
    Color unselectedBorderColor = const Color(0xFFEDEDED),
    Color unselectedSubtitleColor = muted,
    Color unselectedPriceBgColor = const Color(0xFFE8E6E6),
    Color unselectedPriceTextColor = const Color(0xFF3A3434),
    Color unselectedPriceBorderColor = Colors.transparent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: isPopular ? 123 : 102,
            padding: const EdgeInsets.symmetric(horizontal: 26),
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

          if (isPopular)
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
                    'most_popular'.tr,
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 15,
            height: 1.35,
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
      height: 40,
      width: 90,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .17),
                  blurRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          price,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
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
}
