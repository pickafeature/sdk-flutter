# Changelog

## 1.0.0

First public release.

- Drop-in `PickAFeatureScreen` widget — list, vote, comment, and submit feature requests
- Separate submission form (`FeatureRequestScreen`) with proper title + description fields
- Upvote and comment APIs (`PickAFeature.upvoteFeedback()`, comment widgets)
- User tracking: identify users by email, name, custom ID, or payment info via `PickAFeature.updateUser()`
- Anonymous device fallback via `device_info_plus` + persisted UUID
- Theming: primary color, text color, border radius, custom copy, optional email field
- Configurable base URL (`PickAFeatureConfig.apiBaseUrl`) for self-hosted backends
- Demo mode (`PickAFeatureConfig.demoMode`) for offline development
