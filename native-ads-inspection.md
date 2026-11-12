# Native Ads Inspection

Inspection date: 2026-11-07  
Scope: inspection only; no Flutter, NestJS, admin, dependency, or mediation configuration was changed.

## Summary

- Approved placements inspected: **17**
- **CONFIRMED:** 16
- **UNCERTAIN:** 1 (#10 Survival Italian)
- **NOT FOUND:** 0
- Flutter repository: `/Users/air/Desktop/mine/apps/italy_app`
- Backend repository located and inspected at: `/Users/air/Desktop/mine/backend/italir-pothe-backend`

The placement screens, their controllers, and viable non-obstructive insertion points all exist. Placement #10 is the only mapping that needs a product/ordering decision before implementation because the screen does not render one linear situation list.

## Placement map

Line numbers refer to the inspected working tree on 2026-11-07.

| # | Feature | View File | Widget | Line | Insertion Point | Confidence |
|---:|---|---|---|---:|---|---|
| 2 | Free Course Video — 60% | `lib/features/courses/sub_features/chapter_detail/views/chapter_detail_view.dart` | `ChapterDetailView` / `ChapterVideoCard` | 120 | In the page `Column`, immediately after `ChapterVideoCard` and its spacing. Trigger from `recordVideoProgress` when a free lesson crosses the backend-configured percentage; render below, never inside/over the player. | CONFIRMED |
| 3 | Free Course Video — completed | `lib/features/courses/sub_features/chapter_detail/views/chapter_detail_view.dart` | `ChapterDetailView` / `ChapterVideoCard` | 120 | Same safe page region below the video, with a distinct completion slot/state triggered by the 100% callback. It must not overlay the player or controls. | CONFIRMED |
| 4 | Course Catalog | `lib/features/practice_hub/sub_features/course_catalog/views/course_catalog_view.dart` | `CourseCatalogView` | 77 | In `ListView.separated.itemBuilder`, emit a full-width ad after source course index 2 (the third course) without inserting into `controller.courses`. | CONFIRMED |
| 5 | Practice Hub | `lib/features/practice_hub/views/practice_hub_view.dart` | `PracticeHubView` | 110 | After `PracticeHubSkillBuilderGrid` and its trailing spacing, before the final-exam/specialized-learning section. | CONFIRMED |
| 6 | Home | `lib/features/home/views/home_view.dart` | `HomeView` / `_HomeDashboardContent` | 285 | Immediately after `DailyChallengesCard`, at the end of the dashboard content `Column`. | CONFIRMED |
| 7 | Course Detail | `lib/features/courses/views/course_detail_view.dart` | `CourseDetailView` | 170 | In the chapters `SliverList` builder, after source chapter index 2 (third lesson). Preserve chapter indexes passed to `openChapter`. | CONFIRMED |
| 8 | Career Tracks List | `lib/features/practice_hub/views/job_sentences/job_sentences_view.dart` | `JobSentencesView` / `_CareerTrackList` | 131 | Build mixed children from `careerTracks` and place a full-width ad after source track index 1 (second track), outside `_CareerTrackCard`. | CONFIRMED |
| 9 | AI Tutor Landing | `lib/features/ai_chat/ai_chat_view.dart` | `AiChatView` | 81 | At the bottom of the AI tab landing `Column`, after `AiProTipCard` and before the page's bottom padding. | CONFIRMED |
| 10 | Survival Italian List | `lib/features/practice_hub/views/survival_italian/survival_italian_view.dart` | `SurvivalItalianView` | 82 | Intended after the fourth rendered situation, but the view splits items into one hero, a two-column normal grid, and wide cards. Backend order and rendered grouping can diverge, and a full-width ad after item four can split a grid row. Define counting/order first, then use mixed slivers or split the grid at a row boundary. | UNCERTAIN |
| 14 | Career Track Detail | `lib/features/practice_hub/views/job_sentences/job_details_view.dart` | `JobDetailsView` / `_CareerTrackContent` | 112 | Suitable non-obstructive fixed point after `_TrackProgressCard`, before the module grid. This is outside the intro video and module cards. | CONFIRMED |
| 16 | Career Track Sentences | `lib/features/practice_hub/views/job_sentences/job_phrase_details_view.dart` | `JobPhraseDetailsScreen` / `_PhraseList` | 230 | Replace the direct `sentences.map` rendering with display children keyed by sentence ID; add ads after source positions 3, 7, 11, ... without changing `controller.sentences`. | CONFIRMED |
| 22 | Important Verbs List | `lib/features/practice_hub/views/important_verbs/important_verbs_view.dart` | `ImportantVerbsView` / `VerbLibraryList` | 83 | Pass an important-verbs placement identity into `VerbLibraryList`; in its item builder (`important_verb_library_widgets.dart:364`) add ads after source positions 1, 5, 9, ... without modifying `verbItems`. | CONFIRMED |
| 23 | Saved Verbs List | `lib/features/practice_hub/views/important_verbs/saved_verbs_view.dart` | `SavedVerbsView` / `VerbLibraryList` | 65 | Pass a saved-verbs placement identity into the shared list; add ads after source positions 1, 5, 9, ... without modifying `savedVerbItems`. | CONFIRMED |
| 26 | Verb Detail Sections | `lib/features/practice_hub/views/important_verbs/verb_details.dart` | `VerbDetailsView` | 133 | In the `details.forms.asMap()` rendering, insert an ad after every third `VerbFormSection` (3, 6, 9, ...). Keep the existing banner after `VerbHeroCard` unchanged. | CONFIRMED |
| 27 | League Showing List | `lib/features/leaderboard/views/leaderboard_view.dart` | `LeaderboardView` / `LeaderboardList` | 136 | In `LeaderboardList` (`leaderboard_list_widgets.dart:298`), add ads after source user positions 3, 7, 11, ... while leaving ranks, search results, podium data, and message actions untouched. | CONFIRMED |
| 28 | Message List | `lib/features/messages/views/messages_view.dart` | `MessagesView` / `_MessagesList` | 316 | In `_MessagesList`'s derived sliver children, add clearly ad-styled rows after source conversation positions 3, 7, 11, ...; do not insert ads into `threads` or make them `MessageThreadCard`s. | CONFIRMED |
| 30 | Vocabulary List | `lib/features/courses/sub_features/vocabulary/views/vocabulary_view.dart` | `VocabularyView` / `_VocabularyListMode` | 468 | In list mode only, add ads after filtered source-card positions 3, 7, 11, ... without changing `filteredCards`, flashcard `currentIndex`, mastery state, or audio order. | CONFIRMED |

## Per-placement behavior and risks

### #2 and #3 — Free Course Video

- Controller: `ChapterDetailController` (`chapter_detail_controller.dart:21`).
- Progress path: `ChapterVideoCard._onVideoTick` calculates percentage and calls `onProgressChanged` (`chapter_video_card.dart:312-362`); `ChapterDetailView` forwards that to `ChapterDetailController.recordVideoProgress` (`chapter_detail_view.dart:111-117`, `chapter_detail_controller.dart:354-411`). Completion is explicitly normalized to 100%.
- Scrolling: one `SingleChildScrollView` controlled by `ChapterDetailController.scrollController`.
- Feasibility: the player is already a discrete child above lesson content. A slot below it is safe and does not cover video or controls.
- Implementation caution: reserve/reveal space below the player so a late load does not resize the video. The 60% and completion placements need separate one-shot state so reaching 100% does not unintentionally stack duplicate requests. Resuming a video already beyond a threshold also needs an explicit policy.
- Recommended layout: small native template below the video with full-width page padding; medium only if it does not push active playback controls off-screen.

### #4 — Course Catalog

- Controller: `CourseCatalogController` (`course_catalog_controller.dart:13`).
- Behavior: searchable, pull-to-refresh, page size 10, infinite loading when `extentAfter < 240`; new pages are deduplicated by course ID (`course_catalog_controller.dart:18-110`, `164-168`).
- Risk: adding ads to `courses` would corrupt pagination and progress updates by index. Use a derived visual-index mapping and stable ad key based on placement plus source boundary.
- Recommended layout: small full-width in-feed template.

### #5 — Practice Hub

- Controller: `PracticeHubController` (`practice_hub_controller.dart:22`).
- Behavior: one `SingleChildScrollView`; skill builders are a fixed section sourced from the overview API; later sections load independently.
- Risk: none if the ad remains a sibling between sections.
- Recommended layout: small or medium full-width section card.

### #6 — Home

- Controller: `HomeController` (`home_controller.dart:21`).
- Behavior: refreshable `SingleChildScrollView`; Daily Challenges is currently the last dashboard section.
- Risk: keep the ad above existing bottom padding/navigation reserve and outside `DailyChallengesCard`'s tap target.
- Recommended layout: small full-width template.

### #7 — Course Detail

- Controller: `CourseDetailController` (`course_detail_controller.dart:15`).
- Behavior: `CustomScrollView` with a lazily built chapter `SliverList`; the current builder already doubles visual indexes to interleave spacing (`course_detail_view.dart:169-181`).
- Risk: extending that arithmetic directly is error-prone. Use a source-index-to-row model or a sliver delegate that treats ads as display rows but always resolves taps from `detail.chapters[sourceIndex]`.
- Recommended layout: small full-width template matching course page padding.

### #8, #14, and #16 — Career Tracks

- Controller: `JobSentencesController` (`job_sentences_controller.dart:18`).
- Track list: non-paginated `Column` inside `SingleChildScrollView`.
- Detail: refreshable `SingleChildScrollView`; optional intro video, progress card, non-scrolling module grid, and theory resource.
- Sentences: server/search result list rendered as a `Column`; searching replaces `sentences` with the returned filtered items.
- Risks: #16 must count the current visible result list but never alter sentence IDs or TTS/review operations. #14 must stay outside `JobIntroVideoCard`.
- Recommended layouts: small in-feed templates for #8/#16; medium or small full-width template for #14.

### #9 — AI Tutor Landing

- Controller: `AiChatController` (`ai_chat_controller.dart:25`).
- Route confirmation: the bottom navigation AI tab renders `AiChatView` (`navbar_and_appbar_wrapper_view.dart:227-231`); `AiTutorDiscoveryView` is a deeper speaking-lab route opened from it (`ai_chat_controller.dart:193-198`).
- Behavior: non-paginated `SingleChildScrollView` with bottom navigation padding.
- Risk: do not place the ad in the discovery/chat `Stack`, where it could collide with the fixed input bar.
- Recommended layout: small full-width template at the bottom of `AiChatView`.

### #10 — Survival Italian

- Controller: `PracticeHubController` (`practice_hub_controller.dart:997-1087`).
- Behavior: the API returns one ordered list, but getters split it by `cardVariant`: hero, normal, and wide. The view renders the hero first, all normal items in a two-column grid, then all wide items.
- Blocker: clarify whether “fourth situation” means backend `sortOrder`/API index or fourth rendered card. Also decide whether the ad may follow the first item of a grid row; the safer default is a full-width ad after a complete row, which may not be exactly after item four.
- Recommended layout: full-width small template between slivers, not inside a situation card or a single grid cell.

### #22 and #23 — Important/Saved Verbs

- Controller: `ImportantVerbsController` (`important_verbs_controller.dart:16`).
- Behavior: both lists share `VerbLibraryList`; each has independent debounced search/filter state and page-10 incremental loading. `NotificationListener` starts the next page near the bottom.
- Risk: the shared widget needs a placement identity so separate ad instances/keys do not leak between lists. Derive display rows from the accumulated source list and never add ad sentinels to the Rx lists.
- Existing ad interaction: verb detail already contains `AdaptiveBannerAdSlot` at `verb_details.dart:65`; it must remain unchanged.
- Recommended layout: small full-width template, visually separate from the large tappable verb cards.

### #26 — Verb Detail Sections

- Controller: `ImportantVerbsController` (`important_verbs_controller.dart:16`; detail load starts at line 430).
- Behavior: `SingleChildScrollView`; repeated detail sections are `details.forms` rendered as `VerbFormSection` cards.
- Risk: count only the repeated form sections. The hero, information card, heading, and existing banner are not part of the 3/6/9 cadence.
- Recommended layout: small full-width template after every third form card.

### #27 — League Showing List

- Controller: `LeaderboardController` (`leaderboard_controller.dart:15`).
- Behavior: searchable `CustomScrollView`; the displayed `filteredUsers` list is server entries (page limit 20) or fallback data. Podium is a separate section. Current code does not append subsequent leaderboard pages.
- Risk: do not use rank values as visual indexes—ranks may start above 3 and search changes the visible list. Count source rows in `filteredUsers`, preserve the rank displayed by each model, and key ads by placement/boundary.
- Recommended layout: small full-width template clearly different from `_LeaderboardUserTile`.

### #28 — Message List

- Controller: `MessagesController` (`messages_controller.dart:15`).
- Behavior: refreshable `CustomScrollView`; `filteredThreads` filters the live Rx list. Socket events update a conversation then move it to index 0; unread/read events mutate the same list (`messages_controller.dart:66-79`, `190-288`). No conversation pagination is present in this client path.
- Risk: never insert an ad object into `threads`; doing so would affect unread totals, presence sync, real-time ordering, and navigation. Recompute visual rows from the current thread list. Give ad rows their own background, explicit “Ad/Advertisement” treatment, and no avatar/unread/time styling.
- Recommended layout: small native template with a distinct border/background and native ad attribution; it must not use `MessageThreadCard`.

### #30 — Vocabulary List

- Controller: `VocabularyController` (`vocabulary_controller.dart:18`).
- Behavior: list and flashcard modes share one session. List mode uses the searchable `filteredCards`; flashcard mode uses `currentIndex`. The list has its own `ListView` inside an `Expanded` region and is not paginated.
- Risk: implement ads only in list mode. Display-row indexes must never feed back into `currentIndex`, learning actions, search, or `playAllVisibleWords`.
- Recommended layout: compact/small template between vocabulary cards.

## Existing eligibility and ad-free integration

The existing Flutter path is reusable:

- `RewardedAdsService` owns an observable `Rxn<RewardedAdsConfiguration>` and fetches authenticated `GET /rewarded-ads/config` (`rewarded_ads_service.dart:28-55`).
- `RewardedAdsConfiguration` parses top-level `adsEnabled` and `isAdFree` (`rewarded_ads_models.dart:18-49`).
- `BannerAdsService.canRequest` requires a known non-null configuration, `adsEnabled == true`, and `isAdFree == false` (`banner_ads_service.dart:34-43`). Thus unknown eligibility already fails closed for banners.
- `AdaptiveBannerAdSlot` listens to eligibility changes, cancels stale loads by generation, and disposes a loaded banner when eligibility becomes false (`adaptive_banner_ad_slot.dart:36-130`). This is the lifecycle pattern Native Ads should follow.
- `MobileAds.instance.initialize()` already runs once during permanent `RewardedAdsService` bootstrap (`rewarded_ads_service.dart:32-41`, `app_bootstrap_controller.dart:74-85`). Native Ads should reuse it.

Backend contract and authority:

- `GET /rewarded-ads/config` is JWT-protected (`rewarded-ads.controller.ts:21-25`).
- It returns `adsEnabled`, `isAdFree`, rewarded intervals, daily challenge data, call state, and CV reward values (`rewarded-ads.service.ts:49-91`).
- The current `isAdFree` implementation returns true for any paid course order or any completed store order (`rewarded-ads.service.ts:306-316`). This is the existing authoritative rule; Native Ads must consume it rather than create purchase verification.

Required Native behavior:

1. Do not request while the configuration is null/unknown.
2. Require global `adsEnabled`, `nativeAds.enabled`, placement enabled, and `!isAdFree`.
3. Observe the shared configuration Rx and immediately invalidate in-flight generations and dispose loaded `NativeAd`s if eligibility changes.
4. On failed refresh, keep the previous authoritative configuration if one exists; a cold-start failure stays ineligible.
5. Do not create rewarded sessions, counters, credits, or SSV records for Native Ads.

## Smallest safe backend contract extension

Extend the existing authenticated response with a sibling `nativeAds` object. Keep existing top-level fields unchanged for backward compatibility.

```json
{
  "adsEnabled": true,
  "isAdFree": false,
  "nativeAds": {
    "enabled": true,
    "placements": {
      "freeVideoProgress": { "enabled": true, "progressPercent": 60 },
      "freeVideoComplete": { "enabled": true },
      "courseCatalog": { "enabled": true, "firstAfter": 3 },
      "practiceHub": { "enabled": true },
      "home": { "enabled": true },
      "courseDetail": { "enabled": true, "firstAfter": 3 },
      "careerTracks": { "enabled": true, "firstAfter": 2 },
      "aiTutorLanding": { "enabled": true },
      "survivalItalian": { "enabled": true, "firstAfter": 4 },
      "careerTrackDetail": { "enabled": true },
      "careerSentences": { "enabled": true, "firstAfter": 3, "interval": 4 },
      "importantVerbs": { "enabled": true, "firstAfter": 1, "interval": 4 },
      "savedVerbs": { "enabled": true, "firstAfter": 1, "interval": 4 },
      "verbDetail": { "enabled": true, "interval": 3 },
      "league": { "enabled": true, "firstAfter": 3, "interval": 4 },
      "messages": { "enabled": true, "firstAfter": 3, "interval": 4 },
      "vocabulary": { "enabled": true, "firstAfter": 3, "interval": 4 }
    }
  }
}
```

All values should be read through the backend's existing `ConfigService` helper style, with validated positive integers and safe defaults. Suggested environment variables:

```dotenv
NATIVE_ADS_ENABLED=true

NATIVE_FREE_VIDEO_PROGRESS_ENABLED=true
NATIVE_FREE_VIDEO_COMPLETE_ENABLED=true
NATIVE_COURSE_CATALOG_ENABLED=true
NATIVE_PRACTICE_HUB_ENABLED=true
NATIVE_HOME_ENABLED=true
NATIVE_COURSE_DETAIL_ENABLED=true
NATIVE_CAREER_TRACKS_ENABLED=true
NATIVE_AI_TUTOR_LANDING_ENABLED=true
NATIVE_SURVIVAL_ENABLED=true
NATIVE_CAREER_TRACK_DETAIL_ENABLED=true
NATIVE_CAREER_SENTENCES_ENABLED=true
NATIVE_VERBS_ENABLED=true
NATIVE_SAVED_VERBS_ENABLED=true
NATIVE_VERB_DETAIL_ENABLED=true
NATIVE_LEAGUE_ENABLED=true
NATIVE_MESSAGES_ENABLED=true
NATIVE_VOCABULARY_ENABLED=true

NATIVE_VIDEO_PROGRESS_PERCENT=60
NATIVE_COURSE_CATALOG_FIRST_AFTER=3
NATIVE_COURSE_DETAIL_FIRST_AFTER=3
NATIVE_CAREER_TRACKS_FIRST_AFTER=2
NATIVE_SURVIVAL_FIRST_AFTER=4
NATIVE_CAREER_SENTENCES_FIRST_AFTER=3
NATIVE_CAREER_SENTENCES_INTERVAL=4
NATIVE_VERBS_FIRST_AFTER=1
NATIVE_VERBS_INTERVAL=4
NATIVE_SAVED_VERBS_FIRST_AFTER=1
NATIVE_SAVED_VERBS_INTERVAL=4
NATIVE_VERB_DETAIL_INTERVAL=3
NATIVE_LEAGUE_FIRST_AFTER=3
NATIVE_LEAGUE_INTERVAL=4
NATIVE_MESSAGES_FIRST_AFTER=3
NATIVE_MESSAGES_INTERVAL=4
NATIVE_VOCABULARY_FIRST_AFTER=3
NATIVE_VOCABULARY_INTERVAL=4
```

The fixed Home, Practice Hub, AI Tutor, video-complete, and Career Track Detail positions still need individual enable flags, but no numeric interval.

## Recommended Flutter architecture

### `NativeAdsService`

- Register once in `AppBootstrapController` after `RewardedAdsService`; reuse the existing `MobileAds` initialization and shared eligibility configuration.
- Keep platform IDs separate. Development IDs:
  - Android: `ca-app-pub-3940256099942544/2247696110`
  - iOS: `ca-app-pub-3940256099942544/3986624511`
- Production IDs should come from `ADMOB_NATIVE_ANDROID_ID` and `ADMOB_NATIVE_IOS_ID` Dart defines. In release, fail closed when missing or equal to a Google test ID.
- Load through AdMob's `NativeAd` API so configured mediation demand can participate.
- Key cached/in-flight ads by stable slot identity such as `placement + contentContextId + sourceBoundary`, not visual list index alone.
- Deduplicate concurrent loads, cap retained ads to visible/near-visible slots, dispose evicted ads, and invalidate all loads on eligibility loss.
- Do not auto-reload on every list rebuild or scroll. A failed slot should collapse safely and retry only under an explicit bounded policy or later lifecycle/config refresh.
- Expose a pure helper for source-boundary calculation. For first-after `F` and interval `I`, boundaries are `F + n*I`; fixed single insertions omit `I`.

### `NativeAdSlot`

- Stateful widget owning one stable slot handle and disposing it on removal.
- Render nothing while ineligible, unknown, or failed.
- Use `AdWidget` only after the `NativeAd` load callback succeeds.
- Prefer `NativeTemplateStyle(TemplateType.small)` for list placements; consider `medium` only for fixed section placements with enough vertical space.
- Keep every slot outside content cards/tap regions and include SDK-required attribution/ad choices.
- Use semantic labels that identify advertising; do not mimic conversations, leaderboard users, courses, verbs, or vocabulary cards.

List screens should construct derived display rows (`content` or `ad`) while keeping domain collections untouched. This preserves search, original indexes, pagination, selection, TTS, unread counts, rank values, and navigation.

## Native mediation compatibility

### Repository status

- `google_mobile_ads: ^9.2.0` is declared and locked. The local plugin supplies AdMob `NativeAd` and native templates and initializes Google Mobile Ads once.
- **Meta mediation Flutter adapter is absent:** no `gma_mediation_meta` dependency is present.
- **Android Meta adapter is absent:** no `com.google.ads.mediation:facebook` dependency is declared in app Gradle. The Google Mobile Ads SDK arrives transitively from the Flutter plugin, but the Meta login SDK/config is not a mediation adapter.
- **iOS Meta adapter is absent:** `ios/Podfile.lock` contains Facebook Login SDK pods but no `FBAudienceNetwork`, Meta mediation adapter, `google_mobile_ads`, or `Google-Mobile-Ads-SDK` entries. The generated Flutter plugin metadata/registrant includes `google_mobile_ads`, so the Pods lock appears stale relative to `pubspec.lock`.
- Android and iOS manifests currently use Google's sample AdMob application IDs. Production app IDs/build configuration must remain separate from test configuration; production advertising must not be activated during development.
- Android effectively requires API 24 because the inspected `google_mobile_ads` 9.2.0 plugin declares `minSdk 24`. iOS is already deployment target 15.0 (`ios/Podfile:1,64`), which satisfies current Meta adapter requirements.

Google's official Flutter Meta mediation guide states that Meta supports Native ads through AdMob bidding mediation and currently directs Flutter apps to add `gma_mediation_meta`; it also requires the Meta demand mapping, privacy configuration, and test-mode verification. Native templates are supported by the Google Mobile Ads Flutter plugin, while custom layouts require Android and iOS platform factories. Sources: [Flutter Meta mediation](https://developers.google.com/admob/flutter/mediation/meta), [Flutter Native ads](https://developers.google.com/ad-manager/mobile-ads-sdk/flutter/native), [Native templates](https://developers.google.com/ad-manager/mobile-ads-sdk/flutter/native/templates).

### Requirements before implementation can be considered mediated

1. Add a `gma_mediation_meta` version compatible with `google_mobile_ads 9.2.0` (the current Google guide lists 1.5.3 for plugin 9.x); this is a future dependency change, not performed during inspection.
2. Regenerate/synchronize iOS Pods and verify that `google_mobile_ads`, `Google-Mobile-Ads-SDK`, `FBAudienceNetwork`, and the Meta adapter are resolved in the lockfile.
3. Verify each Android/iOS **Native** ad unit is included in an enabled AdMob Meta bidding mediation group and mapped to the correct Meta Native/Native Banner placement. Existing Banner mapping does not prove this.
4. For Meta Native (not Native Banner), render the media asset; Google's Android guidance warns Meta native impressions are not recorded without the required `MediaView`. Native Banner instead requires the app icon asset.
5. Add/verify Meta iOS SKAdNetwork identifiers and Meta's iOS 14+ advertiser-tracking handling before Google Mobile Ads initialization, consistent with the chosen consent/ATT policy.
6. Verify GDPR/Additional Consent and US-state privacy propagation and list Meta as an ad partner in AdMob. No UMP consent flow was identified in the inspected application code even though the Google SDK dependency includes UMP.
7. Validate adapters with Ad Inspector single-source testing and Meta test mode using test ad units only. Dashboard state cannot be proven from repository inspection.

## Platform rendering requirements

- Preferred first implementation: Google `NativeTemplateStyle`, which provides Android and iOS native layouts without app-defined factories.
- If design requirements exceed templates:
  - Android must register a `NativeAdFactory` and provide a native `NativeAdView` layout with all clickable assets registered; Meta Native requires a media view.
  - iOS must register a `FLTNativeAdFactory` and build a `GADNativeAdView` with outlets/assets correctly assigned.
  - Factory registration must occur before a Dart `NativeAd` requests that factory ID and must be unregistered/disposed with engine lifecycle.
- No platform factories were created during this inspection.

## Potential layout issues

- Two video triggers can collide at completion; they need explicit one-shot and replacement/stacking behavior.
- Inserting ads by mutating domain lists would break course pagination/progress, verb pagination, sentence TTS state, message unread/order behavior, leaderboard ranks, and vocabulary indexes.
- Survival Italian needs a decision on counting order and grid-row handling.
- Native templates have fixed minimum heights; nested `SingleChildScrollView` + shrink-wrapped lists may become expensive if many repeated ad platform views are kept alive. Retain only a bounded number and use stable keys.
- Message ads need stronger visual separation than other feeds and must not expose avatar, online, timestamp, unread, or conversation-card affordances.
- Verb Detail already has a banner; repeated Native slots must not replace or alter it and may produce excessive density on long form lists. Backend placement enable/interval controls are therefore essential.
- AI Tutor Discovery has a fixed bottom input bar; the approved landing placement belongs in `AiChatView`, not that deeper screen.

## Implementation blockers

1. **Placement #10 ordering decision:** define backend order vs rendered order and whether a full-width ad may split a two-column row.
2. **Meta adapter missing on both platforms:** current repository is not capable of serving Meta-mediated Native demand.
3. **Stale iOS Pods lock:** it does not reflect the declared Google Mobile Ads Flutter dependency.
4. **Dashboard configuration unverified:** Native ad units, Meta bidding group inclusion/mapping, test mode, and privacy partner settings cannot be established from source code.
5. **Production native unit IDs are not yet wired:** future implementation must add separate Dart defines and retain Google test IDs for non-release builds.
6. **Consent/privacy integration needs verification:** Meta Additional Consent, US-state handling, iOS ATT/advertiser-tracking behavior, and SKAdNetwork entries must be confirmed before production activation.

None of these blockers prevent the other 16 Flutter insertion points from being implemented once implementation is authorized; they prevent claiming complete Native mediation readiness or safely implementing #10 without a decision.
