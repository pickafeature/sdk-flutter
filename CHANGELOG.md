# Changelog

## 1.0.0

First public release.

- Drop-in `PickAFeatureScreen` widget — list, vote, and submit feature requests
- Submission form (`FeatureRequestScreen`) with separate title + description fields
- Programmatic API: `getFeedbackRequests()`, `upvoteFeedback()`
- User identity: `updateUser({email, name})` attaches the user's email to future feedback submissions so requests can be attributed in the dashboard
- Anonymous device fallback — auto-generated UUID persisted with `shared_preferences` for users who don't sign in
- Theming via `PickAFeatureConfig` — colors, border radius, custom copy, optional email field
- Configurable base URL for self-hosted backends
- Typed errors via `ApiException` — `isAuthError`, `isRateLimit`, `isNetworkError`, `retryAfter`
- Demo mode (`PickAFeatureConfig.demoMode`) for offline development
