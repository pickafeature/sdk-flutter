# pick a feature - Flutter SDK

[![pub package](https://img.shields.io/pub/v/pickafeature.svg)](https://pub.dev/packages/pickafeature)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Drop-in feature request, voting, and feedback collection for Flutter apps. Backed by [pickafeature.com](https://pickafeature.com).

Let your users tell you what to build. Ship a polished "Feature Requests" tab in five minutes - no infrastructure to run, no UI to design.

## Features

- **One-line setup** - initialize with your API key, you're live
- **Drop-in widgets** - dialog, bottom sheet, or full-screen browser. Or build your own with the typed API.
- **Voting + comments** - users upvote and discuss, you ship the right things
- **User identity** - attach email, name, custom ID, or revenue tier to every request
- **Anonymous fallback** - device-level identity for users who don't sign in
- **Theming** - primary color, text color, border radius, custom copy
- **Self-host friendly** - configurable base URL

## Install

```yaml
dependencies:
  pickafeature: ^1.0.0
```

```bash
flutter pub get
```

## Get an API key

1. Sign up at [pickafeature.com](https://pickafeature.com)
2. Dashboard → **Projects** → create a project → copy the API key
3. Store it in your app (or pass it through your build config - never check secrets into git)

## Quick start

### Initialize once at startup

```dart
import 'package:flutter/material.dart';
import 'package:pickafeature/pickafeature.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PickAFeature.initialize(
    config: PickAFeatureConfig(
      apiKey: 'YOUR_API_KEY',
    ),
  );

  runApp(const MyApp());
}
```

### Embed the feature requests screen

```dart
PickAFeatureScreen(
  config: PickAFeatureConfig(
    apiKey: 'YOUR_API_KEY',
    customTitle: 'What should we build next?',
    customSubtitle: 'Suggest, vote, comment',
  ),
)
```

The screen shows the full experience: list of approved/completed requests, voting, comments, and a "+" button that opens the submission form.

### Programmatic API

```dart
// List approved + completed requests
final requests = await PickAFeature.getFeedbackRequests();

// Upvote a request
await PickAFeature.upvoteFeedback(requestId);

// Identify the current user (call once after sign-in).
// The email is attached to future feedback submissions so requests
// can be attributed in the dashboard.
await PickAFeature.updateUser(
  email: 'jane@example.com',
  name: 'Jane',
);

// On sign-out, clear the locally cached identity
await PickAFeature.clearUserData();
```

## Theming

```dart
PickAFeatureConfig(
  apiKey: 'YOUR_API_KEY',
  primaryColor: const Color(0xFF6366F1),
  secondaryColor: const Color(0xFF8B5CF6),
  backgroundColor: Colors.white,
  textColor: const Color(0xFF1F2937),
  borderRadius: 12.0,
  customTitle: 'Feature requests',
  customSubtitle: 'Tell us what you need',
  customPlaceholder: 'Describe the feature you want…',
  customSubmitText: 'Submit',
  showEmailField: true,
)
```

## Config options

| Option | Type | Default | Notes |
|---|---|---|---|
| `apiKey` | `String` | _required_ | From your project's API Keys page |
| `apiBaseUrl` | `String` | `https://pickafeature.com/api/v1/sdk` | Override for self-hosted backend |
| `primaryColor` | `Color` | `Colors.blue` | Buttons, accents |
| `secondaryColor` | `Color?` | - | Secondary accents |
| `backgroundColor` | `Color?` | - | Sheet/dialog background |
| `textColor` | `Color?` | - | Body text |
| `borderRadius` | `double` | `12.0` | Card + button corner radius |
| `customTitle` | `String?` | - | Override default screen title |
| `customSubtitle` | `String?` | - | Override default subtitle |
| `customPlaceholder` | `String?` | - | Submission textarea placeholder |
| `customSubmitText` | `String?` | - | Submit button label |
| `showEmailField` | `bool` | `true` | Show an optional email input |
| `demoMode` | `bool` | `false` | Use canned data, no network - handy for screenshots and offline dev |

## Data storage

The SDK persists a few small bits to `shared_preferences`:

- A generated device UUID (anonymous identity)
- The current user object (email, name, custom ID, payment info) if you've called `PickAFeature.updateUser()`

Clear it with:

```dart
await PickAFeature.clearUserData();
```

## Error handling

The widget UIs surface errors via in-context `SnackBar` messages. If you're using the programmatic API directly, calls throw `ApiException` on non-2xx responses - catch it to handle the failure however your app prefers:

```dart
try {
  await PickAFeature.upvoteFeedback(id);
} on ApiException catch (e) {
  // e.statusCode, e.message
}
```

## License

MIT - see [LICENSE](LICENSE).
