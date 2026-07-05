import 'package:get/get.dart';
import 'legal_document_models.dart';

class TermsOfServiceContent {
  TermsOfServiceContent._();

  static const String supportEmail = 'support@lumina.it';

  static LegalDocumentModel document = LegalDocumentModel(
    title: 'gen_terms_of_service'.tr,
    effectiveDate: 'Effective June 27, 2026',
    introduction:
        'These Terms of Service govern your access to and use of Italir Pothe, including the mobile app, learning content, AI Tutor, community features, purchases, and related backend services.',
    sections: <LegalSectionModel>[
      LegalSectionModel(
        title: '1_acceptance_and_eligibility'.tr,
        paragraphs: <String>[
          'By creating an account or using Italir Pothe, you agree to these Terms and the Privacy Policy. If you do not agree, do not use the service.',
          'You must be at least 13 years old. If the law where you live requires a higher age, you may use the service only with permission from a parent or legal guardian who accepts these Terms for you.',
        ],
      ),
      LegalSectionModel(
        title: '2_your_account'.tr,
        bullets: <String>[
          'Provide accurate information and keep your verified email or phone number current.',
          'Protect your password and access codes, and do not share your account.',
          'Notify support promptly if you suspect unauthorized access.',
          'You are responsible for activity performed through your account unless applicable law states otherwise.',
        ],
      ),
      LegalSectionModel(
        title: '3_the_service'.tr,
        paragraphs: <String>[
          'Italir Pothe provides Italian-language courses, practice activities, tests, certificates, AI-assisted learning, guided voice practice, messaging and calls, webinars, CV-building tools, rewards, and digital purchases. Some features may be unavailable by device, language, region, account status, or plan.',
          'We may improve, replace, limit, or discontinue features. We will try to give reasonable notice when a material change significantly affects a paid feature, unless an urgent security, legal, or technical issue requires immediate action.',
        ],
      ),
      LegalSectionModel(
        title: '4_ai_and_educational_limitations'.tr,
        paragraphs: <String>[
          'AI-generated responses, translations, corrections, level estimates, and speech recognition may be incomplete or incorrect. Review important output before relying on it.',
          'Italir Pothe is an educational tool. It does not provide legal, immigration, medical, financial, employment, or other professional advice, and it does not guarantee exam results, language proficiency, employment, residency, or any official outcome.',
        ],
      ),
      LegalSectionModel(
        title: '5_acceptable_use'.tr,
        paragraphs: <String>[
          'You must use the service lawfully and respectfully. You must not:',
        ],
        bullets: <String>[
          'Harass, threaten, exploit, impersonate, or share another person’s private information without permission.',
          'Upload illegal, abusive, deceptive, infringing, sexually exploitative, malicious, or unsafe content.',
          'Record or distribute another person’s voice, video, messages, or personal information without all legally required consent.',
          'Interfere with the app, bypass access controls, probe security, introduce malware, scrape content, or use unauthorized automation.',
          'Manipulate purchases, credits, rewards, exams, referrals, or platform systems.',
          'Use AI or community features to facilitate unlawful activity or violate another person’s rights.',
        ],
      ),
      LegalSectionModel(
        title: '6_user_content_and_permissions'.tr,
        paragraphs: <String>[
          'You keep ownership of content you create and upload, such as messages, recordings, photos, CV information, answers, and reports. You grant Italir Pothe a limited, worldwide, non-exclusive license to host, process, reproduce, transmit, adapt, and display that content only as reasonably necessary to operate, secure, moderate, and improve the service.',
          'You confirm that you have the rights and permissions needed for content you submit. You can remove some content through available app tools or request assistance from support, subject to legal and operational retention requirements.',
        ],
      ),
      LegalSectionModel(
        title: '7_community_calls_and_moderation'.tr,
        paragraphs: <String>[
          'Messages, calls, reports, and community interactions must follow these Terms. We may use automated tools and authorized staff to investigate reports, enforce safety rules, restrict features, remove content, or suspend accounts. Blocking and reporting tools do not replace emergency services.',
        ],
      ),
      LegalSectionModel(
        title: '8_purchases_credits_and_refunds'.tr,
        bullets: <String>[
          'Prices, taxes, currency, package contents, and payment terms are shown before confirmation and may vary by platform or region.',
          'Purchases may be processed by Google Play, Apple, Stripe, or another displayed provider. Their payment and refund rules may also apply.',
          'AI minutes, AI text tokens, CV credits, streak freezes, rewards, and similar digital entitlements are licensed for use inside Italir Pothe. They are personal, non-transferable, not legal tender, and have no cash value unless required by law.',
          'Digital entitlements are granted after payment confirmation. They may be reversed when a payment is refunded, cancelled, charged back, duplicated, fraudulent, or granted in error.',
          'Refund requests are handled under the purchasing platform’s rules, the displayed offer, and mandatory consumer law. Contact support when the platform directs you to the developer.',
        ],
      ),
      LegalSectionModel(
        title: '9_third_party_services_and_links'.tr,
        paragraphs: <String>[
          'The service may use or link to third-party services such as app stores, payment providers, OpenAI, Pipecat, LiveKit, Agora, Firebase, AWS, WhatsApp, Facebook, email, or phone services. Their own terms and privacy policies apply. Italir Pothe is not responsible for third-party content or services outside our control.',
        ],
      ),
      LegalSectionModel(
        title: '10_intellectual_property'.tr,
        paragraphs: <String>[
          'The app, software, designs, lessons, branding, and service content are owned by Italir Pothe or its licensors and are protected by applicable intellectual-property laws. We give you a limited, revocable, non-exclusive, non-transferable license to use the service for personal learning. You may not copy, sell, redistribute, or create unauthorized derivative works from protected service content.',
        ],
      ),
      LegalSectionModel(
        title: '11_privacy'.tr,
        paragraphs: <String>[
          'Our Privacy Policy explains how information is collected and handled. By using the service, you acknowledge that policy and any permission or consent prompts presented for particular features.',
        ],
      ),
      LegalSectionModel(
        title: '12_suspension_termination_and_deletion'.tr,
        paragraphs: <String>[
          'You may stop using the service at any time and can initiate account deletion from Settings. We may warn, limit, suspend, or terminate access when reasonably necessary for security, fraud prevention, non-payment, legal compliance, serious or repeated violations, or protection of users and the service.',
          'Terms that by their nature should continue after termination—including ownership, payment obligations, permitted retention, disclaimers, and liability limits—remain effective.',
        ],
      ),
      LegalSectionModel(
        title: '13_availability_and_disclaimers'.tr,
        paragraphs: <String>[
          'We work to provide a reliable service, but availability may be interrupted by maintenance, network conditions, provider outages, device limitations, or events outside our control. To the extent permitted by law, the service is provided “as is” and “as available” without warranties that it will always be uninterrupted, error-free, or suitable for every purpose.',
          'Nothing in these Terms excludes warranties or consumer rights that cannot legally be excluded.',
        ],
      ),
      LegalSectionModel(
        title: '14_limitation_of_liability'.tr,
        paragraphs: <String>[
          'To the maximum extent permitted by law, Italir Pothe and its providers are not liable for indirect, incidental, special, consequential, or punitive loss, or for lost data, profit, opportunity, or reputation arising from use of the service. Any liability that cannot be excluded is limited only to the extent allowed by applicable law. Mandatory consumer protections remain unaffected.',
        ],
      ),
      LegalSectionModel(
        title: '15_changes_to_these_terms'.tr,
        paragraphs: <String>[
          'We may update these Terms to reflect changes in the service, providers, law, or safety requirements. We will update the effective date and provide additional notice for material changes when required. If you continue using the service after revised Terms take effect, you accept them; where law requires separate consent, we will request it.',
        ],
      ),
      LegalSectionModel(
        title: '16_applicable_law_and_disputes'.tr,
        paragraphs: <String>[
          'These Terms are governed by applicable law. Any dispute will be handled by a court or process with lawful jurisdiction, while preserving any mandatory rights or venue protections available to consumers in their country of residence.',
        ],
      ),
      LegalSectionModel(
        title: '17_contact'.tr,
        paragraphs: <String>[
          'Questions about these Terms may be sent to $supportEmail.',
        ],
      ),
    ],
  );
}
