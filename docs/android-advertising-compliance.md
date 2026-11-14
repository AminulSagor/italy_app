# Android advertising compliance decisions

The Android advertisement release initializes Google Mobile Ads only after
Google UMP reports that ads may be requested. When Google requires a privacy
options entry point, the app exposes it in Settings under Privacy & legal.

## Advertising identifier permissions

`android/app/src/main/AndroidManifest.xml` currently removes `AD_ID` and the
Android Privacy Sandbox advertising permissions contributed by dependencies.
This implementation does not reverse that privacy-sensitive decision.

Before production release, the product owner must decide whether measurement,
attribution, personalized advertising, or Meta Audience Network configuration
requires any of those permissions. If a permission is restored, the Google
Play Data safety declaration, privacy policy, UMP message configuration, and
ad-request behavior must be reviewed together before publishing.

Ads can be requested without restoring the advertising identifier, but fill,
personalization, attribution, and reporting may be reduced.

## Console configuration not represented in source

- Publish an appropriate GDPR/EEA consent message in AdMob Privacy & messaging.
- Configure Meta Audience Network bidding or mediation in the AdMob console.
- Confirm the Android app ID and all three Android ad-unit IDs belong to the
  intended production application.
- Configure the rewarded SSV callback URL and allowed rewarded ad-unit IDs.
- Verify Google Play Data safety answers against the final manifest and SDKs.
