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
- Simple, user-approved geofencing with named circular safe zones and
  entry/exit notifications.
- Offline queuing for location, journey, SOS, check-in, and geofence events,
  with automatic encrypted synchronization after connectivity returns.
- Basic settings and profile management.

Avoid adding these to the MVP unless explicitly requested:

- Full blockchain implementation.
- Complex AI or smart prediction.
- Chat, calls, social feed, public groups, or stories.
- Advanced theft recovery.
- Admin portal.
- Billing/subscriptions.
- Watch apps, widgets, and Live Activities.
- Automatic route learning, journey-corridor alerts, and other advanced
  geofencing.

## Roadmap

Guardian 1.5 can add:

- Parent and child profiles with role-based permissions.
- A simplified child/dependant interface.
- Recovery sessions with a shared trusted-circle timeline.
- An opt-in rolling Safety Buffer for incident reconstruction.
- Biometric app lock for sensitive screens and actions. SOS must remain
  immediately accessible.
- Temporary guardian access with explicit start/end times and an audit trail.
- Apple Watch and Wear OS companion applications, starting with SOS and
  check-ins rather than health interpretation.

Guardian 2.0 can add:

- Device recovery.
- Guardian Plus.
- Subscriptions and billing.
- Timeline/history.
- Advanced geofencing, missed-arrival rules, and journey-corridor alerts.
- Opt-in familiar-place and familiar-route suggestions.
- Smart alerts with clear confidence and device-availability states.
- Care profiles, support plans, and an explicit "I need support" workflow.
- Analytics/AI.
- Advanced watch capabilities and approved sensor observations.
- iOS and Android widgets.
- Support tooling.
- Admin operations.
- Blockchain audit.

Treat these as future modules. Do not let them complicate the MVP UI or backend paths unless the current task is explicitly about those areas.

## Product Expansion Direction

Guardian can grow from phone-based family safety into a multi-device family
safety and assisted-care platform. Keep this as a product direction, not an MVP
promise.

Supported roles may eventually include:

- Individual.
- Primary and additional guardian.
- Child or dependant.
- Care recipient.
- Trusted family member, friend, neighbour, or caregiver.
- Organization as a future optional role, not a core dependency.

Use one family/circle permission model rather than separate products for each
role. Access to location, alerts, care information, and administration must be
explicit, revocable, time-bounded where appropriate, and auditable.

Parent/child and care experiences should be respectful safety tools rather than
covert surveillance. A simplified dependant interface may expose only:

- SOS.
- "I'm safe".
- "I need support".
- Call guardian.
- Start or finish a known journey.

Care features may store user-provided support instructions, emergency contacts,
allergies, medications, communication preferences, and preferred care actions.
Guardian must describe sensor data as observations, never diagnose autism,
asthma, panic, falls, or other medical conditions from watch or phone data.
Algorithmic observations must ask a person to confirm and must not automatically
contact emergency services solely from an inferred condition.

Treat a Guardian device as an abstraction belonging to a person. A location or
safety event may eventually come from an Android phone, iPhone, Apple Watch,
Wear OS watch, or an explicitly supported GPS device. Do not promise full
compatibility with every smartwatch:

- Apple Watch requires a native Swift/SwiftUI watch application.
- Wear OS requires a native Kotlin/Compose application.
- Proprietary watches may only mirror phone notifications.
- Vendor GPS watches require an authorized SDK, API, webhook, or partnership.
- Do not rely on reverse-engineered Bluetooth protocols for a dependable safety
  feature.

### Wearable Compatibility Ladder

Do not reduce wearable support to Apple and Samsung. Implement it as capability
levels so Guardian can honestly support a broader market without pretending that
every watch exposes the same APIs.

```text
Level 1: Native Guardian watch app
  Apple Watch and Wear OS, including compatible Samsung, Google, Xiaomi,
  Oppo, Mobvoi, and other devices running supported Wear OS versions

Level 2: Companion notification integration
  proprietary watches that mirror phone notifications or expose notification
  actions through their manufacturer companion application

Level 3: Documented Bluetooth accessory integration
  BLE devices with a public GATT profile, authorized SDK, or manufacturer API

Level 4: Vendor cloud/device integration
  GPS watches and trackers with an authorized API, SDK, or webhook
```

For Level 2, Guardian may provide mirrored SOS alerts, check-in prompts, family
messages, and geofence notifications, but cannot assume access to the watch's
GPS, buttons, battery, microphone, or health sensors.

For Level 3, Android can use BLE and Companion Device APIs and iOS can use Core
Bluetooth where the accessory exposes a documented protocol. Candidate
capabilities include:

- A physical accessory button triggering SOS on the paired phone.
- Device presence/disconnection observations.
- Battery level when exposed through a standard or documented service.
- Vibration or acknowledgement commands when supported.
- Standard BLE health-device measurements when the user explicitly authorizes
  them and the device provides provenance and timestamps.

Bluetooth pairing alone does not grant Guardian access to a watch's private
data. Many inexpensive or proprietary watches communicate only with their own
companion app, use undocumented/encrypted protocols, or do not permit third-party
background access. Add each model to a tested compatibility registry with exact
capabilities and firmware/app versions. Do not market generic "all Bluetooth
watches" support.

Sensitive BLE data requires application-layer authentication and encryption in
addition to platform pairing. Background connections are constrained and may be
terminated, so disconnection must be reported as "device unavailable", not as a
confirmed emergency.

### Guardian Watch Experience

Build the watch UI as a focused native safety companion rather than a compressed
copy of the Flutter phone application:

- Large hold-to-activate SOS with haptic confirmation and a cancel window.
- "I'm safe", "I need support", and configurable care-request actions.
- Call or message a guardian.
- Current guardian, sharing, connectivity, and queued/sent status.
- Active journey and return-to-safe-place actions.
- Emergency card with user-approved essentials.
- Large targets, high contrast, reduced cognitive load, optional symbols,
  configurable wording, and voice/haptic feedback.

Apple Watch UI should be implemented natively with SwiftUI/watchOS and communicate
through the backend plus Watch Connectivity where appropriate. Wear OS UI should
use Kotlin and Compose for Wear OS. Shared backend contracts and design tokens
may be reused, but do not force Flutter mobile widgets onto watchOS or assume one
native implementation works on both platforms.

Provide a caregiver-configurable simple mode. The wearer should still retain
clear awareness and control over monitoring. Avoid stigmatizing labels in the
watch UI; use phrases such as "Need support", "Call my guardian", and "Show my
support plan".

### Health Observations And Care Safety

Guardian may receive authorized observations such as heart rate, movement,
activity state, falls where officially exposed, sleep-related summaries, manual
symptoms, device removal, and missed check-ins. Availability and update frequency
vary by device. Wear OS Health Services supports active and passive metrics on
compatible watches, while Apple health/watch capabilities require the relevant
HealthKit/watchOS permissions and, for some features, special entitlements.

Health metrics do not identify a diagnosis or reliably determine the cause of
distress:

- Elevated heart rate does not prove an asthma attack or panic episode.
- Motion patterns do not prove an autistic meltdown, wandering intent, seizure,
  or abuse.
- Consumer watch data cannot determine that a person is experiencing psychosis
  or a schizophrenia-related episode.
- A fall-like event, inactivity, or device separation can have ordinary causes.

Use an observation-confirmation-escalation model:

```text
Authorized observation or explicit user action
  -> validate timestamp, device, quality, and recent context
  -> ask the wearer a simple configurable question when appropriate
  -> allow "I'm safe", "Need support", and "Emergency" responses
  -> notify an authorized caregiver if the rule and consent permit it
  -> escalate through configured contacts only when confirmed or unanswered
  -> clearly label every fact, estimate, unavailable reading, and user response
```

The most dependable care trigger is still an explicit wearer action such as "I
need support". Sensor rules should provide earlier prompts, not diagnoses. A
caregiver can configure individualized thresholds only as support preferences,
with defaults reviewed for false-alert risk. Guardian must not recommend medication
doses, interpret symptoms clinically, or automatically contact emergency services
from a consumer sensor reading alone.

Store `health_observations`, not diagnoses. Each record should include person,
device, metric, value/unit, observed time, received time, source quality,
permission basis, and optional user confirmation. Keep health access separate
from ordinary circle location permission; use least privilege, explicit consent,
revocation, short retention, encryption, and an audit trail.

Before shipping condition-specific claims or emergency sensor automation, obtain
clinical, accessibility, privacy, regulatory, and platform-policy review. Design
with autistic people, people with asthma, people living with schizophrenia, and
their chosen caregivers rather than designing only from a caregiver's viewpoint.

### Care Mode

Care Mode is respectful assisted safety, not a mechanism for covert surveillance
or remote control. It may support autistic children and adults, older people,
people with epilepsy or asthma, people prone to panic episodes, people living
with schizophrenia or cognitive disabilities, and people who may become
disoriented. Do not assume that every person with one of these conditions needs
monitoring; the wearer/person and their lawful guardian must remain central to
consent and configuration.

An optional Support Plan may contain user-approved information such as:

- Known triggers and early signs described by the person/caregiver.
- Calming or grounding instructions and communication preferences.
- Preferred and backup contacts.
- Allergies, listed medications, and preferred hospital.
- Actions caregivers should take or avoid.
- User-defined circumstances for contacting emergency services.
- A concise emergency card with separate visibility permissions.

The watch and phone should provide an "I need support" action. When activated,
Guardian can notify authorized caregivers, share current/last-known location,
open the approved Support Plan, begin a configurable support window, ask whether
emergency help is needed, and record the event in the care timeline.

Potential signals, only with appropriate consent, include unexpected rapid
movement, repeated zone transitions, missed arrival, extended immobility,
device/watch disconnection, an unusual available heart-rate observation, manual
distress input, and missed check-ins. Notification wording must remain factual:

```text
Good: "Guardian noticed unusual movement. Please check on Daniel."
Bad:  "Daniel is having an autistic episode."
```

Asthma support may include medication and inhaler reminders, a manual breathing
difficulty action, an emergency action plan, caregiver notification, location
sharing, and later integration with explicitly supported medical devices. A
heart-rate reading alone cannot determine that someone is having an asthma
attack. Medication features are reminders and user-provided records, not dosage
advice or confirmation that medication was medically appropriate.

Use a configurable escalation ladder:

```text
Stage 1: wearer check-in
Stage 2: primary caregiver notification
Stage 3: backup caregiver notification
Stage 4: configured call or SMS escalation
Stage 5: emergency action from the approved plan
```

Do not automatically contact emergency services merely because an algorithm or
consumer sensor detects an unusual pattern. Any later automation requires clear
authorization, regional legal/regulatory review, platform compliance, and a
well-tested false-alert/cancellation process.

## Geofencing Strategy

Simple geofencing is part of the Guardian MVP because it directly supports the
core promise of safe-arrival reassurance.

### MVP Geofencing

Support circular zones only:

- A user chooses a location on the map, gives it a human name, and selects a
  radius.
- A zone can notify on entry, exit, or both.
- A zone targets an explicitly consenting circle member or dependant.
- Entry/exit events create an activity record and notify authorized guardians.
- Safe-zone boundaries are visible on the map and can be disabled or deleted.
- Include accuracy filtering, transition cooldowns, and state persistence so
  GPS drift does not create repeated false alerts.

Recommended initial radius range is approximately 100-2,000 metres. Very small
zones are unreliable on devices with poor GPS, indoors, or on low-power modes.
The UI must communicate that alerts may be delayed and location can be
temporarily unavailable.

### Hybrid Detection Architecture

Use both operating-system and server-side detection:

```text
User creates or changes a zone
  -> Rust backend stores the authoritative rule and permissions
  -> mobile registers relevant zones with Android/iOS region monitoring
  -> device reports a detected transition when possible
  -> every normal Guardian location update is also checked by the backend
  -> backend deduplicates the transition, records it, and sends notifications
```

Android should use Google Play services `GeofencingClient` for battery-efficient
circular entry/exit events. iOS should use Core Location region/condition
monitoring. Google Maps renders and selects locations, but the map widget itself
does not provide background geofence monitoring. Keep the Rust backend as the
source of truth because phone services can be unavailable, force-stopped,
permission-restricted, delayed, or vendor-throttled.

Android geofencing requires fine and background location permissions on current
target versions. iOS requires the appropriate Always Location authorization and
background capability. Request background access only after explaining the
specific safety benefit, and expose clear pause/delete controls.

Suggested backend data model:

```text
geofences
  id, circle_id, name, latitude, longitude, radius_m,
  notify_on_entry, notify_on_exit, enabled, created_by, timestamps

geofence_members
  geofence_id, user_id, consent/authority metadata

geofence_member_states
  geofence_id, user_id, inside, last_transition_at, last_location_at

geofence_events
  geofence_id, user_id, transition, coordinates, accuracy,
  detected_by, occurred_at, notification_status
```

Evaluate zones after each accepted location update using a Haversine/PostGIS
distance check. Reject impossible coordinates, account for horizontal accuracy,
require a stable transition where appropriate, and make notification creation
idempotent.

### Automatic Familiar Places And Routes

Automatic discovery is possible, but it is not supplied by the Google
Geofencing API. Guardian would need to collect an explicitly opted-in location
history and infer patterns itself.

Do not silently create active geofences or label a place as Home. Use a
human-confirmation workflow:

```text
Repeated visits or journeys are detected locally/backend
  -> Guardian suggests "You often stop here. Save as a safe place?"
  -> the user names/confirms the place and chooses who receives alerts
  -> only then is an active geofence created
```

For familiar routes, cluster privacy-reduced journey traces by origin,
destination, time window, and route similarity. First use the result to suggest
a saved journey. Route-deviation monitoring should run only during an explicitly
started or scheduled journey; it should not continuously judge all movement.

Automatic discovery belongs after manual geofencing is reliable because it
requires:

- Consent and a visible opt-out/delete-history control.
- A retained location-history model rather than only latest location.
- Offline buffering and background collection that respects battery limits.
- Minimum sample counts and confidence thresholds.
- Protection against sensitive-place inference and abusive monitoring.
- Clear handling of shared devices, relocation, travel, and changed routines.

Never infer or expose sensitive labels such as hospital, religious venue,
shelter, or relationship status without the user's explicit confirmation.

### Current Implementation Status

Geofencing is not implemented yet. The Rust geofencing domain and worker are
stubs. The mobile `GpsService` currently requests a single position rather than
maintaining a dependable background stream, and the Android manifest does not
yet request background location or register a geofence transition receiver.
iOS contains location background descriptions and modes, but that configuration
alone does not implement region monitoring. Firebase/local notification support
and the backend's latest-member-location endpoint are useful foundations.

Build manual geofencing first in this order:

1. Database schema, permission model, CRUD API, and tests.
2. Safe-zone creation/management UI and map circles.
3. Backend transition evaluation on accepted location updates.
4. Idempotent activity events and push notifications.
5. Android `GeofencingClient` and iOS Core Location monitoring.
6. Background-permission education, degraded-state UI, and device testing.
7. Opt-in familiar-place suggestions only after enough reliable history exists.

## Offline Safety And Recovery

Guardian must be useful during unreliable connectivity, but it must never imply
that an ordinary third-party application can transmit without a communication
path. If a device has no mobile data, Wi-Fi, supported satellite transport, or
approved relay, Guardian cannot send its current location to the backend. If the
device is powered off, destroyed, force-stopped, or has location disabled, live
tracking is unavailable.

Design offline behavior around continuity:

```text
Location or safety event occurs
  -> append it to an encrypted local queue
  -> preserve its original timestamp, sequence, and accuracy
  -> continue local actions that do not require the network
  -> detect usable connectivity
  -> upload in bounded batches
  -> backend acknowledges event IDs
  -> remove only acknowledged records from the local queue
```

Do not treat a network interface being present as proof that the internet works.
Synchronization must tolerate captive portals, exhausted mobile data, transient
connections, process restarts, duplicate requests, and out-of-order delivery.
Use stable event IDs and idempotent backend writes.

### Offline-Capable Events

The first offline queue should support:

- Location samples collected during an active journey or SOS.
- Journey start, progress, completion, and cancellation.
- SOS activation and cancellation, clearly marked as pending until delivered.
- Manual "I'm safe" and "I need support" check-ins.
- Geofence entry/exit transitions detected by the device.
- Battery, charging, location-permission, and connectivity state changes when
  available through supported platform APIs.

An offline SOS must immediately activate the local emergency experience, start
the configured location cadence, persist the event, and keep retrying delivery.
The UI must say that the alert is queued and contacts have not yet been reached;
never show "SOS sent" until the backend acknowledges it.

Scheduled check-in reminders and already-registered device geofences can operate
locally. Their results synchronize later. Remote guardians cannot know about an
offline event until some communication path returns.

### Guardian Safety Buffer

"Guardian Black Box" may be used as an internal concept or later product name.
The user-facing design should initially call it a Safety Buffer or Recovery
Timeline so its purpose is understandable and not alarming.

The Safety Buffer is an explicitly enabled, encrypted, rolling record of recent
safety-relevant events. Normal data expires automatically according to a short
user-visible retention period. Starting an SOS or recovery session may preserve
the relevant window, subject to user consent and policy.

Start with the minimum useful fields:

- Coordinates, horizontal accuracy, and timestamp.
- Speed and heading when reported reliably.
- Battery and charging state.
- Connectivity category, not nearby network identities.
- Journey, check-in, geofence, SOS, and recovery state.

Do not collect nearby Wi-Fi identifiers, Bluetooth device identities, cell-tower
identifiers, ambient audio, or continuous sensor data by default. These data are
sensitive, inconsistently available, and easy to misuse. Emergency audio
recording, if ever considered, requires a separate explicit consent flow,
jurisdiction review, obvious recording state, retention controls, and secure key
management; it is not part of the MVP.

Store queued records in an encrypted local database, not SharedPreferences or
plain files. Protect keys with Android Keystore/iOS Keychain, cap queue size,
expire old normal-mode records, and provide delete/pause controls. Avoid
recording at emergency cadence continuously because of battery, storage, and
privacy costs.

### Recovery Sessions

Device recovery should complement Apple Find My and Google's device-finding
service, not claim to replace their operating-system networks. Guardian cannot
create an equally universal crowd relay from a normal mobile application.

An authorized owner can start a recovery session that:

- Preserves the relevant Safety Buffer window.
- Marks later device updates as part of the recovery timeline.
- Shows last connected time separately from last recorded time.
- Displays movement, battery, connectivity, and location accuracy honestly.
- Shares updates only with specifically authorized trusted members.
- Notifies those members when a brief reconnection uploads new evidence.
- Provides a clear route to the platform's native device-finding service.
- Ends access and heightened retention when the session is resolved.

Use language such as "last recorded", "uploaded after reconnecting", and
"location unavailable". Never present an old offline sample as the device's
current position. Recovery summaries may describe observed speed and direction,
but must distinguish facts from estimates and must not encourage users to
confront a suspected thief.

### SIM Removal And Replacement

Removing a physical SIM normally removes that device's cellular-data path; it
does not disable GPS and it does not automatically stop Guardian. The app may
continue recording locally and may reconnect through known/new Wi-Fi, another
active SIM/eSIM, a paired cellular watch, or a supported independent tracker.
When connectivity returns, queued events can synchronize if Guardian is still
installed, authorized, and permitted to run.

Guardian cannot remotely trace or receive a live location from a phone that has
no communication path. It also cannot survive an uninstall or factory reset as
an ordinary third-party app, bypass a device lock, secretly re-enable location,
or reproduce Apple/Google's operating-system finding networks.

Treat SIM state as an optional integrity observation, not a core recovery
mechanism:

- Some Android versions/devices expose active subscription changes with phone
  state permission, subject to OS, carrier, policy, and permission restrictions.
- iOS does not provide a dependable general-purpose public signal that Guardian
  can use as a universal SIM-removal alarm.
- Dual-SIM/eSIM switching, poor signal, roaming, airplane mode, and carrier
  provisioning can resemble SIM removal.
- Do not collect SIM serial numbers, subscriber identifiers, or phone-state data
  unless strictly necessary, disclosed, consented to, and approved for the
  intended store/platform use.

Where supported, label the event cautiously: "Cellular subscription changed or
became unavailable." Combine it with other facts such as connectivity loss,
device separation, permission changes, or an active recovery session. Never say
"SIM stolen" based on one signal.

### Carrier Information

Carrier information is best-effort device context, not identity or proof of SIM
ownership. On supported Android devices, Guardian may be able to display the SIM
service provider and/or currently registered network, such as Airtel, 9mobile,
AT&T, or Verizon. These can differ while roaming, with MVNOs, or on dual-SIM/eSIM
devices, so model them separately:

- `subscription_carrier`: the provider associated with the active subscription.
- `registered_network`: the network currently serving the device.
- `subscription_slot`: a non-secret local slot label when safely available.
- `observed_at` and `availability`: timestamp plus supported/unavailable/unknown.

On iOS, the older public carrier-name APIs are deprecated and may return static
placeholder values on modern SDKs. Do not make carrier display, SIM-change
detection, recovery, authentication, or billing depend on iOS returning a useful
carrier name.

Do not collect phone numbers, ICCIDs/SIM serials, IMSIs, or other persistent
subscriber identifiers for this feature. Ask for Android phone-state permission
only if the concrete user benefit survives store/privacy review; otherwise omit
the carrier field. Show `Unknown` rather than guessing from IP address or phone
number prefix.

### Multiple Devices And Separation

A cellular watch or dedicated tracker may continue reporting when a paired phone
cannot, because it has an independent communication path. Treat those updates as
separate device observations for the same person and show which device produced
each event.

Phone/watch separation can become an opt-in rule where platform APIs permit it.
A Bluetooth disconnection alone is weak evidence: range, battery saving,
airplane mode, and ordinary watch removal can all trigger it. Record a separation
location and ask the user to confirm before escalating unless they deliberately
configured a stronger rule.

### Relay And Hardware Research

Guardian-to-Guardian Bluetooth relay is research, not a dependable roadmap
promise. It requires both nearby devices to participate, strong anonymous
cryptographic design, abuse resistance, background execution permission, and
careful review on both platforms. It will not match an operating-system-level
finding network.

A future Guardian tracker or supported cellular wearable could provide an
independent GPS and data connection. That introduces hardware certification,
eSIM/carrier relationships, recurring connectivity costs, device provisioning,
firmware security, and support operations; keep it outside the software MVP.

### Offline Implementation Status

The current map periodically requests and uploads a location while its widget is
active, but Guardian does not yet have a durable encrypted event queue, replay
protocol, background journey/SOS recorder, or recovery timeline. The mobile and
backend device-recovery modules are placeholders. Connectivity labels in the UI
must not be mistaken for offline persistence.

Recommended delivery order:

1. Define a versioned safety-event envelope and idempotency contract.
2. Add encrypted local queue storage with retention and size limits.
3. Add connectivity-triggered and scheduled bounded synchronization.
4. Queue journey, check-in, geofence, and SOS events with honest pending UI.
5. Add backend event ingestion, acknowledgements, and ordered timeline views.
6. Add explicit recovery sessions and trusted-member authorization.
7. Evaluate the rolling Safety Buffer using measured battery/storage results.
8. Consider watches, device separation, relays, or hardware only after the core
   offline pipeline is dependable.

## Subscription And Entitlements

Guardian can use subscriptions because cloud location processing, encrypted
history, push delivery, maps, watch/device integrations, and support operations
provide ongoing value and recurring cost. Package features by user outcome, not
by exposing every technical switch as a separate purchase.

Recommended product structure:

### Guardian Personal

For one person building a trusted safety network:

- Profile, trusted circle, and core location sharing.
- Manual SOS and emergency contacts.
- Manual check-ins and a basic journey.
- Current/last-known device status.
- A small amount of recent activity history.

Keep a useful Personal tier free or very low-friction so a person can receive an
invite and use basic safety actions. Never require payment at the moment someone
needs to trigger SOS, view their own emergency card, revoke consent, leave a
circle, or delete their data.

### Guardian Personal Plus

For advanced individual safety and recovery:

- Multiple journeys and scheduled check-ins.
- Manual safe zones and geofence alerts.
- Longer encrypted history and offline Safety Buffer synchronization.
- Recovery sessions and recovery timeline.
- One supported watch/accessory integration where available.
- Advanced permission, battery, and connectivity alerts.

### Guardian Family

One subscription purchased by a family organizer should cover the family rather
than charging each child or dependant separately:

- Multiple family members and guardians within a clear published limit.
- Parent/child or dependant profiles and simplified mode.
- Multiple safe zones, arrival/exit alerts, and family journeys.
- Family activity and collaborative recovery timelines.
- Temporary guardian delegation.
- Multiple supported phones/watches within a published device limit.
- Longer history and configurable escalation contacts.

Invited members should not need their own subscription merely to receive an SOS,
respond to a check-in, or participate in a paid organizer's family.

### Guardian Care

Guardian Care can be a higher family tier or add-on after the care workflows have
been validated with users and professionals:

- Support Plans and emergency cards.
- "I need support" and Episode Assist workflows.
- Care reminders and configurable observation windows.
- Caregiver and backup-caregiver escalation ladder.
- Consented wearable observations and supported medical-device integrations.
- Care timeline, detailed access audit, and longer appropriate retention.

Do not price by diagnosis and do not market Guardian Care as detecting autism,
asthma attacks, schizophrenia-related episodes, epilepsy, or other medical
conditions. The paid value is coordination, configuration, storage, device
integration, and ongoing caregiver workflows.

### Future Organization And Hardware Plans

Organization plans for care providers, estates, employers, NGOs, or other groups
are future B2B products with separate administration, contracts, safeguarding,
support, and audit requirements. They are not prerequisites for the consumer
family product.

Dedicated Guardian trackers, cellular wearables, eSIM connectivity, or hardware
replacement/support should be sold as a device plus connectivity/service plan,
not silently included in an ordinary app subscription.

### Subscription Safety Rules

- Entitlements are enforced by the backend and cached securely for temporary
  offline use; never trust Flutter UI flags as authorization.
- Use Apple/Google in-app purchase systems where platform rules require them and
  validate transactions/server notifications on the backend.
- Support upgrades, downgrades, trials, billing grace periods, restoration, and
  family-organizer transfer without creating duplicate subscriptions.
- Explain exact member, device, history, zone, and storage limits before purchase.
- During expiry or billing grace, preserve safety records and allow export/delete;
  degrade premium creation features predictably rather than abruptly destroying
  configured safety rules.
- Consent, privacy controls, account recovery, data deletion, and access audit
  must never depend on a premium subscription.
- Do not sell raw location or health data, and do not use advertising as the
  economic model for sensitive safety/care experiences.
- Final names, limits, regional prices, trials, and annual discounts should be
  validated through user research and cost modelling before being hard-coded.

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
