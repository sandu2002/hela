# HELA Engineering Audit Report

**Prepared by:** Antigravity (AI Code Review)  
**Date:** 2026-11-25  
**Baseline:** `flutter analyze` → No issues found | `flutter test` → 72/72 passed  
**Guide followed:** `docs/HELA_Production_Quality_Guide.md`

---

## 1. Actual Architecture (What We Found)

| Concern | What HELA Actually Uses |
|---|---|
| **State management** | Custom `ChangeNotifier` + `InheritedNotifier` (`HelaAppStateProvider`, `TourPlannerStateProvider`) — no Riverpod, Bloc, or Provider package |
| **Navigation** | `MaterialApp` with implicit `Navigator.push` — no go_router or auto_route |
| **Networking** | `http` package (not Dio) — no interceptors, no retry logic |
| **AI** | `google_generative_ai` SDK — called **directly from the mobile client** using `GEMINI_API_KEY` |
| **Auth** | Custom `InsForgeAuthService` (BaaS) — tokens stored in `SharedPreferences` (plain, not Keychain/Keystore) |
| **Maps** | `flutter_map` (OpenStreetMap/Nominatim/Overpass) — no Google Maps SDK |
| **Local storage** | `shared_preferences` only — no Hive, Isar, SQLite |
| **Location** | `geolocator` |
| **Localization** | Custom two-tier map (`LocalizationService` + `LocalizationAppStrings`) — no flutter_localizations/intl |
| **Image loading** | `Image.network` with no caching package (no cached_network_image) |
| **CI** | ❌ None detected — no `.github/workflows/` |
| **Tests** | 11 test files, 72 tests (widget + unit) — no integration tests |
| **Analytics/Crash** | ❌ None — no Firebase, Sentry, or similar |

---

## 2. Findings by Severity

### 🔴 CRITICAL

#### C-1 · Gemini API Key called directly from mobile client
**File:** `lib/services/ai_service.dart` lines 28–48 | `lib/config/api_config.dart` line 6  
**Evidence:** `GenerativeModel(apiKey: ApiConfig.geminiApiKey)` — `geminiApiKey` resolves to `String.fromEnvironment('GEMINI_API_KEY')` which is **baked into the binary** at build time.  
**Risk:** Any user with `apktool` / `strings` on the binary can extract the key. It can be used to run up unlimited Gemini API costs.  
**Guide ref:** §2.7, §3.2 — "Make AI calls through a trusted backend, not directly from a shipped mobile client using a secret provider key."  
**Fix:** Proxy all Gemini calls through the `hela-backend` (Node.js). The app sends user preferences → backend holds the key → returns AI response.

---

#### C-2 · Auth tokens stored in SharedPreferences (plain, unencrypted)
**File:** `lib/services/insforge_auth_service.dart` lines 405–410  
**Evidence:** `prefs.setString(_keyAccessToken, accessToken)` — `SharedPreferences` on Android is a plain XML file readable by any process with the same UID on a rooted device; on iOS it is an unencrypted `.plist`.  
**Risk:** Tokens extractable on rooted/jailbroken devices.  
**Guide ref:** §3.3 — "Store sensitive tokens in platform-backed secure storage (Keychain on iOS / Android Keystore-backed storage through a maintained Flutter plugin)."  
**Fix:** Replace with `flutter_secure_storage` package for `_keyAccessToken` and `_keyRefreshToken`. Non-sensitive user profile cache can stay in SharedPreferences.

---

#### C-3 · Social OAuth uses a deterministic password derived from email hash
**File:** `lib/services/insforge_auth_service.dart` lines 337–358  
**Evidence:** `password: 'InsForgeOAuth_${email.hashCode.abs()}'` — this creates a fake-password account for every social sign-in. Any party who knows a user's email can compute this password trivially and sign in as them.  
**Risk:** Full account takeover for any user who signed in with Google/GitHub.  
**Guide ref:** §3.3 — "Use a maintained authentication provider or securely implemented server-side authentication flow."  
**Fix:** Use InsForge's proper PKCE OAuth flow (`initiateOAuth` → `exchangeOAuthCode`) already partially implemented in the same file. Remove `signInWithSocialAccount` and wire the OAuth callback properly.

---

### 🟠 HIGH

#### H-1 · No session expiry / token refresh logic
**File:** `lib/services/insforge_auth_service.dart`  
**Evidence:** `restoreSession()` loads a token from storage and uses it forever — no expiry check, no refresh call, no re-authentication prompt.  
**Risk:** Expired/revoked tokens will silently fail API calls, locking out users with no recovery path.  
**Guide ref:** §5 — "Handle expired sessions by refreshing or prompting sign-in without losing user work."  
**Fix:** Add token expiry check on restore; implement token refresh using `_refreshToken`; show sign-in dialog on 401 responses.

---

#### H-2 · No HTTP request timeouts on networking calls
**File:** `lib/services/insforge_auth_service.dart`, `lib/services/live_weather_service.dart`, `lib/services/place_service.dart`  
**Evidence:** `http.post(uri, ...)` — no `.timeout()` calls on most HTTP requests (AI service has 60s timeout; auth service has only sign-out timeout).  
**Risk:** App can hang indefinitely on slow/dead networks. Violates §2.6 — "Set sensible connection, send and receive timeouts."  
**Fix:** Wrap all `http.get/post/delete` calls in `.timeout(const Duration(seconds: 15))` with typed error handling.

---

#### H-3 · Images loaded with `Image.network` — no caching
**File:** Multiple pages (`home_page.dart`, `place_details_page.dart`, `itinerary_details_page.dart`, etc.)  
**Evidence:** No `cached_network_image` or equivalent package in `pubspec.yaml`. Every navigation rebuilds and re-downloads images.  
**Risk:** High bandwidth usage, slow perceived performance, broken images on slow networks. Guide ref: §2.5 — "Cache images with bounded cache policies."  
**Fix:** Add `cached_network_image: ^3.4.1` to pubspec. Replace `Image.network(url)` with `CachedNetworkImage(imageUrl: url, placeholder: ..., errorWidget: ...)`.

---

#### H-4 · `pubspec.yaml` description is a placeholder
**File:** `pubspec.yaml` line 2  
**Evidence:** `description: "A new Flutter project."` — this is the Flutter default.  
**Risk:** Affects ASO (App Store metadata) and store listing quality. Guide ref: §4.1.  
**Fix:** Update to something like `"HELA — Your AI Sri Lanka travel companion: itineraries, destinations & cultural guides."` Also update `version: 1.0.0+1` and `name:` for store submission.

---

#### H-5 · Android app label is lowercase "hela"
**File:** `android/app/src/main/AndroidManifest.xml` line 5  
**Evidence:** `android:label="hela"` — lowercase, no branding.  
**Risk:** Poor ASO; Play Store title shown as "hela". Guide ref: §4.1.  
**Fix:** Change to `android:label="HELA — Sri Lanka Travel"` or at minimum `"HELA"`.

---

#### H-6 · iOS CFBundleName is lowercase "hela"
**File:** `ios/Runner/Info.plist` line 17  
**Evidence:** `<string>hela</string>` for `CFBundleName`. `CFBundleDisplayName` is "Hela" (mixed case).  
**Risk:** App appears as "hela" in some iOS contexts. Inconsistent branding.  
**Fix:** Set `CFBundleName` to `HELA` and ensure `CFBundleDisplayName` is `HELA`.

---

### 🟡 MEDIUM

#### M-1 · No crash reporting or monitoring
**Evidence:** No Firebase Crashlytics, Sentry, or any crash SDK in `pubspec.yaml`.  
**Risk:** Production crashes are invisible. Guide ref: §8.  
**Fix (Phase D):** Add `firebase_crashlytics` or `sentry_flutter`. Configure in `main()` to capture Flutter/platform errors.

---

#### M-2 · No CI/CD pipeline
**Evidence:** No `.github/workflows/` directory found.  
**Risk:** Code quality gates (analyze, test, format) are not enforced automatically. Guide ref: §7.3.  
**Fix (Phase D):** Add `.github/workflows/ci.yml` running `dart format`, `flutter analyze`, `flutter test`, and Android `flutter build appbundle --release`.

---

#### M-3 · `analysis_options.yaml` uses only base flutter_lints — no strictness
**File:** `analysis_options.yaml`  
**Evidence:** Only `include: package:flutter_lints/flutter.yaml` with no additional rules enabled. No `avoid_print`, no `prefer_const_constructors` enforced.  
**Risk:** Lint gaps allow print statements, non-const widgets, unused imports etc. Guide ref: §6.  
**Fix:** Add targeted rules: `avoid_print: true`, `prefer_const_constructors: true`, `prefer_const_literals_to_create_immutables: true`.

---

#### M-4 · State not persisted across app restarts (Saves, Tours, Bookmarks)
**File:** `lib/state/app_state.dart`  
**Evidence:** `_savedHavens`, `_savedTours`, `_savedExperiences`, `_savedStays` are plain in-memory `List`s — no SharedPreferences or database persistence. Only language preference is saved.  
**Risk:** All saved items and tours are lost when the app is killed. Poor UX for a travel app.  
**Guide ref:** §5 — "Cache safe read-only destination content."  
**Fix (Phase C/D):** Serialize saved tours and favorites to SharedPreferences (JSON) or SQLite on change; restore on startup.

---

#### M-5 · No loading/empty/error states for most pages
**Files:** `pages/explore_page.dart`, `pages/bookings_page.dart`, `pages/stays_page.dart`, `pages/saved_page.dart`, `pages/fair_ride_page.dart`  
**Evidence:** These pages appear to show static/hardcoded data with no network state machine.  
**Risk:** When real data sources are wired, there's no skeleton/loading/error/empty handling. Guide ref: §5 — "Model loading, success, empty, error and retry states explicitly."  
**Fix:** Add `AsyncStateWidget` or similar pattern with loading shimmer, error retry, and empty-state illustrations.

---

#### M-6 · No deep link / App Link configuration
**Evidence:** `AndroidManifest.xml` has no `<intent-filter>` for `android.intent.action.VIEW` with HTTPS scheme. No `apple-app-site-association` or Associated Domains in Info.plist.  
**Risk:** Shareable itinerary links and destination URLs cannot open the app. Guide ref: §4.3.  
**Fix (Phase E):** Define HELA's URL scheme (requires a domain), add `assetlinks.json` to backend, configure Android App Links and iOS Universal Links.

---

#### M-7 · No input validation on sign-up form
**File:** `lib/pages/auth/signup_page.dart`  
**Evidence:** Server-side errors from InsForge are surfaced, but client-side password strength, email format, and name length checks are not visible in the service layer.  
**Risk:** Weak passwords accepted silently; poor UX before server round-trip.  
**Guide ref:** §3.8 — "Validate all inputs on both client and server."  
**Fix:** Add client-side validators: email regex, password minimum 8 chars with complexity hint, name max 100 chars.

---

#### M-8 · AI prompt includes full current plan JSON on every customization
**File:** `lib/services/ai_service.dart` line 270  
**Evidence:** `final currentPlanJson = jsonEncode(currentPlan.toJson())` — entire plan serialized and injected into every customization prompt.  
**Risk:** For long multi-day plans, this bloats token usage significantly. Guide ref: §2.7 — "Avoid sending the entire conversation or entire destination database on every request."  
**Fix:** Send only the affected day(s) for `focusedDayNumber` requests; send metadata summary + changed sections only.

---

### 🔵 LOW

#### L-1 · Hardcoded demo profile data in app state
**File:** `lib/state/app_state.dart` lines 197–202  
**Evidence:** `_userName = 'Kavinda Wickramasinghe'`, `_userEmail = 'kavinda.w@gmail.com'` etc. These are real-looking personal data hardcoded as defaults.  
**Risk:** Could appear in screenshots/demos; confusing for new users who haven't signed in.  
**Fix:** Change defaults to `'Explorer'`, `''`, `''` etc.

---

#### L-2 · `geminiModel` references non-verified model names
**File:** `lib/config/api_config.dart` lines 9, 12, 15  
**Evidence:** `'gemini-3.6-flash'`, `'gemini-3.5-flash'`, `'gemini-3.5-flash-lite'` — verify these identifiers against current Gemini API documentation.  
**Risk:** `StateError: All Gemini models failed` for all users if model names are invalid.  
**Fix:** Verify model IDs against the Gemini API model list and update accordingly.

---

#### L-3 · `dart_defines.json` exists in the project directory
**File:** `hela-mobile/dart_defines.json`  
**Evidence:** File exists locally. It is correctly `.gitignored` but its presence means the actual API key is on disk.  
**Risk:** If OneDrive syncs it (observed in this project), it could appear in cloud backup.  
**Fix:** Confirm `dart_defines.json` is excluded from OneDrive sync folder or use environment variables in CI instead.

---

#### L-4 · No integration tests
**Evidence:** 11 test files are all widget/unit tests. No `integration_test/` directory.  
**Guide ref:** §7.1 — Required test layers include integration tests for sign-in, itinerary, AI retry, map permission denial.  
**Fix (Phase D):** Add `integration_test` package; create basic smoke tests for onboarding → home → trip planner → itinerary flow.

---

## 3. What Is Working Well ✅

- `flutter analyze` and `flutter test` both pass clean (72/72)
- Gemini API key is correctly loaded via `--dart-define-from-file` (not hardcoded in Dart source)
- AI service has a 3-tier fallback model chain with 60s timeout
- AI service has a curated offline fallback plan for network failures
- PKCE OAuth flow correctly implemented (code verifier + SHA256 challenge)
- Location permission is `WhenInUse` only — no over-permission
- All API URLs use HTTPS
- Language preference persisted to SharedPreferences
- InheritedNotifier state architecture is clean and testable
- OpenStreetMap/Nominatim used instead of paid Google Maps SDK — cost-conscious
- `dart_defines.json` correctly gitignored

---

## 4. Prioritized Implementation Plan

Following the guide's Phase A→E structure:

### Phase A — Audit (THIS DOCUMENT) ✅
Exit criteria met: audit exists, no code changed.

---

### Phase B — Critical Security & Reliability
> Fix Critical and High issues. **Requires approval before starting.**

| Priority | Task | Files | Effort |
|---|---|---|---|
| **P0** | Proxy Gemini calls through hela-backend | `ai_service.dart`, `api_config.dart`, backend | High |
| **P0** | Migrate auth tokens to `flutter_secure_storage` | `insforge_auth_service.dart`, `pubspec.yaml` | Low |
| **P0** | Remove/replace `signInWithSocialAccount` deterministic password | `insforge_auth_service.dart`, signup_page | Medium |
| **P1** | Add token refresh + session expiry handling | `insforge_auth_service.dart` | Medium |
| **P1** | Add HTTP timeouts to all requests | `insforge_auth_service.dart`, `place_service.dart`, `live_weather_service.dart` | Low |
| **P1** | Fix app name/label in Manifest, Info.plist, pubspec | 3 files | Low |
| **P1** | Add client-side sign-up input validation | `signup_page.dart` | Low |

---

### Phase C — Performance Baseline

| Priority | Task | Files | Effort |
|---|---|---|---|
| **P1** | Add `cached_network_image` for all Image.network | pubspec + all pages | Medium |
| **P2** | Persist saved tours/havens to SharedPreferences | `app_state.dart` | Medium |
| **P2** | Reduce AI customization prompt size (send delta, not full JSON) | `ai_service.dart` | Low |
| **P2** | Verify Gemini model name identifiers | `api_config.dart` | Low |
| **P3** | Profile startup and scrolling on physical device | — | Measure first |

---

### Phase D — Testing & Monitoring

| Priority | Task | Effort |
|---|---|---|
| **P2** | Add crash reporting (Crashlytics or Sentry) | Medium |
| **P2** | Set up GitHub Actions CI pipeline | Low |
| **P2** | Strengthen `analysis_options.yaml` | Low |
| **P2** | Add integration smoke tests | Medium |
| **P3** | Add loading/error/empty states to static pages | Medium |

---

### Phase E — Discoverability & Release Readiness

| Priority | Task | Effort |
|---|---|---|
| **P2** | Update pubspec description + version for store | Low |
| **P3** | Configure Android App Links + iOS Universal Links | High |
| **P3** | Prepare ASO: screenshots, icon review, store description | Medium |
| **P3** | Privacy policy + Play/AppStore data declarations | Medium |

---

## 5. Definition of Done — Current Status

| Check | Status |
|---|---|
| `dart format` passes | ✅ (manual — no CI yet) |
| `flutter analyze` passes | ✅ Verified |
| All unit/widget tests pass | ✅ 72/72 |
| No privileged secrets in repo | ✅ `dart_defines.json` gitignored |
| Backend authorization enforced | ⚠️ Not inspected (hela-backend/) |
| Tokens in secure storage | ❌ SharedPreferences only |
| HTTPS for all API traffic | ✅ All URLs use HTTPS |
| Android release build verified | ❌ Not run |
| iOS release build verified | ❌ Not run |
| Crash monitoring configured | ❌ None |
| Store listing accurate | ❌ Placeholder description |
| Privacy policy exists | ❌ Not found |
| CI configured | ❌ None |

---

*This report reflects the state of the codebase as of 2026-11-25. No code has been modified.  
Approval is required before beginning Phase B implementation.*
