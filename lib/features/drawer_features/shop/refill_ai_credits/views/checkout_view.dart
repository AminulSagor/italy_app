import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/themes/app_colors.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
import 'package:italir_pothe/core/widgets/widgets.dart';
import '../../shop_controller.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  static const Color _bg = AppColors.scaffoldBackground;
  static const Color _green = AppColors.primaryGreen;
  static const Color _darkGreen = AppColors.primaryBtnShadow;
  static const Color _textDark = AppColors.black;
  static const Color _bodyText = AppColors.bodyText;
  static const Color _softGray = Color(0xFFF0F1F1);
  static const Color _tabGray = Color(0xFFE1E3E3);

  @override
  Widget build(BuildContext context) {
    final ShopController controller = Get.find<ShopController>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: SimpleAppbar(
        onBackTap: () => Navigator.maybePop(context),
        title: 'Checkout',
        icon: Icons.arrow_back,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 44),
            // _CheckoutHeader(onBackTap: () => Navigator.maybePop(context)),
            const SizedBox(height: 28),
            Obx(
              () => _CurrencySelector(
                selectedCurrency: controller.selectedCurrency.value,
                onChanged: controller.selectCurrency,
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => _OrderSummaryCard(
                title: controller.selectedPlanTitle,
                subtitle: controller.selectedPlanSubtitle,
                payableAmount: controller.checkoutPayablePriceText,
                originalAmount: controller.checkoutOriginalPriceText,
                savedAmount: controller.checkoutSavedAmountText,
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                color: _bodyText,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.15,
              ),
            ),
            const SizedBox(height: 18),
            Obx(
              () => Column(
                children: controller.availablePaymentMethods
                    .map(
                      (method) => Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: _PaymentMethodPill(
                          method: method,
                          isSelected: controller.isPaymentMethodSelected(
                            method,
                          ),
                          onTap: () => controller.selectPaymentMethod(method),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => CustomButton.primary(
                text: controller.isCheckoutLoading.value
                    ? 'Processing...'
                    : 'Complete Purchase',
                onPressed: controller.isCheckoutLoading.value
                    ? () {}
                    : controller.goToPurchaseCompleted,
                btnColor: controller.isCheckoutLoading.value
                    ? AppColors.bodyText
                    : _green,
                btnShadowColor: controller.isCheckoutLoading.value
                    ? AppColors.bodyText
                    : _darkGreen,
                borderRadius: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 13, color: _bodyText),
                  SizedBox(width: 7),
                  Text(
                    'SECURE SSL ENCRYPTION',
                    style: TextStyle(
                      color: _bodyText,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => controller.checkoutError.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: Text(
                          controller.checkoutError.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.notificationRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: onBackTap,
              borderRadius: BorderRadius.circular(24),
              child: const SizedBox(
                height: 36,
                width: 36,
                child: Icon(
                  Icons.arrow_back,
                  color: CheckoutPage._green,
                  size: 24,
                ),
              ),
            ),
          ),
          const Text(
            'Checkout',
            style: TextStyle(
              color: CheckoutPage._green,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({
    required this.selectedCurrency,
    required this.onChanged,
  });

  final RefillCurrency selectedCurrency;
  final ValueChanged<RefillCurrency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      //elevation: 0,
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CheckoutPage._tabGray,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CurrencyTab(
              label: 'EUR',
              isSelected: selectedCurrency == RefillCurrency.eur,
              onTap: () => onChanged(RefillCurrency.eur),
            ),
          ),
          Expanded(
            child: _CurrencyTab(
              label: 'BDT',
              isSelected: selectedCurrency == RefillCurrency.bdt,
              onTap: () => onChanged(RefillCurrency.bdt),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyTab extends StatelessWidget {
  const _CurrencyTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? Border.all(color: const Color(0xFFD9DBDB), width: 1.4)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? CheckoutPage._green : CheckoutPage._bodyText,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.title,
    required this.subtitle,
    required this.payableAmount,
    required this.originalAmount,
    required this.savedAmount,
  });

  final String title;
  final String subtitle;
  final String payableAmount;
  final String originalAmount;
  final String savedAmount;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
      //shadowRadius: 10,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(31, 31, 28, 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [Colors.white, Colors.white, Color(0xFFE9FFDF)],
            stops: [0.0, 0.62, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ORDER SUMMARY',
              style: TextStyle(
                color: CheckoutPage._green,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.25,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                color: CheckoutPage._textDark,
                fontSize: 24,
                height: 1.15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.55,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              subtitle,
              style: const TextStyle(
                color: CheckoutPage._bodyText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      payableAmount,
                      maxLines: 1,
                      style: const TextStyle(
                        color: CheckoutPage._textDark,
                        fontSize: 40,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    originalAmount,
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Color(0xFF8E8E8E),
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F3DC),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.redeem_outlined,
                        size: 11,
                        color: CheckoutPage._green,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'YOU SAVED $savedAmount',
                        style: const TextStyle(
                          color: CheckoutPage._green,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '/ one-time',
                  style: TextStyle(
                    color: CheckoutPage._bodyText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodPill extends StatelessWidget {
  const _PaymentMethodPill({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final CheckoutPaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final data = _paymentMethodUi(method);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 96,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : CheckoutPage._softGray,
          borderRadius: BorderRadius.circular(50),
          border: isSelected
              ? Border.all(color: CheckoutPage._green, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            data.icon,
            const SizedBox(height: 9),
            Text(
              data.title,
              style: const TextStyle(
                color: CheckoutPage._bodyText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PaymentMethodUi _paymentMethodUi(CheckoutPaymentMethod method) {
    switch (method) {
      case CheckoutPaymentMethod.card:
        return const _PaymentMethodUi(
          title: 'Card',
          icon: Icon(
            Icons.credit_card_outlined,
            color: CheckoutPage._green,
            size: 30,
          ),
        );
      case CheckoutPaymentMethod.paypal:
        return const _PaymentMethodUi(title: 'PayPal', icon: _PaypalMark());
      case CheckoutPaymentMethod.applePay:
        return const _PaymentMethodUi(
          title: 'Apple Pay',
          icon: Icon(Icons.apple, color: Colors.black, size: 33),
        );
      case CheckoutPaymentMethod.bkash:
        return const _PaymentMethodUi(title: 'Bkash', icon: _BkashMark());
    }
  }
}

class _PaymentMethodUi {
  const _PaymentMethodUi({required this.title, required this.icon});

  final String title;
  final Widget icon;
}

class _PaypalMark extends StatelessWidget {
  const _PaypalMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29,
      width: 29,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Positioned(
            left: 6,
            top: 1,
            child: Text(
              'P',
              style: TextStyle(
                color: Color(0xFF253B80),
                fontSize: 27,
                height: 1,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 3,
            child: Text(
              'P',
              style: TextStyle(
                color: Color(0xFF179BD7),
                fontSize: 24,
                height: 1,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BkashMark extends StatelessWidget {
  const _BkashMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29,
      width: 29,
      child: CustomPaint(painter: _BkashPainter()),
    );
  }
}

class _BkashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = Paint()..color = const Color(0xFFE2136E);
    final darkPink = Paint()..color = const Color(0xFFB90E59);
    final white = Paint()..color = Colors.white;

    final body = Path()
      ..moveTo(size.width * .15, size.height * .14)
      ..lineTo(size.width * .82, size.height * .44)
      ..lineTo(size.width * .36, size.height * .86)
      ..lineTo(size.width * .43, size.height * .54)
      ..close();
    canvas.drawPath(body, pink);

    final wing = Path()
      ..moveTo(size.width * .35, size.height * .08)
      ..lineTo(size.width * .86, size.height * .40)
      ..lineTo(size.width * .57, size.height * .45)
      ..close();
    canvas.drawPath(wing, darkPink);

    final cut = Path()
      ..moveTo(size.width * .34, size.height * .20)
      ..lineTo(size.width * .55, size.height * .44)
      ..lineTo(size.width * .40, size.height * .45)
      ..close();
    canvas.drawPath(cut, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
