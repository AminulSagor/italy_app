import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/themes/app_colors.dart';

const String appPrivacyPolicyUrl = 'https://www.italirpothe.com/privacy-policy';
const String appleStandardEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const String platformTermsAndConditionsUrl =
    'https://www.italirpothe.com/terms-and-conditions';

Uri subscriptionTermsOfUseUri(TargetPlatform platform) => Uri.parse(
  platform == TargetPlatform.iOS
      ? appleStandardEulaUrl
      : platformTermsAndConditionsUrl,
);

class AppStoreSubscriptionDisclosure extends StatelessWidget {
  const AppStoreSubscriptionDisclosure({
    super.key,
    required this.title,
    required this.price,
    required this.billingDuration,
    required this.isRestoring,
    required this.onRestore,
    this.isAutoRenewing = true,
  });

  static final Uri _privacyPolicy = Uri.parse(appPrivacyPolicyUrl);
  static final Uri _manageSubscriptions = Uri.parse(
    'https://apps.apple.com/account/subscriptions',
  );

  final String title;
  final String price;
  final String billingDuration;
  final bool isRestoring;
  final Future<void> Function() onRestore;
  final bool isAutoRenewing;

  Future<void> _open(Uri uri) async {
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      Get.snackbar('unable_to_open_link'.tr, 'try_again_later'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color green = AppColors.primaryGreen;
    const Color text = AppColors.black;
    const Color muted = AppColors.bodyText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E5E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            (isAutoRenewing ? 'subscription_details' : 'course_access_details')
                .tr,
            style: const TextStyle(
              color: text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            label:
                (isAutoRenewing ? 'subscription_title' : 'course_access_title')
                    .tr,
            value: title,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: 'subscription_price'.tr,
            value: price.isEmpty ? 'loading_app_store_price'.tr : price,
          ),
          const SizedBox(height: 10),
          _DetailRow(label: 'billing_duration'.tr, value: billingDuration),
          const SizedBox(height: 16),
          Text(
            (isAutoRenewing
                    ? 'apple_subscription_renewal_disclosure'
                    : 'apple_non_renewing_subscription_disclosure')
                .trParams(<String, String>{
                  'price': price.isEmpty ? 'loading_app_store_price'.tr : price,
                  'duration': billingDuration,
                }),
            style: const TextStyle(
              color: muted,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isAutoRenewing) ...<Widget>[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _open(_manageSubscriptions),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'apple_subscription_cancellation'.tr,
                  style: const TextStyle(
                    color: green,
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 2,
            children: <Widget>[
              Text(
                (isAutoRenewing
                        ? 'subscription_agreement_prefix'
                        : 'purchase_agreement_prefix')
                    .tr,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _LegalLink(
                label: 'privacy_policy'.tr,
                onTap: () => _open(_privacyPolicy),
              ),
              Text(
                'terms_join'.tr,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              _LegalLink(
                label:
                    (defaultTargetPlatform == TargetPlatform.iOS
                            ? 'Terms of Use (EULA)'
                            : 'terms_and_conditions')
                        .tr,
                onTap: () =>
                    _open(subscriptionTermsOfUseUri(defaultTargetPlatform)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: isRestoring ? null : onRestore,
              icon: isRestoring
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restore_rounded, size: 19),
              label: Text(
                isRestoring ? 'restoring_purchases'.tr : 'restore_purchases'.tr,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.bodyText,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
