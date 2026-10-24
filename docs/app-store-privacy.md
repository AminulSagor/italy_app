# App Store privacy answers

Last audited: 2026-10-24

These answers cover the iOS app and the third-party SDKs included in its archive. Keep them synchronized with `ios/Runner/PrivacyInfo.xcprivacy` and the public privacy policy whenever data handling or SDKs change.

## Tracking

- **Does this app use data for tracking?** No.
- Do not select any data type as used for tracking.
- The app disables Meta automatic event logging and advertiser-ID collection in `ios/Runner/Info.plist`, and Facebook authentication uses Limited Login on iOS.
- Do not add an App Tracking Transparency prompt while those settings and behavior remain unchanged.

The Meta SDK privacy manifest describes tracking-capable behavior and may therefore appear in Xcode's generated privacy report. That does not change the app's answer when those features are disabled. Re-audit this answer before enabling Meta standard login, advertiser ID collection, automatic app events, advertising measurement, or cross-app data matching.

## Data collected and App Store Connect selections

For each row below, select the data type, all listed purposes, the linked status, and **No** for tracking.

| App Store Connect data type | Purposes | Linked to identity |
| --- | --- | --- |
| Name | App Functionality; Product Personalization | Yes |
| Email Address | App Functionality | Yes |
| Phone Number | App Functionality | Yes |
| Physical Address | App Functionality | Yes |
| Coarse Location | App Functionality | Yes |
| Emails or Text Messages | App Functionality | Yes |
| Photos or Videos | App Functionality | Yes |
| Audio Data | App Functionality; Product Personalization | Yes |
| Customer Support | App Functionality | Yes |
| Other User Content | App Functionality; Product Personalization | Yes |
| User ID | App Functionality; Product Personalization; Analytics | Yes |
| Device ID | App Functionality; Analytics | Yes |
| Purchase History | App Functionality; Analytics | Yes |
| Product Interaction | App Functionality; Product Personalization; Analytics | Yes |
| Other Usage Data | App Functionality; Product Personalization; Analytics | Yes |
| Crash Data | App Functionality | No |
| Other Diagnostic Data | App Functionality; Analytics | Yes |
| Other Data Types | App Functionality; Analytics | Yes |

Do not select Payment Info when payment details are entered into Apple's purchase sheet and the developer never receives the payment credentials. Purchase History is still collected because the backend stores purchases and entitlements.

Do not select Precise Location, Contacts, Health, Fitness, Browsing History, Advertising Data, or Sensitive Info based on the current implementation. Generic CV fields, documents, AI prompts, transcripts, and exam responses are represented by Other User Content. Retained voice recordings are represented by Audio Data.

Live audio/video that is only transmitted to service a call and not retained does not independently count as collection. Stored message attachments, uploaded photos/videos, recordings, and transcripts do count and are declared above.

## Third-party AI disclosure and permission

- On iOS, AI Tutor voice connects directly to Google Gemini for live tutoring, transcripts, session summaries, and language-level evaluation. The iOS AI voice path does not use Pipecat or LiveKit, and the backend rejects the legacy transport for authenticated iOS sessions.
- OpenAI remains in use on iOS for AI Tutor text responses, level-test transcription, language and speech processing, and AI-assisted CV features involving CV text, selected documents or images, and generated or edited content.
- The published legacy Android voice path remains available through Pipecat and may use LiveKit transport plus OpenAI speech recognition, language processing, and speech generation. This Android-only disclosure must remain in the cross-platform privacy policy.
- The app must obtain current, explicit AI data-sharing permission before the backend permits any endpoint that sends data to these providers.
- Users can decline without losing non-AI functionality and can withdraw permission under Settings → AI data sharing.
- Withdrawal immediately stops microphone capture, playback, and the provider socket on that device. The backend invalidates account voice sessions and requests Pipecat worker shutdown. Other signed-in devices revalidate consent every 10 seconds while voice is active; a direct Gemini socket cannot be revoked provider-side by the backend, so cross-device shutdown is bounded by that check rather than claimed as instantaneous.
- UGC moderation uses the server-local keyword filter by default; direct messages and webinar chat are not sent to the OpenAI moderation helper without separate permission.
- Permanent account deletion queues eligible user-owned S3 objects, incomplete or not-yet-confirmed uploads, generated CV assets, and Resume Studio output for durable deletion with automatic retry. Files still shared with other users and narrowly retained report, certificate, or service-record evidence are preserved without retaining ownership by the deleted account.

## SDK audit summary

- Agora RTC: no collected data declared; required-reason APIs for boot time, file timestamps, and disk space are supplied by the SDK manifest.
- Google Sign-In: declares name, email, phone, coarse location, user ID, device ID, other usage data, and other data types. These are covered above.
- Firebase Messaging: declares device ID, other diagnostic data, and other data types. These are covered above.
- Firebase Crashlytics: declares crash data and other diagnostic data. These are covered above; Crashlytics collection is enabled only for release builds.
- Meta/Facebook Login: tracking-capable declarations exist inside the SDK, but app-level advertiser-ID collection and automatic events are disabled and iOS uses Limited Login.

## Release check

1. Archive the exact release build in Xcode.
2. In Organizer, select the archive and generate its Privacy Report.
3. Confirm the app manifest is present, tracking is false at app level, and no newly added SDK introduces undeclared data or required-reason APIs.
4. Enter or update the table above in App Store Connect under **App Privacy**, then click **Publish**.
5. Recheck after every SDK upgrade or when adding analytics, ads, marketing attribution, new uploads, or a new data-retention path.
