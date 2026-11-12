# Backend Environment-Variable Incident Runbook

## Scope, date, and safety boundary

- Audit date: 2026-10-30 (Asia/Dhaka).
- In scope: the Italir Pothe main backend at `/Users/air/Desktop/mine/backend/italir-pothe-backend` and the separate Pipecat backend that the main backend calls.
- Out of scope: mobile and web frontend inventories.
- Method: read-only source/config/template/Docker/Compose/documentation/Git-metadata search. The real `.env` was never opened. No value, credential, production connection, or provider action was used.
- Important limitation: the Pipecat backend implementation is not present in the authorized workspace. This repository contains only three client variables and three integration call sites. Pipecat counts below are therefore incomplete until its repository or a names-only Railway export is supplied.

## Executive result

| Surface | Distinct names | Notes |
|---|---:|---|
| Main backend runtime/test source | 217 | Includes dynamically constructed names and worker/test settings. |
| Main backend plus executable presence example | 218 | Adds `SOCKET_SERVER`. This closely matches the reported Railway count of roughly 218, but does not prove Railway and source are identical. |
| Committed env templates | 134 | Union of `.env.example`, `.env.ai-tutor.example`, and `important-verbs.env.example`. |
| Runtime names absent from all templates | 90 | Includes several high-impact secrets. |
| Template names apparently unused by runtime | 7 | Still rotate any live credential after compromise. |
| Docker-only names | 1 | `PUPPETEER_CACHE_DIR`. |
| Documentation-only names | 4 | `API_BASE_URL`, `CONV_ID`, `REACT_APP_API_URL`, `REDIS_URL`. |
| Full main-backend union | 230 | Runtime, templates, Docker, examples, and documentation. |
| Pipecat implementation | Unknown | Source/config absent; only its client contract is observable. |

Primary evidence: `.env.example`, `.env.ai-tutor.example`, `src/module-2/important-verbs/important-verbs.env.example`, `Dockerfile:24-29`, `src/app.module.ts:69-85`, and the service references listed below.

## Pipecat source-location recheck

The repository was checked for nested directories, ignored paths, Git submodules, `.gitmodules`, Python files, Python manifests, Railway/Procfile files, Docker/Compose files, archives, and documentation pointers.

- No Git submodule or `.gitmodules` entry exists.
- No Pipecat-named directory/file, Python source, `requirements*.txt`, `pyproject.toml`, Railway config, or Procfile exists under the backend root.
- `src.zip` contains only a `src/` snapshot and no Pipecat/Python/deployment path.
- The only Compose file is `libretranslate/docker-compose.yml`; it is not Pipecat.
- The only Pipecat references are client integrations in:
  - `src/ai-tutor/ai-tutor.service.ts:826-843`
  - `src/ai-consent/ai-consent-session-revocation.service.ts:141-150`
  - `src/resume-studio/services/resume-llm-client.service.ts:14-31`

Observable Pipecat contract names:

```text
PIPECAT_SERVICE_URL
PIPECAT_INTERNAL_API_KEY
PIPECAT_REQUEST_TIMEOUT_MS
```

The Pipecat service likely has additional provider, transport, media, and deployment variables that cannot be inferred safely from this checkout.

### Safe way to supply missing Pipecat data

Preferred: provide the local path to the Pipecat repository after placing it in an authorized workspace root. Do not paste `.env` contents.

If only Railway is available, export **names only** from the Pipecat service UI/API. A safe format is one name per line, for example:

```text
OPENAI_API_KEY
PIPECAT_INTERNAL_API_KEY
PORT
```

Do not use `railway variables` output directly in chat because it can contain values. Locally transform an already-authorized JSON export without printing values, then review the output before sharing:

```sh
jq -r 'keys[]' railway-variables.json | LC_ALL=C sort -u > pipecat-variable-names.txt
```

If the export is an object nested under a service key, select that object first, then run `keys[]`. Delete the local export securely according to incident policy after the names-only file is verified. A screenshot of the Railway variable-name column is also acceptable if every value column is fully cropped or redacted.

## Main backend inventory

This is the sanitized 230-name union. Names only; no values.

```text
AGORA_APP_CERTIFICATE AGORA_APP_ID AGORA_TOKEN_EXPIRE_SECONDS
AI_TUTOR_LEVEL_TEST_MAX_ATTEMPTS AI_TUTOR_LEVEL_TEST_MAX_SPEAKING_QUESTIONS AI_TUTOR_LEVEL_TEST_MIN_SPEAKING_QUESTIONS
API_BASE_URL
APPLE_APNS_BUNDLE_ID APPLE_APNS_KEY_ID APPLE_APNS_PRIVATE_KEY APPLE_APNS_TEAM_ID APPLE_APNS_USE_SANDBOX
APPLE_APP_ATTEST_ENVIRONMENT APPLE_APP_ATTEST_ROOT_CA_PATH
APPLE_APP_ID_PREFIX APPLE_BUNDLE_ID APPLE_CLIENT_ID
APPLE_SIGN_IN_KEY_ID APPLE_SIGN_IN_PRIVATE_KEY APPLE_SIGN_IN_REDIRECT_URI APPLE_SIGN_IN_TEAM_ID APPLE_SIGN_IN_TOKEN_ENCRYPTION_KEY
APP_STORE_APP_APPLE_ID APP_STORE_BUNDLE_ID APP_STORE_ENABLE_ONLINE_CERTIFICATE_CHECKS APP_STORE_ISSUER_ID APP_STORE_KEY_ID
APP_STORE_NOTIFICATION_ENCRYPTION_KEY APP_STORE_NOTIFICATION_MAX_ATTEMPTS APP_STORE_PRIVATE_KEY APP_STORE_ROOT_CA_CERTS_BASE64 APP_STORE_VERIFICATION_MODE
AUTH_SESSION_TTL_DAYS
AWS_ACCESS_KEY_ID AWS_CLOUDFRONT_BASE_URL AWS_REGION AWS_S3_BUCKET AWS_S3_PUBLIC_BASE_URL AWS_S3_READ_URL_EXPIRES_SECONDS
AWS_S3_REGION AWS_S3_UPLOAD_URL_EXPIRES_SECONDS AWS_SECRET_ACCESS_KEY
CERTIFICATE_PUBLIC_VERIFY_BASE_URL
CHAT_MODERATION_ALLOWLIST CHAT_MODERATION_ENABLED CHAT_MODERATION_HIGH_CONFIDENCE
CHAT_MODERATION_KEYWORDS_HARASSMENT CHAT_MODERATION_KEYWORDS_HATE CHAT_MODERATION_KEYWORDS_PROFANITY
CHAT_MODERATION_KEYWORDS_SELF_HARM CHAT_MODERATION_KEYWORDS_SEXUAL CHAT_MODERATION_KEYWORDS_THREAT CHAT_MODERATION_KEYWORDS_VIOLENCE
CHAT_MODERATION_LLM_MODEL CHAT_MODERATION_LLM_TIMEOUT_MS CHAT_MODERATION_MAX_INPUT_CHARACTERS
CLOUDFRONT_COOKIE_EXPIRES_SECONDS CLOUDFRONT_KEY_PAIR_ID CLOUDFRONT_PRIVATE_KEY_BASE64
CLOUDFRONT_SIGNED_COOKIES_ENABLED CLOUDFRONT_SIGNED_URLS_ENABLED CLOUDFRONT_URL_EXPIRES_SECONDS
CONTACT_INBOX_EMAIL CONV_ID CORS_ORIGIN COURSE_DEVICE_ENFORCEMENT_ENABLED
CV_FREE_CREATION_LIMIT CV_RENDER_CHROMIUM_PATH CV_RENDER_FONT_BOLD_PATH CV_RENDER_FONT_FALLBACK_PATHS
CV_RENDER_FONT_FAMILY CV_RENDER_FONT_REGULAR_PATH CV_TEST_OUTPUT_DIR
DB_HOST DB_NAME DB_PASSWORD DB_PORT DB_USER
DEMO_EUR_TO_BDT_RATE EMAIL_BYPASS
FACEBOOK_APP_ID FACEBOOK_APP_SECRET FACEBOOK_GRAPH_API_VERSION
FFMPEG_PATH FFPROBE_PATH
FILE_MAX_AUDIO_SIZE_BYTES FILE_MAX_IMAGE_SIZE_BYTES FILE_MAX_PDF_SIZE_BYTES FILE_MAX_VIDEO_SIZE_BYTES
FIREBASE_CLIENT_EMAIL FIREBASE_PRIVATE_KEY FIREBASE_PROJECT_ID
FRONTEND_URL
GEMINI_API_KEY GEMINI_LEVEL_TEST_MODEL GEMINI_LIVE_MODEL GEMINI_REQUEST_TIMEOUT_MS
GEMINI_SESSION_SUMMARY_INTERVAL_SECONDS GEMINI_SESSION_SUMMARY_MODEL GEMINI_VAD_PREFIX_PADDING_MS GEMINI_VAD_SILENCE_DURATION_MS
GOOGLE_CLIENT_ID
GOOGLE_PLAY_CLIENT_EMAIL GOOGLE_PLAY_DEMO_PRODUCT_PREFIX GOOGLE_PLAY_PACKAGE_NAME GOOGLE_PLAY_PRIVATE_KEY GOOGLE_PLAY_PROJECT_ID
GOOGLE_PLAY_REQUIRE_OBFUSCATED_ACCOUNT_ID GOOGLE_PLAY_RTDN_AUDIENCE GOOGLE_PLAY_RTDN_BATCH_SIZE
GOOGLE_PLAY_RTDN_ENCRYPTION_KEY GOOGLE_PLAY_RTDN_MAX_ATTEMPTS GOOGLE_PLAY_RTDN_PUSH_SERVICE_ACCOUNT_EMAIL
GOOGLE_PLAY_RTDN_STALE_MINUTES GOOGLE_PLAY_SUBSCRIPTION_TOKEN_ENCRYPTION_KEY GOOGLE_PLAY_VERIFICATION_MODE
GOOGLE_PLAY_VOIDED_BACKFILL_DAYS GOOGLE_PLAY_VOIDED_LEASE_MINUTES GOOGLE_PLAY_VOIDED_MAX_ATTEMPTS
GOOGLE_PLAY_VOIDED_MAX_PAGES GOOGLE_PLAY_VOIDED_OVERLAP_MINUTES GOOGLE_PLAY_VOIDED_PAGE_SIZE
GOOGLE_PLAY_VOIDED_PROCESS_BATCH GOOGLE_PLAY_VOIDED_RECONCILIATION_ENABLED
HOME_GUIDE_VIDEO_ENABLED HOME_GUIDE_VIDEO_YOUTUBE_URL HOST
IMPORTANT_VERBS_IMPORT_ALL IMPORTANT_VERBS_KAIKKI_SOURCE IMPORTANT_VERBS_LEMMAS IMPORTANT_VERBS_LEMMA_FILE
IMPORTANT_VERBS_MAX_VERBS IMPORTANT_VERBS_MONTHLY_SYNC_ENABLED IMPORTANT_VERBS_SOURCE_VERSION
IMPORTANT_VERBS_SYNC_ON_STARTUP IMPORTANT_VERBS_TATOEBA_ENABLED IMPORTANT_VERBS_TATOEBA_ENDPOINT
IMPORTANT_VERBS_TATOEBA_MAX_REQUESTS IMPORTANT_VERBS_TATOEBA_REQUEST_DELAY_MS IMPORTANT_VERBS_TATOEBA_TIMEOUT_MS
IMPORTANT_VERBS_UNIMORPH_SOURCE
ITALIR_POTHE_INVOICE_SUPPORT_EMAIL ITALIR_POTHE_INVOICE_TAX_NOTE ITALIR_POTHE_LOGO_PATH
JWT_EXPIRES_IN JWT_SECRET
LIBRETRANSLATE_API_KEY LIBRETRANSLATE_BATCH_MAX_CHARACTERS LIBRETRANSLATE_BATCH_SIZE LIBRETRANSLATE_ENABLED
LIBRETRANSLATE_ENDPOINT LIBRETRANSLATE_MAX_RETRIES LIBRETRANSLATE_PIPELINE_VERSION
LIBRETRANSLATE_REQUEST_DELAY_MS LIBRETRANSLATE_SOURCE_LANGUAGE LIBRETRANSLATE_TARGET_LANGUAGE LIBRETRANSLATE_TIMEOUT_MS
NODE_ENV
OPENAI_API_KEY OPENAI_CV_ASSISTANT_MODEL OPENAI_CV_ASSISTANT_TIMEOUT_MS OPENAI_CV_DOWNLOAD_TIMEOUT_MS
OPENAI_CV_IMAGE_QUALITY OPENAI_CV_IMAGE_SIZE OPENAI_CV_REQUEST_TIMEOUT_MS
OTP_IDENTIFIER_DAILY_LIMIT OTP_IDENTIFIER_HOURLY_LIMIT OTP_IP_DAILY_SEND_LIMIT OTP_IP_DAILY_VERIFY_LIMIT
OTP_IP_HOURLY_SEND_LIMIT OTP_IP_HOURLY_VERIFY_LIMIT OTP_RATE_LIMIT_HASH_SECRET OTP_RESEND_COOLDOWN_SECONDS
PACKAGE_STORE_CHECKOUT_TTL_MINUTES PAYMENTS_DEMO_MODE
PDF_LINEARIZATION_ENABLED PDF_LINEARIZATION_REQUIRED PDF_LINEARIZATION_TIMEOUT_MS
PIPECAT_INTERNAL_API_KEY PIPECAT_REQUEST_TIMEOUT_MS PIPECAT_SERVICE_URL
PIPER_DATA_DIR PIPER_PYTHON PIPER_VOICE
PLAY_INTEGRITY_CLIENT_EMAIL PLAY_INTEGRITY_MAX_AGE_MS PLAY_INTEGRITY_PACKAGE_NAME PLAY_INTEGRITY_PRIVATE_KEY
PLAY_INTEGRITY_PROJECT_ID PLAY_INTEGRITY_REQUIRE_LICENSED
PORT PUBLIC_API_BASE_URL PUPPETEER_CACHE_DIR QPDF_BINARY REACT_APP_API_URL REDIS_URL RUN_CV_RENDER_TESTS
S3_MULTIPART_PART_SIZE_BYTES S3_MULTIPART_SESSION_TTL_HOURS S3_MULTIPART_URL_EXPIRES_SECONDS S3_SINGLE_PUT_THRESHOLD_BYTES
SES_FROM_EMAIL SMS_API_KEY SMS_BYPASS SMS_SENDER_ID SOCKET_SERVER
TRUST_PROXY_HOPS TYPEORM_SYNC
VIDEO_HLS_SEGMENT_SECONDS VIDEO_HLS_STORAGE_PREFIX VIDEO_TRANSCODE_MAX_ATTEMPTS VIDEO_TRANSCODE_RETRY_DELAY_MINUTES
VIDEO_TRANSCODING_ENABLED VIDEO_WORKER_ID VIDEO_WORKER_LOCK_TIMEOUT_MINUTES VIDEO_WORKER_POLL_INTERVAL_MS VIDEO_WORK_DIRECTORY
WEB_APP_URL
ZEPTOMAIL_API_TOKEN ZEPTOMAIL_API_URL ZEPTOMAIL_FROM_EMAIL ZEPTOMAIL_FROM_NAME ZEPTOMAIL_WEBHOOK_SECRET
ZOHO_FROM_EMAIL ZOHO_FROM_NAME ZOHO_SMTP_HOST ZOHO_SMTP_PASS ZOHO_SMTP_PORT ZOHO_SMTP_SECURE ZOHO_SMTP_USER
```

## Code-versus-template drift

### Runtime names absent from every template (90)

```text
APP_STORE_APP_APPLE_ID APP_STORE_BUNDLE_ID APP_STORE_ENABLE_ONLINE_CERTIFICATE_CHECKS
APP_STORE_ISSUER_ID APP_STORE_KEY_ID APP_STORE_NOTIFICATION_ENCRYPTION_KEY
APP_STORE_NOTIFICATION_MAX_ATTEMPTS APP_STORE_PRIVATE_KEY APP_STORE_ROOT_CA_CERTS_BASE64 APP_STORE_VERIFICATION_MODE
AUTH_SESSION_TTL_DAYS
AWS_CLOUDFRONT_BASE_URL AWS_S3_READ_URL_EXPIRES_SECONDS AWS_S3_UPLOAD_URL_EXPIRES_SECONDS
CLOUDFRONT_COOKIE_EXPIRES_SECONDS CLOUDFRONT_KEY_PAIR_ID CLOUDFRONT_PRIVATE_KEY_BASE64
CLOUDFRONT_SIGNED_COOKIES_ENABLED CLOUDFRONT_SIGNED_URLS_ENABLED CLOUDFRONT_URL_EXPIRES_SECONDS
CONTACT_INBOX_EMAIL
CV_FREE_CREATION_LIMIT CV_RENDER_CHROMIUM_PATH CV_RENDER_FONT_BOLD_PATH CV_RENDER_FONT_FALLBACK_PATHS
CV_RENDER_FONT_FAMILY CV_RENDER_FONT_REGULAR_PATH CV_TEST_OUTPUT_DIR
FILE_MAX_AUDIO_SIZE_BYTES FILE_MAX_IMAGE_SIZE_BYTES FILE_MAX_PDF_SIZE_BYTES FILE_MAX_VIDEO_SIZE_BYTES
FRONTEND_URL
GOOGLE_PLAY_CLIENT_EMAIL GOOGLE_PLAY_PACKAGE_NAME GOOGLE_PLAY_PRIVATE_KEY GOOGLE_PLAY_PROJECT_ID
GOOGLE_PLAY_REQUIRE_OBFUSCATED_ACCOUNT_ID GOOGLE_PLAY_RTDN_AUDIENCE GOOGLE_PLAY_RTDN_BATCH_SIZE
GOOGLE_PLAY_RTDN_ENCRYPTION_KEY GOOGLE_PLAY_RTDN_MAX_ATTEMPTS GOOGLE_PLAY_RTDN_PUSH_SERVICE_ACCOUNT_EMAIL
GOOGLE_PLAY_RTDN_STALE_MINUTES GOOGLE_PLAY_SUBSCRIPTION_TOKEN_ENCRYPTION_KEY GOOGLE_PLAY_VERIFICATION_MODE
GOOGLE_PLAY_VOIDED_BACKFILL_DAYS GOOGLE_PLAY_VOIDED_LEASE_MINUTES GOOGLE_PLAY_VOIDED_MAX_ATTEMPTS
GOOGLE_PLAY_VOIDED_MAX_PAGES GOOGLE_PLAY_VOIDED_OVERLAP_MINUTES GOOGLE_PLAY_VOIDED_PAGE_SIZE
GOOGLE_PLAY_VOIDED_PROCESS_BATCH GOOGLE_PLAY_VOIDED_RECONCILIATION_ENABLED
HOME_GUIDE_VIDEO_ENABLED HOME_GUIDE_VIDEO_YOUTUBE_URL
ITALIR_POTHE_INVOICE_SUPPORT_EMAIL ITALIR_POTHE_INVOICE_TAX_NOTE ITALIR_POTHE_LOGO_PATH
OPENAI_CV_ASSISTANT_TIMEOUT_MS OPENAI_CV_DOWNLOAD_TIMEOUT_MS OPENAI_CV_IMAGE_QUALITY
OPENAI_CV_IMAGE_SIZE OPENAI_CV_REQUEST_TIMEOUT_MS
PACKAGE_STORE_CHECKOUT_TTL_MINUTES
PDF_LINEARIZATION_ENABLED PDF_LINEARIZATION_REQUIRED PDF_LINEARIZATION_TIMEOUT_MS
PIPER_DATA_DIR PIPER_PYTHON PIPER_VOICE QPDF_BINARY RUN_CV_RENDER_TESTS
S3_MULTIPART_PART_SIZE_BYTES S3_MULTIPART_SESSION_TTL_HOURS S3_MULTIPART_URL_EXPIRES_SECONDS S3_SINGLE_PUT_THRESHOLD_BYTES
SES_FROM_EMAIL SMS_API_KEY SMS_SENDER_ID
VIDEO_HLS_SEGMENT_SECONDS VIDEO_HLS_STORAGE_PREFIX VIDEO_TRANSCODE_MAX_ATTEMPTS
VIDEO_TRANSCODE_RETRY_DELAY_MINUTES VIDEO_WORKER_ID VIDEO_WORKER_LOCK_TIMEOUT_MINUTES
VIDEO_WORKER_POLL_INTERVAL_MS VIDEO_WORK_DIRECTORY
WEB_APP_URL ZOHO_FROM_NAME
```

High-impact omissions include `APP_STORE_PRIVATE_KEY`, `APP_STORE_NOTIFICATION_ENCRYPTION_KEY`, `CLOUDFRONT_PRIVATE_KEY_BASE64`, `GOOGLE_PLAY_PRIVATE_KEY`, `GOOGLE_PLAY_RTDN_ENCRYPTION_KEY`, `GOOGLE_PLAY_SUBSCRIPTION_TOKEN_ENCRYPTION_KEY`, and `SMS_API_KEY`.

The seven `CHAT_MODERATION_KEYWORDS_*` entries are genuine runtime names dynamically assembled at `src/chat/moderation/message-keyword-scanner.service.ts:71`.

### Template names apparently unused by runtime (7)

```text
GOOGLE_PLAY_DEMO_PRODUCT_PREFIX
PUBLIC_API_BASE_URL
ZOHO_SMTP_HOST
ZOHO_SMTP_PASS
ZOHO_SMTP_PORT
ZOHO_SMTP_SECURE
ZOHO_SMTP_USER
```

Evidence: `.env.example:13`, `.env.example:68-72`, and `.env.example:182`. “Unused” does not mean safe: rotate `ZOHO_SMTP_PASS` if it was live in Railway, then remove obsolete variables deliberately.

## Secret and non-secret classification

### Credential/secret names (26)

```text
AGORA_APP_CERTIFICATE
APPLE_APNS_PRIVATE_KEY
APPLE_SIGN_IN_PRIVATE_KEY
APPLE_SIGN_IN_TOKEN_ENCRYPTION_KEY
APP_STORE_NOTIFICATION_ENCRYPTION_KEY
APP_STORE_PRIVATE_KEY
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
CLOUDFRONT_PRIVATE_KEY_BASE64
DB_PASSWORD
FACEBOOK_APP_SECRET
FIREBASE_PRIVATE_KEY
GEMINI_API_KEY
GOOGLE_PLAY_PRIVATE_KEY
GOOGLE_PLAY_RTDN_ENCRYPTION_KEY
GOOGLE_PLAY_SUBSCRIPTION_TOKEN_ENCRYPTION_KEY
JWT_SECRET
LIBRETRANSLATE_API_KEY
OPENAI_API_KEY
OTP_RATE_LIMIT_HASH_SECRET
PIPECAT_INTERNAL_API_KEY
PLAY_INTEGRITY_PRIVATE_KEY
SMS_API_KEY
ZEPTOMAIL_API_TOKEN
ZEPTOMAIL_WEBHOOK_SECRET
ZOHO_SMTP_PASS
```

### Risk and rotation priority

| Tier | Names/families | Why / action |
|---|---|---|
| Urgent | `DB_PASSWORD`; AWS pair; `CLOUDFRONT_PRIVATE_KEY_BASE64`; `JWT_SECRET`; Firebase/Google/Play/Integrity private keys; `OPENAI_API_KEY`; `GEMINI_API_KEY`; `PIPECAT_INTERNAL_API_KEY`; Apple/App Store/APNS private keys; `FACEBOOK_APP_SECRET`; `AGORA_APP_CERTIFICATE`; ZeptoMail/SMS credentials; live `ZOHO_SMTP_PASS` | Direct data access, token forgery, cloud mutation, paid API abuse, or provider impersonation. Create replacements, deploy/verify, and revoke old credentials provider-side. |
| High, migration-sensitive | `APPLE_SIGN_IN_TOKEN_ENCRYPTION_KEY`, `APP_STORE_NOTIFICATION_ENCRYPTION_KEY`, `GOOGLE_PLAY_RTDN_ENCRYPTION_KEY`, `GOOGLE_PLAY_SUBSCRIPTION_TOKEN_ENCRYPTION_KEY` | They protect persisted ciphertext. Do not overwrite directly. Add key versioning/dual decrypt, migrate rows, then retire the old key. Evidence: `app-store-payload-cipher.service.ts:15-16`, `google-play-rtdn-cipher.service.ts:61-62`, `google-play-subscription-token-cipher.service.ts:14-15`. |
| Medium | `OTP_RATE_LIMIT_HASH_SECRET`, `LIBRETRANSLATE_API_KEY`; webhook/config pairing identifiers and any legacy credential whose provider scope is constrained | OTP rotation changes the hash namespace and may weaken continuity of throttles; it falls back to `JWT_SECRET` at `src/common/mail/otp-rate-limit.service.ts:237-238`. Rotate constrained provider keys after urgent credentials and inspect usage. |
| Low / non-secret | Hosts, URLs, ports, regions, bucket names, public/client IDs, key IDs, project IDs, service-account emails, sender IDs, package/bundle IDs, feature flags, model names, paths, TTLs, limits, timeouts, and public CA roots | Validate integrity and least-privilege associations. Do not mistake these for authenticators. IDs paired with a secret must be updated atomically when the provider changes the pair. |

## Immediate incident checklist

- [ ] Preserve Railway audit/activity logs, deploy history, membership changes, variable-change history, token creation, and suspected-compromise timestamps.
- [ ] Remove unknown Railway members, project/service tokens, CLI tokens, deploy hooks, and connected integrations; require MFA/SSO where available.
- [ ] Snapshot **variable names only** for main backend and Pipecat; never paste/export values into this report.
- [ ] Compare the main-backend Railway name set with the 217 runtime names and 134 template names; investigate extra/missing names.
- [ ] Locate the Pipecat repository or produce the names-only export described above.
- [ ] Confirm the old OpenAI key is revoked in the provider console and review usage/billing after the compromise time.
- [ ] Confirm the replacement OpenAI key reaches all three main-backend consumers and the separate Pipecat service.
- [ ] Rotate database and cloud/admin access before lower-impact configuration.
- [ ] Disable old credentials only after replacement-path verification, except where active abuse requires immediate revocation and controlled downtime.
- [ ] Record provider key IDs/fingerprints—not secret material—plus rotation time, owner, verification evidence, and revocation status.

## Dependency-aware staged rotation plan

### Stage 0 — contain and preserve evidence

Freeze uncontrolled deploys, remove unauthorized access, preserve logs, establish the exact compromise window, and create a rotation ledger containing only provider, variable name, old key identifier, new key identifier, owner, timestamps, and status.

### Stage 1 — database

1. Create a replacement database role/password with least privilege.
2. Update the main API and video worker together; both consume `DB_PASSWORD` (`src/app.module.ts:80`, `src/video-processing/video-worker.module.ts:22`).
3. Verify health, migrations, read/write transactions, background jobs, and worker locks.
4. Rollback: restore the prior credential only while it remains active and only if no evidence of active misuse; otherwise fix forward.
5. Terminate sessions using the old role, revoke it, and check DB audit logs for unusual reads/schema changes/export activity.

### Stage 2 — AWS, S3, CloudFront, Firebase, and Google service accounts

1. Create least-privilege replacements. Treat multiple Google variables as possibly referencing one provider key; revoke by provider key ID, not by Railway variable name.
2. Deploy and test S3 upload/download/delete, multipart operations, signed reads, Firebase push, Google Play verification/RTDN, and Play Integrity.
3. CloudFront overlap order: add a replacement public key to the trusted key group; deploy the new `CLOUDFRONT_PRIVATE_KEY_BASE64` plus `CLOUDFRONT_KEY_PAIR_ID`; verify fresh URLs/cookies; wait through configured URL/cookie TTLs; remove the old public key.
4. Disable old cloud/service-account keys, monitor errors, then delete them. Review CloudTrail/provider audit logs and object access logs.

Evidence: `src/files/services/s3.service.ts:89-94`, `src/files/services/cloudfront-signer.service.ts:38-43`, `src/firebase/services/firebase-admin.service.ts:153-156`, and `src/course-device-access/services/course-device-attestation.service.ts:135-141`.

### Stage 3 — AI providers and Pipecat internal authentication

1. OpenAI is reported rotated. Confirm old-key revocation provider-side, replacement deployment, usage/billing logs, and a low-cost request from each consumer:
   - moderation: `src/chat/moderation/message-moderation-llm.service.ts:33`
   - CV assistant: `src/cv-assistant/services/cv-assistant-openai.service.ts:1409`
   - CV image generation: `src/cv-generations/services/cv-image-generation.service.ts:36`
   - Pipecat: unverified until its source/name export is supplied.
2. Rotate `GEMINI_API_KEY`, test live tutoring and summary/level-test paths, revoke the old key, and inspect quotas/billing (`src/ai-tutor/gemini-live.service.ts:22-36,211`).
3. Rotate `PIPECAT_INTERNAL_API_KEY` with dual-key acceptance if supported: Pipecat accepts old+new, all three main-backend clients switch, calls and consent revocation are tested, then old-key acceptance is removed. Without dual-key support, use a coordinated maintenance deployment.
4. Rotate any Pipecat-only AI/transport credentials revealed by its own inventory.

### Stage 4 — JWT/session authentication

1. Prefer a key-ring transition: verify old and new keys, sign only with new, and remove old verification after `JWT_EXPIRES_IN` plus clock skew.
2. Current modules consume one `JWT_SECRET` across auth, chat, and calls (`src/auth/auth.module.ts:42`, `src/chat/chat.module.ts:63`, `src/calls/calls.module.ts:36`). If key-ring support is absent, immediate replacement logs users out and invalidates API/chat/call tokens.
3. Invalidate stored sessions as appropriate for `AUTH_SESSION_TTL_DAYS`; test login, refresh/session validation, WebSocket auth, and call auth.
4. Rollback must not re-enable a compromised signing key. Fix forward or accept controlled logout.

### Stage 5 — encryption-at-rest keys

For `APPLE_SIGN_IN_TOKEN_ENCRYPTION_KEY`, `APP_STORE_NOTIFICATION_ENCRYPTION_KEY`, `GOOGLE_PLAY_RTDN_ENCRYPTION_KEY`, and `GOOGLE_PLAY_SUBSCRIPTION_TOKEN_ENCRYPTION_KEY`:

1. Add a key version and dual-decrypt capability.
2. Encrypt new records only with the replacement.
3. Batch decrypt/re-encrypt existing records; compare row counts and sample functional reads without logging plaintext.
4. Keep a tested rollback path that can still decrypt both versions.
5. Remove old-key access only after migration and backup validation. Never simply overwrite these variables.

### Stage 6 — Apple, App Store, APNS, Facebook, and Agora

Create/activate replacement provider keys first, deploy the matching non-secret key/team/issuer IDs atomically, then verify Apple sign-in, purchase verification, App Store notifications, VoIP/APNS push, Facebook token verification, and Agora token issuance. Revoke the old provider credentials and inspect provider logs.

### Stage 7 — email, SMS, webhooks, and secondary providers

- ZeptoMail/SMS: deploy replacement token, send controlled test messages, revoke old token, and inspect delivery/billing logs.
- Webhook secrets: receiver accepts old+new, sender switches, a signed delivery is verified, then old-secret acceptance ends.
- Legacy Zoho: if `ZOHO_SMTP_PASS` was valid anywhere, rotate/revoke it even though current runtime appears not to use it.
- LibreTranslate: rotate if the endpoint requires the key; test a low-volume translation and revoke the old key.

### Stage 8 — integrity-only configuration

Validate endpoints, domains, CORS, ports, project/bucket/package/bundle IDs, key IDs, feature flags, model selections, paths, TTLs, and limits against known-good deployment records. These are not secrets but an attacker could alter them to redirect traffic or disable controls.

## Verification, rollback, and revocation matrix

| Family | Verify replacement | Safe rollback condition | Revoke/close old access |
|---|---|---|---|
| Database | API health, reads/writes, migrations, jobs, video-worker lock | Old role still active and not observed abused | Terminate old sessions; revoke role/password; review DB audit logs |
| AWS/S3 | Upload, signed read, delete, multipart, object policy | Replacement lacks permission and old key is not actively abused | Disable, monitor, delete old access key; review CloudTrail/S3 logs |
| CloudFront | Fresh signed URL/cookie works through CDN | Trusted key group still contains both public keys | Wait configured TTLs, remove old public key/key pair |
| Firebase/Google | Push, Play purchase, RTDN, Integrity | Old provider key temporarily enabled and not abused | Disable/delete old provider key ID; inspect provider audit logs |
| OpenAI/Gemini | One request through every consumer; quota/billing normal | Use a second newly created key, not the compromised old key | Provider-side revoke old key; confirm no post-revocation successes |
| Pipecat internal | AI tutor, consent revocation, resume LLM calls | Dual-key window or coordinated rollback | Remove old-key acceptance and search Pipecat access logs |
| JWT/session | Login, token verify, WebSocket/chat/call auth | Dual-verification ring only | Remove old verification after TTL; invalidate sessions as required |
| Persisted encryption | New writes and all migrated rows decrypt; counts reconcile | Dual-decrypt remains available | Remove old key only after verified migration/backups |
| Apple/Facebook/Agora | Sign-in, push, purchase notification, token issuance | Provider supports overlapping active keys | Revoke old provider credential and review logs |
| Email/SMS/webhook | Controlled send/delivery and signature validation | Dual receiver secret or old token not abused | Revoke token; end old webhook acceptance; review usage |

## Old-credential revocation checklist

- [ ] Database old role/password revoked and existing sessions terminated.
- [ ] AWS old access key disabled, observed, then deleted; CloudFront old public key removed after TTL.
- [ ] Old Firebase/Google service-account key IDs deleted; Play/Integrity/RTDN still healthy.
- [ ] Old OpenAI key confirmed revoked; no main-backend or Pipecat process still uses it.
- [ ] Old Gemini and other AI-provider keys revoked; quotas/billing reviewed.
- [ ] Old Pipecat internal key rejected and access logs checked.
- [ ] Old JWT signing key removed after transition/TTL; compromised sessions invalidated.
- [ ] Old encryption keys removed only after versioned migration verification.
- [ ] Old Apple/App Store/APNS, Facebook, and Agora credentials revoked in provider consoles.
- [ ] Old ZeptoMail, SMS, webhook, LibreTranslate, and Zoho credentials revoked or deleted.
- [ ] Railway project/service tokens, deploy hooks, CLI tokens, and unauthorized memberships revoked.
- [ ] Secrets removed from logs, tickets, chat, shell history, CI artifacts, backups, and temporary export files according to retention policy.

## Keeping this document current

1. Update the audit date and counts whenever env access patterns, templates, Docker/deployment config, or service boundaries change.
2. Add every new runtime variable to a committed names-only template in the same pull request; mark it `secret`, `sensitive non-secret`, or `public config` in comments without adding a value.
3. Add CI that compares statically referenced names with templates and fails on undocumented names, while allowing reviewed dynamic-name families.
4. Maintain separate templates/inventories for main backend, video worker, and Pipecat so Railway service scopes stay minimal.
5. Never place live values in this file. Record provider key IDs/fingerprints and ticket references only if they are non-secret and approved.
6. Re-run the Pipecat section as soon as its repository or names-only Railway export is available; until then, do not treat the combined system inventory as complete.
7. Quarterly, verify that unused template/Railway variables are deliberately removed and that no frontend service receives backend secrets.
