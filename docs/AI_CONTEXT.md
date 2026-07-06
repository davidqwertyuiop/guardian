# Guardian AI Context

Last updated: July 2026

This document captures the working product, architecture, and codebase context for Guardian. Use it as the first project brief for Codex, AI IDE agents, or contributors before making code changes.

## Product Mission

Guardian is a family safety and real-time location platform. The product should help trusted people know where loved ones are, whether they arrived safely, and what to do during emergencies.

Guardian should not feel like a social network or a generic map app. Location sharing is the foundation, but the core value is safety, reassurance, and emergency coordination.

## MVP Scope

Build the MVP around a small number of dependable flows:

- Phone-number authentication and OTP verification.
- User profile setup.
- Family or trusted circles.
- Invite and join circle flows.
- Live location sharing.
- Last seen, online/offline, battery, and basic device context.
- "I'm heading out" journey/broadcasting flow.
- SOS flow with a short countdown and cancel affordance.
- Push notifications for SOS, arrival, journey, and circle events.
- Basic settings and profile management.

Avoid adding these to the MVP unless explicitly requested:

- Full blockchain implementation.
- Complex AI or smart prediction.
- Chat, calls, social feed, public groups, or stories.
- Advanced theft recovery.
- Admin portal.
- Billing/subscriptions.
- Watch apps, widgets, and Live Activities.
- Complex geofencing.

## Roadmap

Guardian 2.0 can add:

- Device recovery.
- Guardian Plus.
- Subscriptions and billing.
- Timeline/history.
- Geofencing.
- Smart alerts.
- Analytics/AI.
- Watch app.
- iOS and Android widgets.
- Support tooling.
- Admin operations.
- Blockchain audit.

Treat these as future modules. Do not let them complicate the MVP UI or backend paths unless the current task is explicitly about those areas.

## Technical Direction

The preferred architecture is:

```text
Flutter mobile app
  -> Rust Axum API
  -> PostgreSQL / Redis / push services / audit services
```

The mobile app should not directly access sensitive location tables. Keep sensitive authorization, location access rules, SOS actions, audit logs, and journey state behind the Rust API.

Current confirmed stack from the repo:

- Mobile: Flutter and Dart.
- State management: BLoC / flutter_bloc.
- Maps/location: google_maps_flutter, apple_maps_flutter, geolocator, geocoding.
- Auth/messaging: Firebase Auth, Firebase Core, Firebase Messaging.
- Local security: flutter_secure_storage, token manager, device integrity, certificate pinning.
- Backend: Rust, Axum, Tokio, SQLx, PostgreSQL.
- Backend auth/security: firebase-auth, jsonwebtoken, argon2, sha2.
- Observability: tracing and tracing-subscriber.
- Deployment: Docker, Render config, Codemagic config, GitHub Actions.

## Security Principles

Guardian handles sensitive data, so security is product-critical.

- Use Rust backend APIs for all sensitive workflows.
- Do not expose PostgreSQL directly to Flutter.
- Store service-role keys only on the backend.
- Use TLS for all network calls.
- Use JWT access tokens and refresh tokens.
- Use Argon2id for password hashing if password auth is introduced.
- Rate-limit OTP, login, registration, SOS, and location endpoints.
- Log audit events for login, invite, permission, location access, SOS, and journey changes.
- Encrypt sensitive location/SOS data before or at database storage when possible.
- Keep secrets in environment variables or a secret manager.
- Treat device trust, MFA, anomaly detection, and risk scoring as later hardening layers.

Blockchain should not store live GPS data. If blockchain is added, use it for tamper-evident audit proofs only:

```text
Private event record in PostgreSQL
  -> hash/proof
  -> blockchain audit ledger
```

Good blockchain candidates are SOS proofs, permission changes, revocations, device ownership proofs, and high-value audit records.

## Current Repository Shape

Top-level repo:

```text
apps/
  backend/
  mobile/
  admin_panel/
docs/
  code_reference/
infrastructure/
scripts/
```

The mobile app currently uses a feature-oriented Flutter structure:

```text
apps/mobile/lib/
  bootstrap/
  core/
    constants/
    security/
    services/
    theme/
    utils/
    widgets/
  features/
    alerts/
    analytics/
    auth/
    billing/
    circles/
    device_recovery/
    emergency/
    family/
    geofencing/
    home/
    journey/
    location/
    map/
    notifications/
    settings/
    sos/
    subscriptions/
    support/
```

The backend currently uses a domain-oriented Rust structure:

```text
apps/backend/src/
  config/
  domains/
    identity/
    circles/
    location/
    journey/
    sos/
    notifications/
    device_recovery/
    geofencing/
    smart_alerts/
    blockchain_audit/
    billing/
    subscriptions/
    analytics/
    admin/
    support/
  infrastructure/
  routes/
  shared/
  websocket/
  workers/
```

This mostly matches the intended modular-monolith direction. Prefer improving these boundaries over introducing microservices.

## Mobile Architecture Guidance

Keep feature folders consistent:

```text
feature/
  data/
  domain/
  presentation/
    bloc/
    screens/
    widgets/
  di/
```

Prefer:

- Small presentation widgets.
- BLoC for feature state and events.
- Repositories/services for API calls.
- Reusable widgets for shared controls.
- Clear UI state enums instead of many nested booleans.

Avoid:

- Large screens with many duplicated UI blocks.
- Business logic inside widgets.
- Direct API calls scattered through many widgets when a service/repository already exists.
- Rebuilding map widgets unnecessarily.

## Home And Map UI Direction

The home screen should support three clear visual states:

```dart
enum HomeViewState {
  home,
  broadcast,
  broadcastExpanded,
}
```

The repo currently has a lower-level map state enum:

```dart
enum MapDisplayState {
  compact,
  expanded,
  full,
}
```

That is useful for the map card, but the screen-level UI should still be reasoned about as:

- Normal home: welcome/header, compact map, circle card, heading-out CTA, SOS feed.
- Broadcasting: broadcast banner, stop button, compact map, circle card, SOS feed.
- Broadcast expanded: focused map overlay, top bar/search, gradient bottom controls, broadcast banner, stop button, circle summary.

Important current code note:

- `apps/mobile/lib/features/location/presentation/screens/live_map_screen.dart` currently duplicates the broadcast banner and Stop button in both the scroll content and the full-map overlay. If polishing the UI, extract these into reusable widgets and make the three screen states explicit.

The intended map behavior:

- Tapping the map in normal home expands it slightly in-place.
- Tapping the map during broadcasting opens a focused/full map state.
- The notification and SOS controls remain available as floating controls.
- The map should feel like Apple Maps / Find My / Life360: focused when needed, but not a separate disconnected page.

## Figma Screenshot Context

The latest Figma screenshots define seven design areas. Treat these screenshots as the visual source of truth when working on presentation code.

### 1. Onboarding Setup

The onboarding flow includes splash/welcome, phone entry, OTP, profile/name setup, permission prompts, circle setup, invite/join flows, and completion states.

Implementation expectations:

- Must be adaptive across iPhone-style and Android-style screen sizes.
- Use native-feeling spacing, safe areas, keyboard avoidance, and bottom sheets.
- Keep forms simple and high-contrast.
- OTP should be ready for Firebase/Auth provider integration.
- Permission screens should explain why Guardian needs location and notifications.
- Circle setup should offer create circle, invite member, paste/join link, and empty/ready states.

### 2. Home Page And Broadcasting

The home page has a compact safety dashboard style:

- Greeting/header.
- Notification and SOS controls.
- Compact map card.
- Circle/member summary.
- "I'm heading out" CTA.
- SOS/broadcast feed.
- Bottom navigation.

Broadcasting changes the same screen, not a separate page:

- Hide or replace the normal heading-out CTA.
- Show a strong orange broadcasting status banner.
- Show a black Stop button.
- Keep the map and circle context visible.
- When the map is tapped during broadcasting, move into a focused map/broadcast view.

The current Flutter implementation should be aligned to these Figma states instead of trying to let one long `Column` handle every visual mode.

### 3. SOS And Heading-Out Sheets

The SOS flow uses bottom sheets/cards:

- "You're live" confirmation after live broadcast starts.
- "Stop broadcasting?" confirmation.
- "Activating SOS..." progress/countdown state.
- "SOS active" state with emergency details and cancel/resolve action.
- "SOS cancelled" completion state.

Implementation expectations:

- SOS should not trigger instantly without a short cancel window.
- Emergency states should be visually distinct from normal broadcasting.
- The active SOS sheet should show location/update status and clear actions.
- Heading-out should open a small flow/sheet, then transition into broadcasting.

### 4. Member Detail UI

When a user taps a member in their circle, the UI should show a member-focused detail card/sheet:

- Member avatar and name.
- Last seen or live/broadcasting status.
- Location/address.
- Distance or ETA where available.
- Battery percentage.
- Network status.
- Sharing/activity status.
- Call action.
- View on map action.

The Figma includes both neutral sheet variants and a high-alert pink emergency/member state. The emergency variant should be reserved for SOS/high-risk states, not normal member inspection.

### 5. Circles UI

The circles screens cover:

- Circle list/overview.
- Circle details.
- Member rows.
- Invite/join actions.
- Empty circle states.
- Possibly circle settings and membership management.

Implementation expectations:

- Circle UI should be separate from auth setup once onboarding is complete.
- Circle cards should make member count and active/offline status easy to scan.
- Avoid making circles feel like social groups; this is a safety network.

### 6. Profile And Settings

Profile/settings screens include:

- Profile summary.
- Account settings.
- Location/privacy settings.
- Notifications settings.
- Help/support.
- Legal/privacy copy.
- Safety or device-related settings.

Implementation expectations:

- Settings should be quiet, dense, and utilitarian.
- Keep privacy/location controls explicit.
- Avoid decorative marketing-style settings pages.

### 7. Push Notification Examples

Push notifications shown in Figma include normal app notifications and Guardian-specific safety notifications.

Notification categories should include:

- General Guardian update.
- Member last seen.
- Arrival/safe-home notice.
- SOS alert with action buttons.
- Rich notification with optional image/map preview.

SOS notifications should support urgent actions like:

- Open Guardian.
- Call member.
- View map.

Keep notification copy short, human, and direct.

## Figma Implementation Priority

The UI build should be corrected in this order:

1. Onboarding/auth/circle setup should fit all screen sizes without overflow.
2. Home normal state should match Figma structure before adding more behavior.
3. Broadcasting state should be extracted into reusable controls and stop duplicating banner/button code.
4. SOS sheets should be implemented as a clear state machine.
5. Member detail sheet should be implemented after map/member data is stable.
6. Circles/profile/settings can then be polished around the same design system.
7. Push notification UI can be represented in app copy/config first, then connected to FCM/APNs.

## Backend Architecture Guidance

The backend should remain a modular monolith for the MVP.

Core MVP domains:

- identity
- circles
- location
- journey
- sos
- notifications
- settings/profile

V2 domains may exist as placeholders, but avoid wiring them deeply into MVP flows until needed.

Use:

- Axum for HTTP routing.
- SQLx for PostgreSQL persistence.
- Redis later for presence, pub/sub, OTP/session cache, rate limiting, and realtime fanout.
- WebSockets for live location and SOS streams.
- Push notifications for offline/background alerts.

Data flow examples:

```text
Journey starts
  -> backend creates journey
  -> mobile starts location stream
  -> periodic updates every 5-15 seconds depending on mode
  -> backend stores and broadcasts updates
  -> circle members receive WebSocket or push updates
  -> journey completes or escalates
```

```text
SOS starts
  -> countdown in mobile
  -> backend creates SOS event
  -> location sharing switches to emergency cadence
  -> push notifications sent to circle members
  -> WebSocket streams active SOS state
  -> event resolved and audited
```

## Location Update Cadence

Use adaptive cadence rather than one fixed interval:

- Normal mode: 30-60 seconds.
- Journey mode: around 15 seconds.
- Emergency/SOS mode: around 5 seconds.

Optimize for battery, low-end Android devices, inconsistent networks, and African market conditions. Cache locally when offline and sync once the network returns.

## Product Positioning

Do not position Guardian as "another Life360." Position it as:

```text
A family safety app that helps loved ones know where you are and whether you arrived safely.
```

Important African/Nigerian realities:

- Some users are not tech-savvy.
- Phone-number signup is important.
- Low-end Android support matters.
- Poor or unstable network conditions are normal.
- Journey safety and safe-arrival reassurance are stronger than generic tracking.
- Theft recovery should start with last-known location, history, trusted devices, and alerts rather than OS-level locking claims.

## Current Codebase Check Notes

Recent worktree inspection showed active changes in both backend and mobile. Do not revert user changes.

Notable active areas:

- Backend identity, journey, SOS, and push notification files are modified.
- Mobile API services, home BLoC, journey BLoC, live map screen, and journey/location bottom sheets are modified.
- Several onboarding/auth screens appear deleted or moved.
- New circles and notifications presentation folders exist.
- New notification and background trigger services exist.
- Utility scripts appear moved from `apps/mobile/` into top-level `scripts/`.

Before major refactors, run:

```bash
git status --short
```

Then check:

```bash
cd apps/mobile
flutter analyze
```

```bash
cd apps/backend
cargo check
```

## AI Coding Instructions

When using an AI coding agent on Guardian:

- Read this file first.
- Preserve the current feature architecture unless the task explicitly asks for a restructure.
- Keep MVP flows simple.
- Do not add new dependencies unless needed.
- Do not move sensitive logic into Flutter.
- Do not introduce blockchain into live location flows.
- For UI tasks, prefer extracting duplicated widgets and clarifying screen states over piling on conditionals.
- For backend tasks, prefer domain-level modules and repository traits over cross-domain shortcuts.
- Never revert unrelated changes in the worktree.
