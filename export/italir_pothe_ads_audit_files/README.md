# Italir Pothe ads audit — related source files

This archive contains the project files directly referenced in the ads placement and compliance report. Paths are preserved relative to the Flutter project root.

## Included files

- `pubspec.yaml` — confirms the current dependency set and absence of a mobile ads SDK.
- `android/app/src/main/AndroidManifest.xml` — current advertising-ID and Privacy Sandbox permission removals.
- `ios/Runner/PrivacyInfo.xcprivacy` — current iOS privacy and tracking declarations.
- `lib/core/models/current_user_summary.dart` — current global user state, which lacks a persistent ever-paid/ad-free entitlement.
- `lib/core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_view.dart` — five-tab application shell and bottom navigation context.
- `lib/features/home/views/home_view.dart` — Home feed and proposed end-of-feed placement context.
- `lib/features/practice_hub/views/practice_hub_view.dart` — Practice Hub sections and proposed section-boundary placement context.
- `lib/features/practice_hub/sub_features/course_catalog/views/course_catalog_view.dart` — course list and primary proposed native placement context.
- `lib/features/courses/sub_features/quiz/views/quiz_completion_view.dart` — quiz result flow cited as a no-ad zone.
- `lib/features/ai_chat/controllers/ai_chat_controller.dart` — AI credit exhaustion behavior cited when rejecting rewarded ads.

No source code was changed as part of the audit or export.
