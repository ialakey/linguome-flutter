# LinguoMe Mobile (Flutter)

A cross-platform Flutter app that helps learners turn real-world text into vocabulary practice. Users can sign in, capture text with the camera, generate vocabulary pages, review words, and play mini games.

---

## Table of contents

- [Overview](#overview)
- [Feature highlights](#feature-highlights)
- [Tech stack](#tech-stack)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Environment and configuration](#environment-and-configuration)
- [Setup and run](#setup-and-run)
- [Localization](#localization)
- [Analytics](#analytics)
- [Testing](#testing)
- [Build and release notes](#build-and-release-notes)
- [Troubleshooting](#troubleshooting)
- [Roadmap ideas](#roadmap-ideas)

---

## Overview

LinguoMe Mobile is designed around one primary learning loop:

1. Authenticate with Google (and Apple on iOS).
2. Capture or import text.
3. Create a "page" on the backend.
4. Fetch generated words/definitions.
5. Save words into personal vocabulary with learning status.
6. Practice through in-app views and game flows.

The app supports four locales (English, Russian, French, Japanese), includes onboarding hints, and logs interaction events to Amplitude.

---

## Feature highlights

### Authentication
- Google Sign-In support.
- Apple Sign-In support on iOS.
- Access token + refresh token handling through `Dio` interceptors.

### Text capture and processing
- Camera/gallery integration via `image_picker`.
- On-device OCR via `google_mlkit_text_recognition`.
- Backend page creation from recognized text.

### Vocabulary learning
- Fetch paginated vocabulary items.
- Fetch detailed word definitions.
- Add words to user vocabulary with status metadata.

### Navigation and UX
- Bottom navigation: Home, Search, Camera action, Games, Profile.
- Intro/tutorial overlays for first-time users.
- Quick alerts for loading and error states.

### Internationalization
- ARB-based translations (`en`, `ru`, `fr`, `ja`).
- Locale persisted with user data in `SharedPreferences`.

---

## Tech stack

- **Framework:** Flutter (Dart)
- **State management:** `provider`
- **HTTP client:** `dio`
- **Storage:** `shared_preferences`
- **OCR:** `google_mlkit_text_recognition`
- **Sign-in:** `google_sign_in`, `sign_in_with_apple`
- **Analytics:** `amplitude_flutter`
- **UI utilities:** `quickalert`, `flutter_intro`, `flutter_spinkit`
- **Testing:** `flutter_test`

Full dependency list is in `pubspec.yaml`.

---

## Architecture

The app uses a modular Flutter structure:

- `config/` — constants, app colors, language/level metadata.
- `entities/` — JSON-serializable domain models.
- `providers/` — app-wide state objects (language/user/time spent).
- `services/` — API access and orchestration logic.
- `screens/` — route-level UI.
- `widgets/` — reusable UI components.

### Data flow (high-level)

```text
UI (Screen/Widget)
   -> Handler/Service layer
      -> Dio client (with auth interceptor)
         -> REST API
      <- JSON response
   <- entities mapped into UI models
```

### Core service responsibilities

- **`AuthService`**
  - `POST /authorize`
  - `POST /refresh`
  - `GET /User`
  - `POST /logout`
  - `GET /version`
- **`PageService`**
  - `POST /Page`
  - `GET /Page`
  - `DELETE /Page/{id}`
- **`WordService`**
  - `GET /Vocabulary`
  - `GET /Word/{word}`
  - `GET /WordList?page={id}&sort=level&wait-until-ready=true`
  - `POST /Vocabulary`

---

## Project structure

```text
lib/
  config/
  entities/
  helper/
  localizations/
  l10n/
  providers/
  screens/
    games/
  services/
  widgets/
  main.dart
assets/
  games_data/
  icons/
  images/
  premium_icons/
  woods/
fonts/
android/
ios/
test/
```

---

## Prerequisites

- Flutter SDK `>=3.2.4 <4.0.0`
- Dart SDK compatible with the Flutter version
- Android Studio/Xcode (depending on target platform)
- CocoaPods for iOS builds
- A backend environment compatible with the API routes above

---

## Environment and configuration

App runtime constants are defined in:

- `lib/config/app_config.dart`

Before running in a real environment, configure at minimum:

- `baseUrlApi` (required)
- `googleClientId`
- `appleClientId`
- `authAppleClientId`
- `amplitudeApiKey`

Current repository values are placeholders/empty for sensitive fields.

### Recommended config approach

For production hardening, avoid shipping secrets directly in source:

- Prefer `--dart-define` for build-time injection.
- Or generate environment-specific config files in CI/CD.

---

## Setup and run

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Validate toolchain

```bash
flutter doctor
```

### 3) Run app

```bash
flutter run
```

### 4) Run unit/widget tests

```bash
flutter test
```

---

## Localization

Translation files:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_ru.arb`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_ja.arb`

Supported locales are declared in `lib/config/language_config.dart`.

If you add new user-facing strings:

1. Add keys to ARB files.
2. Update localization usage in widgets/screens.
3. Verify fallback behavior.
4. Add/update localization tests.

---

## Analytics

Amplitude is initialized via `AmplitudeManager`.

Typical events include:

- Startup events (Android/iOS device model/name)
- Login button taps
- Bottom navigation interactions
- OCR/page creation lifecycle events

Set `amplitudeApiKey` in config before expecting events in your Amplitude project.

---

## Testing

Current tests include:

- Localization tests
- Widget tests
- Screen/widget-specific rendering tests

Location:

- `test/`

Recommended additions:

- Service layer tests with mocked `Dio`
- Provider behavior tests for locale and user persistence
- End-to-end flow tests for OCR -> page -> vocabulary

---

## Build and release notes

- Android Fastlane files exist under `android/fastlane/`.
- Android package id currently points to `me.linguo.mobile`.
- iOS project files are in `ios/Runner*`.

Before release, verify:

- API endpoints and auth credentials
- Privacy policy / Terms links
- Sign-In entitlements and OAuth configuration
- Store metadata and screenshots

---

## Troubleshooting

### App starts but API calls fail
- Check `AppConfig.baseUrlApi` is non-empty and reachable.
- Confirm SSL/network policies for emulator/device.

### Google/Apple sign-in not working
- Validate SHA fingerprints (Android) and Bundle ID (iOS).
- Check OAuth client IDs in `AppConfig` and platform config.

### OCR returns empty text
- Test with higher-contrast images.
- Ensure camera/gallery permissions are granted.

### Locale does not persist
- Confirm user object is saved correctly in `SharedPreferences`.

---

## Roadmap ideas

- Replace hardcoded config with strongly-typed environment flavors.
- Improve error handling and standardize logging.
- Add repository pattern + dependency injection for testability.
- Introduce API contract validation and typed response wrappers.
- Add CI for formatting, linting, and automated tests.

---
