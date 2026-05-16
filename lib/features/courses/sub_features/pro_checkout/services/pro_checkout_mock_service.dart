import '../models/pro_checkout_models.dart';

class ProCheckoutMockService {
  Future<ProOrderModel> fetchOrderSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));

    return ProOrderModel.fromJson(<String, dynamic>{
      'appName': 'Italian Shikhi',
      'headline': 'Unlock your Italian\nfuture!',
      'description': 'You’ve finished the free trial. Join\n5,000+ students mastering Italian.',
      'trustedLabel': 'TRUSTED BY 5K+ LEARNERS',
      'plan': <String, dynamic>{
        'title': 'Lifetime Access',
        'subtitle': 'Pay once, learn forever',
        'eurPrice': '€29.99',
        'eurOldPrice': '€89.99',
        'bdtPrice': '৳4315',
        'bdtOldPrice': '৳12,949',
        'discountLabel': '66% OFF',
        'couponCode': 'WELCOME10',
        'couponEurPrice': '€19.99',
        'couponSaveLabel': 'YOU SAVE €10.00',
      },
      'features': <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'All 30+\nChapters',
          'iconName': 'school',
          'tone': 'green',
        },
        <String, dynamic>{
          'title': 'Unlimited AI\nSpeaking',
          'iconName': 'smart_toy',
          'tone': 'orange',
        },
        <String, dynamic>{
          'title': 'Theory Books',
          'iconName': 'description',
          'tone': 'blue',
        },
        <String, dynamic>{
          'title': 'Official Course\nCertificate',
          'iconName': 'workspace_premium',
          'tone': 'purple',
        },
      ],
    });
  }

  Future<void> applyCoupon(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
  }

  Future<ProPurchaseResultModel> completePurchase({
    required ProCurrency currency,
    required ProPaymentMethod paymentMethod,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    return ProPurchaseResultModel.fromJson(<String, dynamic>{
      'orderId': '#IT-SHK-1024',
      'statusLabel': 'Status: Completed',
      'title': 'Congratulations!',
      'description': 'You now have full lifetime access to all\nItalian Shikhi features. Your journey to\nfluency starts today.',
      'buttonLabel': 'Start Learning Now',
    });
  }
}
