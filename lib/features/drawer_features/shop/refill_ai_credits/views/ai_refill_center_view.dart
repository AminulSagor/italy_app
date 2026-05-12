import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/themes/app_colors.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
import 'package:italir_pothe/core/widgets/simple_appbar.dart';

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
        title: 'AI Refill Center',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _topStats(),
                    const SizedBox(height: 24),
                    _heroCard(),
                    const SizedBox(height: 24),

                    Obx(
                      () => _selectablePlanCard(
                        title: 'Basic Starter',
                        subtitle: '15 Mins Voice | 1,000 Tokens',
                        price: '€2.49',
                        isSelected: controller.isSelected(AiRefillPlan.basic),
                        onTap: () => controller.selectPlan(AiRefillPlan.basic),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Obx(
                      () => _selectablePlanCard(
                        title: 'Fluent Learner',
                        subtitle: '60 Mins Voice | 5,000\nTokens',
                        price: '€6.99',
                        isPopular: true,
                        isSelected: controller.isSelected(AiRefillPlan.fluent),
                        onTap: () => controller.selectPlan(AiRefillPlan.fluent),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Obx(
                      () => _selectablePlanCard(
                        title: 'Elite Mastery',
                        subtitle: '180 Mins | 15,000 Tokens',
                        price: '€14.99',
                        isSelected: controller.isSelected(AiRefillPlan.elite),
                        onTap: () => controller.selectPlan(AiRefillPlan.elite),
                        unselectedBgColor: paleOrange,
                        unselectedBorderColor: const Color(0xFFFFEBC0),
                        unselectedSubtitleColor: orange,
                        unselectedPriceBgColor: Colors.white,
                        unselectedPriceTextColor: orange,
                        unselectedPriceBorderColor: const Color(0xFFF8D564),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _infoCard(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: CustomButton.primary(
                text: 'Confirm Purchase  ▶',
                onPressed: controller.confirmPurchase,
                btnColor: green,
                borderRadius: 30,
                btnShadowColor: darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topStats() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(icon: Icons.mic, label: '12 Mins', color: green),
          ),
          Container(height: 34, width: 1, color: const Color(0xFFE7E7E7)),
          Expanded(
            child: _statItem(
              icon: Icons.inventory_2_outlined,
              label: '1,200 Tokens',
              color: orange,
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
            color: green.withOpacity(.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 32,
            top: 31,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Mastery',
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
              color: Colors.white.withOpacity(.24),
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
                        color: Colors.black.withOpacity(.10),
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
                child: const Center(
                  child: Text(
                    'MOST POPULAR',
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
                  color: Colors.black.withOpacity(.17),
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
            color: Colors.black.withOpacity(.04),
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
            title: 'Voice Minutes',
            desc:
                'Consumed during live conversation\nsessions with your AI Speaking Partner.',
          ),
          const SizedBox(height: 22),
          _infoRow(
            icon: Icons.chat_bubble,
            iconBg: const Color(0xFFE9F5FF),
            iconColor: const Color(0xFF006BAA),
            title: 'Text Tokens',
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
