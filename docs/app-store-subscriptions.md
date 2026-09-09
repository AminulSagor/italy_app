# App Store subscription submission checklist

Last audited: 2026-08-31

Both the shop checkout and course checkout now show the StoreKit-localized title, exact StoreKit price, StoreKit billing duration, automatic-renewal terms, cancellation instructions, Privacy Policy, Terms of Use, and Restore Purchases before the purchase button.

App Store Connect configuration cannot be created from the app code. Complete every item below for each active App Store subscription product.

## Subscription group

- Create the subscription group and add localized group display names and descriptions for English, Bangla, and Italian.
- Put mutually exclusive plans in the same group and assign the correct subscription levels for upgrades and downgrades.
- Confirm the subscription provides ongoing value, lasts at least seven days, and works on all supported user devices.

## Every subscription product

- Product ID exactly matches the backend App Store mapping.
- Reference name is clear internally.
- Duration matches the period returned by StoreKit and the app's package configuration.
- Price and storefront availability are configured.
- Display name and description are localized for English, Bangla, and Italian.
- Each promotional offer or offer code used by the backend exists in App Store Connect and has the same Offer ID.
- Course subscriptions currently accept the regular StoreKit product price only. Keep the course App Store `offerId` empty unless the signed StoreKit promotional-offer purchase flow is implemented; checkout is intentionally blocked when an unsupported offer is configured.
- The product is in **Ready to Submit** state and has no missing metadata.

## Review information

- Upload a review screenshot for every subscription. Capture every relevant final iOS paywall, including shop and course checkout, showing the selected title, localized price, billing duration, renewal terms, cancellation link, legal links, Restore Purchases, and purchase button.
- Add review notes explaining where the reviewer can open each subscription screen.
- Provide a working review account with access to every paywall.
- Keep the backend and review environment online during review.
- Add the subscription to the app version submission. The first subscription and first subscription group must be submitted with a new app version.

## Final device test

- Test each product with a Sandbox Apple Account or TestFlight in every supported language.
- Confirm Restore Purchases works for both subscriptions and lifetime-course non-consumables.
- Confirm the displayed amount comes from StoreKit and matches Apple's purchase confirmation sheet.
- Confirm renewal duration and any offer terms match App Store Connect.
- Complete, cancel, pending, interrupted, and restored purchase flows.
- Verify **Manage subscription** opens Apple's subscription management page.
- Verify Privacy Policy and Terms of Use links load publicly without authentication.
