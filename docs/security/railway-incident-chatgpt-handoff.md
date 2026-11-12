# Railway Incident — ChatGPT Handoff

## Current verified state

- Railway disclosed an October 21, 2026 incident involving possible decryption of a subset of customer environment variables. Sensitive credentials stored before the incident should be rotated.
- Account tier: Railway Hobby. The Postgres Backups page showed no backups; creating new Railway backups requires Pro.
- Railway Postgres and the main backend are Online. The user verified the app loads existing data.
- No database data was deleted or migrated.
- The old database password and old connection URLs must be treated as invalid.
- `DATABASE_PUBLIC_URL` still exists with its regenerated password. A public hostname alone does not grant database access, but the public TCP endpoint remains enabled.
- Durable backend audit: `/Users/air/Desktop/mine/apps/italy_app/docs/security/environment-variable-incident-runbook.md`.
- Audit counts: 217 runtime/test variables; 218 including the executable presence example; 134 template names; 90 code-used names missing from templates; 7 apparently unused template names; 26 credentials/cryptographic secrets; 230-name sanitized backend union.
- Pipecat source was absent from the authorized workspace. Only `PIPECAT_SERVICE_URL`, `PIPECAT_INTERNAL_API_KEY`, and `PIPECAT_REQUEST_TIMEOUT_MS` were observable from the main backend.

## Completed actions

1. Before rotation, the main backend used a fixed `DB_PASSWORD`.
2. `DB_PASSWORD` was changed to the Railway reference `${{Postgres.PGPASSWORD}}`, saved, deployed, and verified Online.
3. Railway Postgres → Database → Config → Connection → **Regenerate Password** was used.
4. Railway confirmed it generated a new password, updated environment variables automatically, redeployed Postgres, and redeployed dependent Railway services.
5. Postgres and the main backend returned Online, and the app works with existing data.

## Database follow-up

- Review Postgres and backend logs for unfamiliar connections, authentication failures, bulk reads/exports, schema or permission changes, and unknown users.
- Determine whether backend `DB_HOST` uses `railway.internal` or a public proxy.
- If public, migrate `DB_HOST` and `DB_PORT` to Postgres references, deploy, and test first. Then disable public database networking if no external client needs it.
- Do not disable the public endpoint until the backend's private connection is verified.

## Next action — AWS/S3

Why: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` can permit S3 data access or mutation. Rotation starts in AWS IAM, not Railway.

1. Open AWS IAM and identify the current IAM principal/access key.
2. Review its permissions and CloudTrail activity.
3. Create a replacement least-privilege access key while the old key remains active.
4. Update the two Railway variables and redeploy.
5. Test harmless S3 upload, download, delete, multipart upload, and signed access.
6. Disable the old key and monitor application/provider logs.
7. Delete the old key after verification.

Never reveal an AWS secret access key. AWS displays a new secret only once.

## Remaining prioritized queue

1. CloudFront signing credentials.
2. Firebase/Google service-account keys.
3. JWT/session signing secret.
4. `PIPECAT_INTERNAL_API_KEY` and Pipecat-only providers.
5. Verify the already-rotated OpenAI key is deployed everywhere and the old key is revoked.
6. `GEMINI_API_KEY`.
7. Apple/App Store/APNS, Facebook, and Agora credentials.
8. Email, SMS, webhooks, and secondary providers.

Four encryption-at-rest keys require versioned dual-decrypt migration, not direct overwrite:

- `APPLE_SIGN_IN_TOKEN_ENCRYPTION_KEY`
- `APP_STORE_NOTIFICATION_ENCRYPTION_KEY`
- `GOOGLE_PLAY_RTDN_ENCRYPTION_KEY`
- `GOOGLE_PLAY_SUBSCRIPTION_TOKEN_ENCRYPTION_KEY`

## Safety rules

- Universal pattern: create replacement → update Railway/dependencies → redeploy → test → revoke old credential → inspect provider logs/billing.
- Do not delete an old credential before replacement verification unless active misuse requires immediate containment.
- Never include secret values, complete connection URLs, private IDs, screenshots, or private-message content in ChatGPT.
- Use variable names, provider key identifiers/fingerprints, status, and timestamps only.
- Do not assume Pipecat is covered until its repository or names-only Railway inventory is supplied.

## User interaction preferences

- Use concise English.
- Explain why before each action.
- Guide one step at a time.
- Avoid screen capture or browser control unless explicitly requested.
- Prefer URLs and instructions for the user to type/click to conserve usage.

## Links and paths

- AWS IAM: https://console.aws.amazon.com/iam/
- Full incident runbook: `/Users/air/Desktop/mine/apps/italy_app/docs/security/environment-variable-incident-runbook.md`
- This handoff: `/Users/air/Desktop/mine/apps/italy_app/docs/security/railway-incident-chatgpt-handoff.md`
