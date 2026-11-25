# HELA --- Production Quality Engineering Guide

## Flutter & Dart \| Android + iOS \| Performance, Security, Discoverability, Reliability

**Purpose:** This document is an engineering standard and implementation
brief for improving the existing HELA Flutter application. It is written
to be given to an AI coding agent (Antigravity) together with the
existing project repository.

**Project context:** HELA is a Sri Lankan travel companion. Its planned
capabilities include destination discovery, AI-generated itineraries,
cultural information, maps, accommodation discovery/booking,
transport/taxi services, restaurants and events. The current repository,
architecture, backend, packages and implementation status must be
inspected before changes are proposed.

**Important:** Do not assume that the app uses Supabase, Firebase,
Riverpod, Bloc, a particular API provider, or any architecture until the
repository proves it. Recommendations below are standards and options,
not permission to replace working project decisions blindly.

------------------------------------------------------------------------

## 0. Instructions for the coding agent

Before changing code:

1.  Inspect the complete repository structure, `pubspec.yaml`, lockfile,
    app entry point, routing, state management, API clients, models,
    assets, Android and iOS configuration, environment configuration,
    tests and CI workflows.
2.  Identify the actual architecture and packages in use. Do not
    introduce duplicate state-management, networking, routing or
    dependency-injection systems.
3.  Run the existing tests, `flutter analyze`, and relevant build checks
    before modifications. Record baseline failures separately from newly
    introduced failures.
4.  Create a concise audit report with:
    -   Current architecture and dependencies.
    -   Existing security-sensitive code and configuration.
    -   Performance risks.
    -   Missing tests and observability.
    -   Existing SEO/ASO/deep-link support, if any.
    -   Prioritized findings: Critical, High, Medium, Low.
5.  Propose a phased implementation plan. Explain risks and affected
    files before broad refactoring.
6.  Make small, reviewable changes. Preserve existing UI, design
    language, business behavior and working features unless a change is
    required and approved.
7.  Do not delete, overwrite, migrate or reset user data, production
    databases, credentials, signing configuration or project files
    without explicit approval.
8.  Do not invent secrets, credentials, API endpoints, domain names,
    bundle IDs, package names, signing fingerprints, privacy claims or
    business rules.
9.  Do not claim a test, scan, build, security control or deployment
    succeeded unless it was actually executed and its result checked.
10. After each phase, run the relevant tests and report changed files,
    commands run, results, remaining risks and manual steps.

**Primary rule:** Audit first; fix verified problems; avoid speculative
rewrites.

------------------------------------------------------------------------

# 1. Quality goals and engineering principles

HELA should be:

-   Fast on mid-range and lower-end supported Android/iOS devices.
-   Smooth during scrolling, transitions, map interactions and itinerary
    generation.
-   Resilient to slow, unavailable or intermittent mobile networks.
-   Secure by design, with authorization enforced by trusted backend
    systems.
-   Respectful of location, identity, travel and booking data.
-   Accessible and usable with different screen sizes, text scaling and
    assistive technology.
-   Observable in production without collecting unnecessary personal
    data.
-   Maintainable through clear boundaries, tests and documented
    decisions.
-   Discoverable through accurate store listings, shareable links and
    useful public web content.

Use measurable baselines rather than claims such as "fully optimized",
"100% secure" or "SEO guaranteed".

# 2. Performance engineering

Official references: - Flutter performance best practices:
https://docs.flutter.dev/perf/best-practices - Flutter performance
overview: https://docs.flutter.dev/perf - Flutter DevTools Performance
view: https://docs.flutter.dev/tools/devtools/performance - Android Core
App Quality:
https://developer.android.com/docs/quality-guidelines/core-app-quality -
Android Vitals: https://developer.android.com/google/play/vitals

## 2.1 Measure before optimizing

-   Profile on physical devices representative of the supported device
    range.
-   Use Flutter DevTools in **profile mode** for frame, CPU, memory and
    network investigations.
-   Use release builds for final performance validation; debug-mode
    timings are not representative of release performance.
-   Record app startup, screen transition, scrolling, image loading, map
    loading, AI request latency, memory and app size.
-   Test both a good network and constrained/intermittent network
    conditions.
-   Compare before/after measurements for every significant
    optimization.

## 2.2 Rendering and widget efficiency

-   Keep `build()` methods lightweight and free of network/database
    work.
-   Avoid unnecessary widget rebuilds. Scope state updates to the
    smallest practical subtree.
-   Use `const` constructors where possible.
-   Use `ListView.builder`, `SliverList`, `GridView.builder` or
    equivalent lazy builders for long lists.
-   Give list items stable keys when item identity matters.
-   Avoid expensive work in `build()`, including sorting large
    collections, parsing large payloads and repeated formatting.
-   Avoid deeply nested layouts where simpler layout structures work.
-   Use `RepaintBoundary` only where profiling shows repaint isolation
    is beneficial; do not add it everywhere.
-   Avoid unnecessary clipping, shadows, opacity layers, intrinsic
    layout passes and oversized effects in frequently rebuilt areas.
-   In animations, avoid repeatedly rebuilding unrelated subtrees. Use
    animation builders efficiently and pass static children where
    appropriate.
-   Dispose controllers, animation controllers, streams, focus nodes and
    other owned resources correctly.
-   Avoid synchronous file, database, image or large JSON work on the UI
    isolate.
-   Move genuinely CPU-intensive work to isolates when profiling proves
    it blocks frames. Do not add isolates for trivial tasks.

## 2.3 Frame targets

-   Aim for smooth 60 Hz rendering on supported devices; a 60 Hz frame
    budget is approximately 16.7 ms.
-   For 120 Hz devices, smooth rendering may require approximately 8.3
    ms per frame.
-   Investigate sustained slow frames and jank instead of optimizing
    isolated outliers without user impact.
-   Flutter's performance guidance discusses build and raster work
    separately; use the DevTools frame chart to determine which side is
    slow.
-   Do not treat these targets as a guarantee across every device, OS or
    workload.

## 2.4 Startup and navigation

-   Keep app initialization minimal.
-   Do not block the first useful screen on non-essential network calls.
-   Defer analytics, optional SDK initialization and non-critical data
    loading where safe.
-   Show a branded loading/skeleton state when data is not immediately
    available.
-   Avoid repeated initialization of clients, repositories and SDKs
    during widget rebuilds.
-   Cache stable configuration and reference data with explicit
    expiry/invalidation rules.
-   Use pagination or incremental loading for large destination, hotel,
    restaurant and event collections.
-   Preserve navigation state where it improves user experience, without
    retaining unbounded data.

## 2.5 Images and media

HELA is image-heavy because destination photography is central to travel
discovery.

-   Prefer appropriately sized, compressed images; do not download
    full-resolution originals for small cards.
-   Use responsive image dimensions and modern formats supported by the
    delivery pipeline.
-   Use thumbnails for lists and load larger assets only on detail
    screens.
-   Provide placeholders, loading states and error fallbacks.
-   Cache images with bounded cache policies; avoid unbounded
    memory/disk caches.
-   Avoid decoding very large images into memory unnecessarily.
-   Use a CDN or image transformation service when justified by traffic
    and cost.
-   Ensure image licensing and usage rights are valid.
-   Avoid embedding huge image files in the application bundle unless
    there is a clear offline requirement.

## 2.6 Networking and API efficiency

-   Reuse configured HTTP clients and connection pools where supported.
-   Set sensible connection, send and receive timeouts.
-   Implement cancellation for requests that are no longer needed (for
    example, changing search queries).
-   Debounce user-driven search requests.
-   Paginate large datasets; request only fields and rows needed by the
    screen.
-   Avoid N+1 API/database queries.
-   Batch requests where the backend supports safe batching.
-   Use caching with clear freshness rules. Never cache private
    booking/user data in a shared cache.
-   Retry only transient failures, with bounded exponential backoff and
    jitter.
-   Do not automatically retry non-idempotent booking/payment operations
    unless the backend supports idempotency.
-   Handle offline, timeout, unauthorized, validation, rate-limit and
    server-error states distinctly.
-   Do not log access tokens, personal data, payment details or full
    sensitive API responses.

## 2.7 AI itinerary and assistant performance

-   Make AI calls through a trusted backend, not directly from a shipped
    mobile client using a secret provider key.
-   Display progress and allow safe cancellation where possible.
-   Set request timeouts and enforce server-side token, request and cost
    limits.
-   Use structured response schemas and validate output before showing
    or saving it.
-   Avoid sending the entire conversation or entire destination database
    on every request.
-   Retrieve only relevant verified destination information.
-   Cache only safe, reusable outputs; do not expose one user's private
    itinerary to another.
-   Store AI generation status and errors clearly.
-   Do not block the UI while generating an itinerary.
-   Provide a useful retry path and preserve user inputs after a failed
    request.

## 2.8 Maps and location performance

-   Request location permission only when a feature needs it.
-   Prefer approximate location when precise location is not necessary.
-   Avoid repeated GPS polling; use the least frequent update rate that
    satisfies the feature.
-   Stop location streams when the relevant screen/feature is no longer
    active.
-   Avoid loading many map markers at once; cluster or query markers by
    visible map bounds when appropriate.
-   Do not request Places/Routes data on every widget rebuild.
-   Cache safe place metadata and respect provider terms, attribution
    and caching restrictions.
-   Provide a manual location/search fallback if permission is denied or
    GPS is unavailable.
-   Track third-party map API usage and billing.

## 2.9 App size, battery and memory

-   Inspect release app size and asset contributions.
-   Remove unused assets and dependencies only after verifying they are
    unused.
-   Use deferred loading only where supported and justified.
-   Avoid unnecessary background tasks, polling and wake locks.
-   Stop timers, streams, sensors and location tracking when not needed.
-   Test memory behavior during long browsing sessions and repeated
    navigation.
-   Check for image memory growth and retained
    controllers/subscriptions.
-   Use platform-specific profiling tools when native plugins are
    involved.

## 2.10 Performance acceptance checks

-   No reproducible crash or ANR in critical user journeys.
-   No persistent UI jank in home, explore, itinerary and map flows on
    target test devices.
-   Lists load incrementally rather than rendering unbounded records.
-   Large images are not downloaded at full size for thumbnails.
-   Network failures do not freeze the app.
-   AI generation does not block UI interaction.
-   Resource subscriptions and controllers are disposed.
-   Record actual startup, frame, memory and release-size measurements;
    compare them to a baseline.

------------------------------------------------------------------------

# 3. Security engineering

Primary standard: - OWASP MASVS: https://mas.owasp.org/MASVS/ - OWASP
MASTG: https://mas.owasp.org/MASTG/ - Supabase API keys:
https://supabase.com/docs/guides/getting-started/api-keys - Supabase Row
Level Security:
https://supabase.com/docs/guides/database/postgres/row-level-security -
Supabase Edge Function secrets:
https://supabase.com/docs/guides/functions/secrets - Supabase Edge
Functions: https://supabase.com/docs/guides/functions - Flutter Dart
obfuscation: https://docs.flutter.dev/deployment/obfuscate

Use OWASP MASVS as a security baseline. Its control groups include
storage, cryptography, authentication, network communication, platform
interaction, code, resilience and privacy. A Flutter app still needs
Android- and iOS-specific security review.

## 3.1 Threat model HELA

Treat these as important assets:

-   User identity, email, phone number and profile.
-   Precise/coarse location and travel history.
-   Saved itineraries and travel preferences.
-   Hotel, taxi, restaurant and event bookings.
-   Payment references and transaction status.
-   Driver/provider identity and operational information.
-   AI conversation history and user-generated content.
-   Backend credentials, signing keys and third-party API secrets.

Consider threats including: - Stolen/reused credentials and account
takeover. - Insecure direct object references (one user accessing
another user's records). - Exposed API keys and backend secrets. - Weak
database policies. - Insecure deep-link handling. - Man-in-the-middle
attacks and unsafe network configuration. - Malicious or manipulated API
input. - Booking/payment replay, duplicate requests and price
tampering. - Excessive permissions and location leakage. -
Dependency/plugin vulnerabilities.

## 3.2 Secrets and API keys

-   Never embed private API keys, service-role keys, payment secrets, AI
    provider secrets, signing passwords or privileged credentials in
    Dart code, assets, remote config or the mobile bundle.
-   A value placed in `.env` and bundled into a mobile app is not
    secret.
-   Keep server secrets in a secure backend secret manager/environment.
-   Rotate any credential that has been committed, shared or exposed.
-   Use separate development, staging and production
    credentials/projects.
-   Restrict public/client keys by platform, application ID, bundle ID,
    API scope and quotas where the provider supports it.
-   Treat every value shipped to a device as extractable.
-   Do not rely on code obfuscation to protect secrets.

**If HELA uses Supabase:** - A publishable key may be used by the client
only with correctly configured authorization and RLS. - Never ship a
Supabase secret/service-role key in the app. It bypasses RLS. - Keep
privileged database operations and third-party secrets in trusted
server-side code/Edge Functions. - Review current Supabase key guidance
before migration because key formats and recommendations can evolve.

## 3.3 Authentication and authorization

-   Use a maintained authentication provider or securely implemented
    server-side authentication flow.
-   Never trust a user ID, role, booking owner, price or permission
    supplied by the client without server-side validation.
-   Enforce authorization on every protected backend operation.
-   Use short-lived access tokens and secure refresh-token handling
    supported by the auth provider.
-   Store sensitive tokens in platform-backed secure storage (Keychain
    on iOS / Android Keystore-backed storage through a maintained
    Flutter plugin).
-   Do not store passwords in local preferences, plain files or logs.
-   Implement logout, token revocation/session invalidation and account
    recovery safely.
-   Add rate limits and abuse controls to login, OTP, password reset and
    sensitive endpoints.
-   Consider MFA for administrative/provider accounts and other
    high-risk operations.
-   Ensure role changes are controlled by trusted server/admin
    workflows, never by a client-side role field.

## 3.4 Database authorization

For every table and endpoint, document: - Who may read it? - Who may
create it? - Who may update it? - Who may delete it? - Which rows belong
to the authenticated user? - Which fields are public? - Which operations
require an administrator/provider role?

If using Supabase/PostgreSQL: - Enable RLS on every table exposed
through the Data API. - Define least-privilege grants and explicit
policies for SELECT, INSERT, UPDATE and DELETE. - Do not assume adding
policies automatically removes broad grants. - Test both allowed and
denied access for `anon` and `authenticated` roles. - Verify users
cannot read or modify another user's itinerary, profile, booking, ride
or private message. - Protect views, functions, RPCs and storage
buckets; review security-definer behavior and execution permissions. -
Use database constraints for invariants such as valid status values and
required ownership relationships. - Add automated RLS tests and run them
in CI where practical.

## 3.5 Booking and payment integrity

For future HELA booking features: - Calculate final prices and
commissions on the trusted backend. - Never accept the client as the
source of truth for fare, discount, availability or payment success. -
Use server-side booking state transitions. - Use idempotency keys for
payment and booking creation where supported. - Verify payment provider
webhooks server-side, including signature and event authenticity. -
Handle duplicate, delayed and out-of-order webhook events. - Never store
raw card details unless the system is specifically designed and
certified to do so; prefer a compliant payment provider's
hosted/tokenized flow. - Keep an auditable transaction/booking
history. - Protect cancellation/refund operations with authorization and
state checks. - Do not mark a booking as paid merely because the mobile
client reports success.

## 3.6 Network security

-   Use HTTPS/TLS for all production API traffic.
-   Never disable certificate validation or accept all certificates in
    production.
-   Do not add broad cleartext HTTP exceptions.
-   Review Android Network Security Configuration and iOS App Transport
    Security exceptions.
-   Avoid logging authorization headers or sensitive request/response
    bodies.
-   Validate server responses and handle malformed payloads safely.
-   Consider certificate pinning only after a threat/risk assessment and
    with a robust certificate rotation/fallback plan; poorly implemented
    pinning can lock users out.
-   Use secure, verified deep links and validate all incoming URL
    parameters.

## 3.7 Local data protection

-   Store only data that the feature genuinely needs.
-   Use platform-backed secure storage for tokens and secrets that must
    be stored on-device.
-   Use normal local preferences only for non-sensitive settings.
-   Protect sensitive cached records and clear them on logout where
    appropriate.
-   Do not put sensitive information in clipboard, screenshots,
    notifications or analytics by default.
-   Avoid exposing private itinerary or booking data in app-switcher
    previews if the threat model requires protection.
-   Do not implement custom cryptography. Use vetted platform/library
    primitives when encryption is required.
-   Define retention and deletion rules for cached data and server
    records.

## 3.8 Input validation and abuse prevention

-   Validate all inputs on both client and server; server validation is
    authoritative.
-   Enforce length, type, format, range and allowed-value limits.
-   Treat AI output, external place data, deep links and user-generated
    content as untrusted.
-   Prevent SQL injection by using parameterized queries/ORM-safe APIs.
-   Sanitize rendered user content and avoid unsafe HTML rendering.
-   Add rate limits and quotas for search, AI generation, OTP, booking
    and upload endpoints.
-   Validate file type, size and ownership for uploads; do not trust
    file extensions alone.
-   Restrict CORS where applicable to actual web clients; CORS is not an
    authorization mechanism for mobile apps.

## 3.9 Privacy and permissions

-   Ask for location, camera, photo, microphone and notification
    permissions only when needed.
-   Explain the feature benefit before requesting sensitive permissions.
-   Provide a useful experience when permission is denied.
-   Collect the minimum data needed for a clear purpose.
-   Define retention, export and account deletion processes.
-   Publish a truthful privacy policy before store submission.
-   Keep Apple App Privacy disclosures and Google Play Data safety
    declarations accurate, including third-party SDK collection.
-   Do not claim "no data collected" without checking all SDKs,
    analytics, crash reporting and backend flows.
-   Avoid collecting precise location in the background unless essential
    and clearly disclosed.
-   Do not send personal identifiers or precise location to AI providers
    unless necessary, disclosed and protected.

## 3.10 Mobile platform and release hardening

-   Keep Flutter SDK, Dart SDK, plugins and native dependencies updated
    with controlled testing.
-   Review dependency provenance, maintenance, permissions and known
    vulnerabilities.
-   Avoid unmaintained or unnecessary plugins.
-   Enable release-mode optimizations and consider Dart obfuscation for
    release builds where appropriate.
-   Preserve symbol files securely for crash de-obfuscation.
-   Understand that obfuscation only makes reverse engineering harder;
    it does not encrypt resources or secure embedded secrets.
-   Protect Android signing keys and iOS certificates/profiles.
-   Do not commit keystores, provisioning profiles, certificates or
    signing passwords.
-   Use CI secret storage for release signing.
-   Review exported Android components, intent filters, iOS URL schemes
    and associated domains.
-   Test on rooted/jailbroken devices only as part of a defined threat
    model; do not use root detection as the sole security control.

------------------------------------------------------------------------

# 4. SEO, ASO and app discoverability

**Important distinction:** Traditional Google SEO primarily applies to
crawlable web pages, not directly to the internal screens of a native
Flutter Android/iOS app. For HELA, use three complementary strategies:

1.  **ASO (App Store Optimization):** Improve discovery and conversion
    on Google Play and Apple App Store.
2.  **Web SEO:** Publish useful, indexable public HELA pages for Sri
    Lankan destinations and travel guides.
3.  **Deep links:** Connect public web URLs, search results, campaigns
    and shared content to the corresponding app screen.

Official references: - Google SEO Starter Guide:
https://developers.google.com/search/docs/fundamentals/seo-starter-guide -
Google Search Central: https://developers.google.com/search - Android
App Links: https://developer.android.com/training/app-links/about -
Apple Universal Links:
https://developer.apple.com/documentation/xcode/supporting-universal-links -
Apple Associated Domains:
https://developer.apple.com/documentation/xcode/supporting-associated-domains -
Apple Product Page Optimization:
https://developer.apple.com/app-store/product-page-optimization/

## 4.1 App Store Optimization (ASO)

Prepare accurate, localized store metadata: - App name: HELA, subject to
store naming rules and availability. - Short description/subtitle:
clearly explain the travel companion value. - Full description: describe
real, currently available features; do not advertise unbuilt taxi/hotel
booking as live. - Relevant keywords: Sri Lanka travel, travel planner,
Sri Lanka guide, destinations, itinerary, cultural guide, subject to
store rules and relevance. - App icon: recognizable at small sizes. -
Screenshots: show actual app screens and benefits, not misleading mock
functionality. - Preview video: demonstrate real user journeys. -
Localization: consider English first, then Sinhala and Tamil where
supported and professionally translated. - Ratings/reviews: ask at
appropriate moments, never incentivize fake reviews or manipulate
ratings. - Monitor store listing conversion, acquisition sources,
ratings and review themes. - Test alternative store creative using
supported store experiments; do not change many variables without a
measurement plan.

Apple Product Page Optimization supports testing product page treatments
such as icons, screenshots and previews. See the official reference
above.

## 4.2 Web SEO for HELA

If HELA has or plans a public website, create indexable pages such as: -
`/destinations/sigiriya` - `/destinations/ella` -
`/destinations/kandy` - `/destinations/galle` -
`/travel-guides/sri-lanka-7-day-itinerary` -
`/travel-guides/sri-lanka-cultural-etiquette` -
`/things-to-do/sri-lanka`

Each page should: - Have a unique, descriptive title and meta
description. - Use one clear primary heading and logical heading
hierarchy. - Provide original, useful, accurate information. - Include
descriptive URLs and internal links. - Use descriptive image alt text. -
Use optimized responsive images. - Include canonical URLs where
duplicate URL variants exist. - Be crawlable and return correct HTTP
status codes. - Have an XML sitemap and robots.txt configured
appropriately. - Avoid thin, duplicated, auto-generated or misleading
pages. - Display author/reviewer and last-updated information where it
adds trust. - Cite reliable sources for historical, cultural, entry-fee
and travel-safety information. - Keep opening hours, prices and
transport information updated; clearly label estimates and last
verification dates.

Use structured data only when the page content genuinely qualifies and
the markup matches visible content. Potential schema types may include
`TouristAttraction`, `Article`, `BreadcrumbList` or `Organization`,
subject to Google's current supported structured-data policies.
Structured data does not guarantee rich results or rankings.

Set up Google Search Console for the website. Monitor indexing, search
queries, impressions, clicks, crawl issues and Core Web Vitals where
applicable.

## 4.3 Deep links and shareable content

Design stable HTTPS URLs for public content, for example: -
`https://<HELA_DOMAIN>/destinations/sigiriya` -
`https://<HELA_DOMAIN>/itinerary/<PUBLIC_SHARE_ID>`

Requirements: - Use Android App Links with verified domain association
(`assetlinks.json`). - Use iOS Universal Links with Associated Domains
and `apple-app-site-association`. - Route each URL to a specific, safe
in-app destination. - If the app is not installed, show a useful web
fallback or store handoff. - Validate every incoming URL, path, query
parameter and identifier. - Do not allow links to execute privileged
actions such as deleting content or revealing private booking data. -
Public itinerary sharing must be opt-in, revocable and use unguessable
share identifiers. - Do not expose private user IDs or sequential
database IDs in public links. - Test installed/not-installed,
logged-in/logged-out and invalid-link cases.

## 4.4 Flutter Web caveat

If a separate HELA website is built, choose an SEO-capable web
architecture for public content. Do not assume that simply compiling the
mobile Flutter app to web automatically gives the best search-engine
experience. A server-rendered or statically generated content website
may be more appropriate for destination articles and landing pages. Keep
the mobile app focused on app interactions.

------------------------------------------------------------------------

# 5. Reliability, offline behavior and error handling

-   Model loading, success, empty, error and retry states explicitly.
-   Use typed errors instead of displaying raw exception messages.
-   Provide retry only where it is safe.
-   Preserve unsent user input during temporary network failure.
-   Cache safe read-only destination content for limited offline access
    if product requirements justify it.
-   Show the freshness/last-updated state for cached information.
-   Never imply a booking/payment succeeded until the backend/provider
    confirms it.
-   Use idempotent server operations for retryable booking/payment
    actions.
-   Handle expired sessions by refreshing or prompting sign-in without
    losing user work.
-   Provide graceful fallbacks when map, AI, location or image providers
    are unavailable.
-   Avoid a single third-party SDK failure preventing unrelated app
    features from loading.
-   Add health monitoring for backend services and third-party
    integration failures.

# 6. Architecture and code quality

Official Flutter architecture recommendations:
https://docs.flutter.dev/app-architecture/recommendations

Follow the architecture already established in the repository unless it
has clear maintainability/security problems.

Recommended principles: - Separate UI from data access and business
logic. - Keep widgets focused on rendering and user interaction. - Use
repositories to isolate data sources. - Use services for external
APIs/platform integrations. - Use immutable models where appropriate. -
Keep state ownership clear and avoid global mutable state. - Inject
dependencies rather than constructing network/database clients
throughout widgets. - Keep secrets and privileged business logic out of
the UI layer. - Avoid unnecessary abstractions and avoid a large rewrite
solely to match a preferred pattern. - Document architectural decisions
that affect future contributors.

If the current app uses MVVM, Bloc, Riverpod, Provider or another
established pattern, improve consistency within that pattern rather than
introducing a second competing system.

# 7. Testing and continuous integration

## 7.1 Required test layers

**Unit tests** - Model serialization/deserialization. - Input validation
and business rules. - Price/fare calculations where applicable. -
Repository behavior using fakes/mocks. - ViewModel/state transitions. -
URL/deep-link parsing and validation.

**Widget tests** - Loading, success, empty and error states. - Forms and
validation. - Navigation and key user journeys. - Accessibility
semantics where practical. - Responsive layout and text scaling.

**Integration tests** - Sign up/sign in/sign out. - Destination
browsing. - Save/edit itinerary. - AI generation failure and retry. -
Map/location permission denial. - Booking flows when implemented. - Deep
links. - Session expiry and recovery.

**Security tests** - RLS allow/deny tests for every exposed table. -
Cross-user access attempts. - Role escalation attempts. - Unauthorized
API requests. - Invalid/malformed inputs. - Deep-link abuse cases. -
Secret scanning and dependency vulnerability checks. - Backend
authorization and payment webhook tests.

## 7.2 Suggested local validation commands

Run from the Flutter project root; adapt only if the repository uses a
documented alternative.

``` bash
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

For Android release validation:

``` bash
flutter build appbundle --release
```

For iOS release validation (requires macOS and suitable Xcode signing
configuration):

``` bash
flutter build ipa --release
```

For performance analysis, use a profile build on a physical device and
Flutter DevTools. Do not use debug-mode frame timings as production
performance evidence.

## 7.3 CI quality gates

Configure CI to: - Install the pinned Flutter/Dart SDK version. -
Resolve dependencies reproducibly. - Run formatter checks. - Run
`flutter analyze`. - Run unit/widget tests. - Run backend/database
policy tests where applicable. - Build Android in a controlled
environment. - Build iOS on macOS runners when configured. - Scan for
committed secrets. - Check dependency advisories. - Retain test/build
artifacts and logs without leaking secrets.

Do not make deployment automatic until release signing, environment
separation, tests and approval rules are established.

------------------------------------------------------------------------

# 8. Monitoring and analytics

Use privacy-conscious observability.

Track technical signals: - Crash-free users/sessions. - ANR rate
(Android). - Startup time. - Slow frames/jank. - Memory pressure. - API
latency and error rate. - AI request latency, failure rate and cost. -
Map/Places/Routes API errors and usage. - Booking/payment failure and
duplicate-operation rate.

Track product signals only where justified: - Onboarding completion. -
Search success. - Destination detail engagement. - Itinerary
creation/save success. - Booking funnel conversion when booking exists.

Rules: - Do not log passwords, tokens, payment data, precise location or
private AI conversations. - Use pseudonymous identifiers where
possible. - Define retention and access restrictions. - Obtain consent
where required. - Document third-party SDK data collection. - Provide a
way to disable optional analytics if product/legal requirements call for
it.

For Android, regularly review Android Vitals in Play Console. For iOS,
use App Store Connect analytics and appropriate crash diagnostics. A
crash reporting SDK can supplement, not replace, platform reporting.

------------------------------------------------------------------------

# 9. Accessibility and internationalization

HELA serves international visitors and should support: - English as the
initial language if that is the product decision. - Sinhala and Tamil
when translations are ready. - Currency formatting based on explicit
currency codes, not device locale alone. - Time zones and local
date/time display for Sri Lanka. - Screen readers and meaningful
semantic labels. - Sufficient text/background contrast. - Text scaling
without clipping. - Touch targets large enough for comfortable use. -
Clear focus order and keyboard behavior where relevant. - RTL readiness
only if languages requiring it are introduced. - Consistent localization
of errors, dates, distances and prices.

Never rely on color alone to communicate status. Do not hardcode
user-facing strings throughout widgets; use the project's localization
approach.

------------------------------------------------------------------------

# 10. HELA-specific data and content quality

Travel information can affect users' safety, time and money.

-   Distinguish verified facts, estimates, AI suggestions and
    user-generated reviews.
-   Store source and `last_verified_at` for important destination facts.
-   Do not let AI invent opening hours, ticket prices, route
    availability or booking confirmation.
-   Validate map coordinates and destination identity.
-   Label approximate travel times and fares as estimates unless
    confirmed by a provider.
-   Provide correction/reporting workflows for outdated destination
    information.
-   Protect private itineraries and location history.
-   Obtain appropriate permission and legal review before collecting
    driver/provider documents or sensitive verification data.
-   Use role-based access for tourist, guide, driver, hotel/restaurant
    partner and administrator functions if those roles are implemented.
-   Keep audit records for privileged changes to fares, bookings,
    partner listings and refunds.

------------------------------------------------------------------------

# 11. Prioritized implementation plan

Do not attempt all improvements in one unreviewed change. Use the
following sequence.

## Phase A --- Repository audit (first)

-   Inspect project and report actual architecture.
-   Run baseline analyze/tests/builds.
-   Identify secrets and risky configuration without printing secret
    values.
-   Map data flows and user roles.
-   Review dependencies and permissions.
-   Produce prioritized findings.

**Exit criteria:** A verified audit report exists; no code has been
unnecessarily rewritten.

## Phase B --- Critical security and reliability

-   Remove exposed privileged secrets and rotate leaked credentials.
-   Verify backend authorization and database policies.
-   Fix cross-user data access.
-   Validate authentication/session handling.
-   Secure sensitive local storage.
-   Ensure HTTPS and safe deep-link parsing.
-   Fix crash-causing defects and unsafe booking state changes.

**Exit criteria:** Critical/high-risk findings are fixed or explicitly
documented with an owner and mitigation.

## Phase C --- Performance baseline and optimization

-   Profile startup and key screens.
-   Fix proven jank/rebuild/image/network issues.
-   Add pagination and bounded caching where needed.
-   Review map/location lifecycle.
-   Measure memory and release app size.

**Exit criteria:** Before/after measurements are documented and no
regressions are introduced.

## Phase D --- Test and monitoring foundation

-   Add unit/widget/integration tests for critical journeys.
-   Add backend authorization tests.
-   Configure CI checks.
-   Configure crash/performance monitoring with privacy safeguards.

**Exit criteria:** Critical flows have repeatable tests and production
diagnostics.

## Phase E --- Discoverability and release readiness

-   Prepare accurate store listing metadata and assets.
-   Publish a public HELA website if product strategy supports it.
-   Add destination pages and Search Console.
-   Configure verified App Links and Universal Links when the domain and
    app IDs are available.
-   Complete privacy policy and store privacy/data declarations.

**Exit criteria:** Store and web content accurately describe released
features; links and privacy disclosures are verified.

------------------------------------------------------------------------

# 12. Definition of Done (release checklist)

A release candidate should not be considered ready until applicable
items below are checked.

## Performance

-   [ ] Profiled on representative physical Android and iOS devices.
-   [ ] No known reproducible critical jank in key journeys.
-   [ ] Startup and screen loading measured.
-   [ ] Lists are paginated/lazy-loaded where needed.
-   [ ] Images are sized and cached appropriately.
-   [ ] Memory, battery and location lifecycle reviewed.
-   [ ] Network failure and slow-network behavior tested.
-   [ ] Release build size recorded.

## Security

-   [ ] No privileged secrets in repository or app bundle.
-   [ ] Exposed credentials rotated if necessary.
-   [ ] Backend authorization enforced for every protected operation.
-   [ ] Database policies/grants reviewed and tested.
-   [ ] Cross-user access tests pass.
-   [ ] Tokens stored using secure platform-backed storage.
-   [ ] HTTPS and platform transport security reviewed.
-   [ ] Deep links validated.
-   [ ] Uploads and user input validated.
-   [ ] Payment/booking operations are server-authoritative (when
    implemented).
-   [ ] Dependency and secret scans reviewed.
-   [ ] Privacy and data-retention practices documented.

## Discoverability

-   [ ] Store title, description, screenshots and icon are accurate.
-   [ ] Store listing does not advertise unavailable features.
-   [ ] Public website pages are useful, crawlable and original (if
    website exists).
-   [ ] Search Console configured (if website exists).
-   [ ] Android App Links verified (if implemented).
-   [ ] iOS Universal Links verified (if implemented).
-   [ ] Public share links do not expose private data.

## Quality

-   [ ] `dart format` check passes.
-   [ ] `flutter analyze` passes or remaining warnings are documented.
-   [ ] Relevant unit/widget/integration tests pass.
-   [ ] Android release build verified.
-   [ ] iOS release build verified on configured macOS/Xcode
    environment.
-   [ ] Crash/ANR monitoring configured.
-   [ ] Privacy policy and store disclosures are accurate.
-   [ ] Manual smoke test completed for critical journeys.

------------------------------------------------------------------------

# 13. Antigravity master implementation prompt

Copy the following prompt into Antigravity after opening the existing
HELA repository and providing this document as project context.

> You are the senior Flutter engineer and mobile application
> security/performance reviewer for HELA.
>
> Read `HELA_Production_Quality_Guide.md` completely and inspect the
> existing repository before making changes.
>
> HELA is an existing Flutter/Dart Android and iOS travel application.
> Your job is to improve the existing codebase safely, not to generate a
> new application or blindly replace its architecture.
>
> **Step 1 --- Audit only:** Inspect the repository, dependencies,
> architecture, routing, state management, API integrations, storage,
> permissions, Android/iOS configuration, tests and CI. Run baseline
> formatting, analysis, tests and relevant builds. Identify security,
> performance, reliability, accessibility and discoverability gaps. Do
> not print secret values.
>
> **Step 2 --- Report:** Create `docs/engineering_audit.md` containing
> actual findings, evidence (file paths and relevant code locations),
> severity, impact, recommended fix, dependencies and verification
> steps. Clearly separate verified defects from potential risks and
> items that cannot be verified.
>
> **Step 3 --- Plan:** Create a prioritized implementation plan.
> Preserve current working features, UI and business rules. Do not add a
> backend or replace packages unless the existing repository and
> requirements justify it. Ask before destructive migrations, production
> changes, credential rotation, major architecture changes or paid
> third-party integrations.
>
> **Step 4 --- Implement incrementally:** Address Critical and High
> issues first, then performance, testing, observability and
> discoverability. Make small changes. Follow the standards and
> acceptance criteria in this guide. Do not claim a control is
> implemented unless the code/configuration and tests demonstrate it.
>
> **Security requirements:** Never embed privileged API keys or secrets
> in the mobile app. Enforce authorization on the backend. If Supabase
> is present, inspect RLS, grants, policies, views, functions and
> storage permissions; do not ship service-role/secret keys. Validate
> all external input and deep links. Protect tokens and private user
> data. Do not treat obfuscation as a security boundary.
>
> **Performance requirements:** Profile in profile/release mode,
> optimize only measured bottlenecks, use lazy lists and appropriately
> sized images, avoid UI-thread blocking, manage
> streams/controllers/location lifecycle, and handle slow/offline
> networks.
>
> **SEO/discoverability requirements:** Do not pretend native Flutter
> screens are directly indexed like website pages. Review ASO, public
> web SEO (only if a website exists or is approved), and verified
> Android App Links/iOS Universal Links. Never invent a domain, package
> ID, bundle ID or signing fingerprint.
>
> **Testing requirements:** Add or update tests for each meaningful
> change. Run formatter, analyzer, relevant tests and available builds.
> For backend changes, include authorization allow/deny tests. Report
> tests that could not run and why.
>
> **Final report:** Summarize changes, files modified, commands run,
> test/build outcomes, measured performance changes, remaining risks,
> required manual configuration and next recommended steps. Do not claim
> production readiness or complete security without evidence.
>
> Work in phases and stop after the audit report and plan for review
> before broad changes. Do not make destructive or production changes
> without approval.

------------------------------------------------------------------------

# 14. Official references and further reading

The recommendations in this guide are based primarily on the following
official standards and vendor documentation. Re-check them when
implementing because platform rules and pricing can change.

## Flutter and Dart

1.  Performance best practices ---
    https://docs.flutter.dev/perf/best-practices
2.  Performance overview --- https://docs.flutter.dev/perf
3.  DevTools Performance view ---
    https://docs.flutter.dev/tools/devtools/performance
4.  Architecture recommendations ---
    https://docs.flutter.dev/app-architecture/recommendations
5.  Architecture guide ---
    https://docs.flutter.dev/app-architecture/guide
6.  Dart obfuscation --- https://docs.flutter.dev/deployment/obfuscate

## Mobile security

7.  OWASP MASVS --- https://mas.owasp.org/MASVS/
8.  OWASP MASTG --- https://mas.owasp.org/MASTG/
9.  Supabase API keys ---
    https://supabase.com/docs/guides/getting-started/api-keys
10. Supabase Row Level Security ---
    https://supabase.com/docs/guides/database/postgres/row-level-security
11. Supabase Edge Function secrets ---
    https://supabase.com/docs/guides/functions/secrets
12. Supabase Edge Functions ---
    https://supabase.com/docs/guides/functions

## Android and Apple quality/privacy

13. Android Core App Quality ---
    https://developer.android.com/docs/quality-guidelines/core-app-quality
14. Android Vitals --- https://developer.android.com/google/play/vitals
15. Android App Links ---
    https://developer.android.com/training/app-links/about
16. Apple App Privacy ---
    https://developer.apple.com/app-store/app-privacy-details/
17. Apple Manage App Privacy ---
    https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
18. Apple Universal Links ---
    https://developer.apple.com/documentation/xcode/supporting-universal-links
19. Apple Associated Domains ---
    https://developer.apple.com/documentation/xcode/supporting-associated-domains
20. Apple Product Page Optimization ---
    https://developer.apple.com/app-store/product-page-optimization/

## Search and web discoverability

21. Google SEO Starter Guide ---
    https://developers.google.com/search/docs/fundamentals/seo-starter-guide
22. Google Search Central --- https://developers.google.com/search

------------------------------------------------------------------------

## Final engineering principle

**Do not optimize by guessing. Inspect, measure, fix, test and
document.**

HELA's performance, security and discoverability must be maintained
continuously as features are added---not treated as a final cleanup task
immediately before launch.
