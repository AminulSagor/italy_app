import 'legal_document_models.dart';

class PrivacyPolicyContent {
  PrivacyPolicyContent._();

  static const String supportEmail = 'support@lumina.it';

  static const LegalDocumentModel document = LegalDocumentModel(
    title: 'Privacy Policy',
    effectiveDate: 'Effective June 27, 2026',
    introduction:
        'This Privacy Policy explains how Italir Pothe collects, uses, stores, and shares information when you use the mobile application, its backend services, and related support or administrative services.',
    sections: <LegalSectionModel>[
      LegalSectionModel(
        title: '1. Who this policy applies to',
        paragraphs: <String>[
          'This policy applies to learners, community members, and other users of Italir Pothe. By using the service, you acknowledge the practices described here. Where consent is required by law, we request it before collecting or using the relevant data.',
        ],
      ),
      LegalSectionModel(
        title: '2. Information we collect',
        paragraphs: <String>[
          'We collect only information reasonably needed to provide, secure, personalize, and improve the service.',
        ],
        bullets: <String>[
          'Account and profile information: full name, email address or phone number, password hash, verification status, profile photo, and account identifiers.',
          'Learning information: course enrollment and progress, lessons, quiz and exam answers, scores, certificates, streaks, XP, saved learning items, AI Tutor level results, strengths, and focus areas.',
          'Content and communications: messages, attachments, CV details and generated documents, reports, support requests, and information you intentionally provide in AI Tutor conversations.',
          'Audio, video, and media: microphone audio and transcripts used for AI voice chat, speaking tests, speaking exams, calls, and webinars; photos or files you choose to upload; and camera input only when you choose a camera-based feature.',
          'Purchase and entitlement information: order number, purchased package or course, price, currency, discounts, payment provider, payment status, refunds, and resulting balances such as AI minutes, text tokens, CV credits, or streak freezes.',
          'Device and technical information: device identifier, platform, app version, timezone, app state, push-notification tokens, IP address, request logs, crash or diagnostic information, and security events.',
          'Safety and moderation information: blocks, reports, uploaded evidence, moderation decisions, and records needed to prevent abuse or protect users.',
        ],
      ),
      LegalSectionModel(
        title: '3. Device permissions',
        paragraphs: <String>[
          'Depending on the feature you use, the app may request microphone, camera or photo access, notifications, network access, and limited file access. You can deny or later revoke optional permissions in your device settings, although the related feature may stop working.',
          'The current app does not request access to your precise device location or address book contacts.',
        ],
      ),
      LegalSectionModel(
        title: '4. How we use information',
        bullets: <String>[
          'Create, verify, authenticate, and maintain your account.',
          'Deliver courses, practice activities, exams, certificates, CV tools, webinars, messaging, calls, notifications, rewards, purchases, and customer support.',
          'Personalize lessons and AI Tutor responses using your level, recent context, mistakes, and learning progress.',
          'Process orders, grant purchased digital entitlements, prevent duplicate transactions, and handle refunds or disputes.',
          'Operate, troubleshoot, secure, moderate, and improve the app and backend.',
          'Comply with legal obligations, enforce our Terms, and protect users, Italir Pothe, and the public.',
        ],
      ),
      LegalSectionModel(
        title: '5. AI Tutor and voice processing',
        paragraphs: <String>[
          'AI Tutor text, voice, writing-help, and level-test requests may be sent to AI, speech-to-text, text-to-speech, and real-time communication providers so they can generate a response. This can include your prompt, recent conversation context, selected learning topic, learner level, audio, and transcript.',
          'Live AI audio is generally processed as a stream. Some speaking-exam recordings, uploaded files, transcripts, level results, or conversation context may be stored when required to provide the feature. Do not submit highly sensitive information that is not needed for language learning.',
        ],
      ),
      LegalSectionModel(
        title: '6. When information is shared',
        paragraphs: <String>[
          'We do not sell personal information. The current version does not use personal information for cross-app behavioral advertising or tracking.',
          'We may share limited information with service providers only as needed to operate the service, including:',
        ],
        bullets: <String>[
          'Cloud hosting, database, file-storage, and email providers, including AWS-based services where configured.',
          'Firebase for push notifications and device delivery.',
          'OpenAI, Pipecat, and LiveKit for AI, transcription, speech, and real-time AI sessions.',
          'Agora for user calls and live webinar communication.',
          'Google Play, Apple, Stripe, or another configured payment provider for purchases, verification, refunds, and fraud prevention.',
          'Authorized administrators, moderators, or support staff who need access to provide support, manage content, or investigate safety issues.',
          'Authorities or other parties when required by law, necessary to protect rights or safety, or involved in a business transfer subject to appropriate safeguards.',
        ],
      ),
      LegalSectionModel(
        title: '7. Data retention and account deletion',
        paragraphs: <String>[
          'We keep account and service data while your account is active and for as long as reasonably necessary for the purposes described in this policy. Retention periods vary by data type, operational need, legal obligations, fraud prevention, payment disputes, and backup cycles.',
          'You can initiate account deletion in Settings → Privacy & Legal → Delete Account. The app asks you to confirm using your full name. Account access is disabled and direct profile identifiers are removed or anonymized. Associated personal data is deleted or de-identified according to our operational retention process, except records we must retain for legal, accounting, security, fraud-prevention, or dispute-resolution reasons.',
          'You may also request deletion or ask about retained data by contacting support. Backup copies may remain for a limited period before being overwritten and are not used for ordinary product activity.',
        ],
      ),
      LegalSectionModel(
        title: '8. Your choices and rights',
        bullets: <String>[
          'Review or update your name, profile photo, verified email, verified phone, and password from Settings, subject to verification requirements.',
          'Control microphone, camera, photo, and notification permissions through your device settings.',
          'Block users and use available reporting or moderation tools.',
          'Request access, correction, deletion, restriction, or a copy of your personal data where applicable law provides those rights.',
          'Withdraw consent for optional processing without affecting processing already lawfully completed.',
        ],
      ),
      LegalSectionModel(
        title: '9. Security',
        paragraphs: <String>[
          'We use reasonable administrative, technical, and organizational safeguards, including authenticated APIs, password hashing, access controls, secure token storage, and encrypted network connections in production. No service can guarantee absolute security, so keep your password private and contact us if you suspect unauthorized access.',
        ],
      ),
      LegalSectionModel(
        title: '10. International processing',
        paragraphs: <String>[
          'Our service providers may process information in countries other than your own. Where required, we use appropriate contractual, technical, or legal safeguards for international transfers.',
        ],
      ),
      LegalSectionModel(
        title: '11. Children',
        paragraphs: <String>[
          'Italir Pothe is not directed to children under 13. If the law where you live requires a higher minimum age, you may use the service only with valid permission from a parent or legal guardian. Contact us if you believe a child provided personal information without appropriate authorization.',
        ],
      ),
      LegalSectionModel(
        title: '12. Policy updates',
        paragraphs: <String>[
          'We may update this policy when features, providers, or legal requirements change. We will update the effective date and provide additional notice when a change is material. Continued use after the change takes effect means the updated policy applies, subject to any consent rights required by law.',
        ],
      ),
      LegalSectionModel(
        title: '13. Contact us',
        paragraphs: <String>[
          'For privacy questions, requests, or complaints, contact $supportEmail. Please include the email address or phone number connected to your account so we can securely verify and respond to your request.',
        ],
      ),
    ],
  );
}
