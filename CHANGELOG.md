# Changelog

## 1.0.6

- Team replies to a specific comment show indented under it (one level). `Comment` gains `parentId` and `isReply`.

## 1.0.5

- Show a `Team` badge on feature requests the project owner posted from the dashboard and on their replies in the comments, so users can tell them apart from other users' posts. `FeatureRequest` and `Comment` gain an `authorType` field (`user` | `admin`) and an `isTeam` getter.
- Team posts sort to the top of the list, then everything by upvotes as before.
- Requests now send an `x-sdk-version` header. Older SDK versions keep working: the server prefixes team posts and replies with `Team:` for them instead of relying on the badge.

## 1.0.4

- Report the platform (`ios`, `android`, `web`, `macos`, ...) with submissions, votes, and comments so the dashboard can show per-platform statistics. No API or UI changes.

## 1.0.3

- Fix: broken `thumb_up` icon and resulting Row overflow on every feature card. The icon was referenced via the old package name (`packages/wishkit/...`) and never resolved after the rebrand.
- Fix: default `PickAFeatureScreen` title showed `WishKit` when `customTitle` was not set. Now defaults to `Feature requests`.

## 1.0.2

- Docs polish (README, CHANGELOG, pubspec description).

## 1.0.1

- Dropped unused dependencies: `device_info_plus`, `package_info_plus`, `url_launcher`. Smaller install footprint and no out-of-date transitive constraints.

## 1.0.0

First public release.

- Drop-in `PickAFeatureScreen` widget - list, vote, and submit feature requests
- Submission form (`FeatureRequestScreen`) with separate title + description fields
- Programmatic API: `getFeedbackRequests()`, `upvoteFeedback()`
- User identity: `updateUser({email, name})` attaches the user's email to future feedback submissions so requests can be attributed in the dashboard
- Anonymous device fallback - auto-generated UUID persisted with `shared_preferences` for users who don't sign in
- Theming via `PickAFeatureConfig` - colors, border radius, custom copy, optional email field
- Configurable base URL for self-hosted backends
- Typed errors via `ApiException` - `isAuthError`, `isRateLimit`, `isNetworkError`, `retryAfter`
- Demo mode (`PickAFeatureConfig.demoMode`) for offline development
