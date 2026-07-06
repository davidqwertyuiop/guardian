# 🛡️ Guardian Codebase File Index

This index lists and categorizes all source files in the Guardian monorepo. It organizes components logically to help navigate the codebase.

---

## 📱 Flutter Mobile App (`apps/mobile`)

### 🧠 State Management (Blocs)
Manages the application state, business logic transitions, and event flow:
* [auth_bloc.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/bloc/auth_bloc.dart): Coordinates user auth state, session caching, and multi-step onboarding navigation.
* [auth_event.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/bloc/auth_event.dart): Declares input events for authentication (e.g., `AppStarted`, `PhoneSubmitted`, `OtpSubmitted`, `ProfileSetupCompleted`).
* [auth_state.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/bloc/auth_state.dart): Holds user profile models, registration steps (`AuthStep`), and validation error states.
* [journey_bloc.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/journey/presentation/bloc/journey_bloc.dart): Manages active traveler routes, travel timing, and geofence tracking progress.
* [journey_event.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/journey/presentation/bloc/journey_event.dart): Declares inputs for safety route triggers (e.g., `StartJourneyRequested`, `UpdateJourneyRoute`, `CompleteJourneyRequested`).
* [journey_state.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/journey/presentation/bloc/journey_state.dart): Holds navigation paths, target coordinates, and active trip telemetry.
* [home_bloc.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/home/presentation/bloc/home_bloc.dart): Manages the main dashboard views and circles data loading.
* [home_event.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/home/presentation/bloc/home_event.dart): Events triggered during circle changes and status updates.
* [home_state.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/home/presentation/bloc/home_state.dart): State mapping current circle info and active group members.
* [settings_bloc.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/settings/presentation/bloc/settings_bloc.dart): Handles configuration preference transitions (theme toggles, notification configurations).
* [settings_event.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/settings/presentation/bloc/settings_event.dart): Declares user preference adjustments.
* [settings_state.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/settings/presentation/bloc/settings_state.dart): Stores persistent user configs.

### 🏁 Auth Bloc Handlers
Modularized sub-handlers processing specific auth flows:
* [app_handler.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/bloc/handlers/app_handler.dart): Manages initial app loading and persistence verification on startup.
* [circle_handler.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/bloc/handlers/circle_handler.dart): Handles circle setup logic.
* [navigation_handler.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/bloc/handlers/navigation_handler.dart): Orchestrates screen transitions based on state changes.
* [phone_auth_handler.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/bloc/handlers/phone_auth_handler.dart): Handles OTP requests, SMS timeouts, and token exchanges.
* [profile_handler.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/bloc/handlers/profile_handler.dart): Coordinates profile data submissions and avatar selections.

### 🖥️ Screens & Views
#### Authentication
* [welcome_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/screens/welcome_screen.dart): Initial onboarding view.
* [login_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/screens/login_screen.dart): Form to input user phone numbers.
* [otp_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/screens/otp_screen.dart): Code entry keypad with verification handlers.
* [register_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/screens/register_screen.dart): Profile settings form (Username, Avatar picker, Email).
* [almost_in_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/screens/almost_in_screen.dart): Asks for system location permissions.
* [splash_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/screens/splash_screen.dart): Initial loading splash widget.

#### Live Map & Geolocation
* [live_map_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/screens/live_map_screen.dart): Interactive map tracking self and group members.
* [location_history_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/screens/location_history_screen.dart): Chronological list and route trails of locations.
* [location_permission_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/screens/location_permission_screen.dart): Prompts for system permissions.
* [member_location_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/screens/member_location_screen.dart): Detail view tracking a specific circle member.
* [sos_broadcasts_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/screens/sos_broadcasts_screen.dart): Displays emergency distress coordinates.

#### Circles (Groups)
* [circle_empty_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/circles/presentation/screens/circle_empty_screen.dart): Prompts to create or join a circle.
* [enter_invite_code_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/circles/presentation/screens/enter_invite_code_screen.dart): Keypad screen to join groups.
* [name_circle_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/circles/presentation/screens/name_circle_screen.dart): Screen to name a new circle.
* [paste_link_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/circles/presentation/screens/paste_link_screen.dart): Form to join using links.
* [family_circle_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/family/presentation/screens/family_circle_screen.dart): Group setting configurations.

#### Safety Journeys
* [start_journey_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/journey/presentation/screens/start_journey_screen.dart): Journey initiation screen.
* [active_journey_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/journey/presentation/screens/active_journey_screen.dart): Route progress tracker with emergency helpers.
* [completed_journey_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/journey/presentation/screens/completed_journey_screen.dart): Journey completion screen.

#### Emergency & UI Shells
* [emergency_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/emergency/presentation/screens/emergency_screen.dart): Shows emergency options.
* [emergency_active_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/emergency/presentation/screens/emergency_active_screen.dart): SOS broadcasting countdown and status screen.
* [home_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/home/presentation/screens/home_screen.dart): App dashboard container.
* [settings_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/settings/presentation/screens/settings_screen.dart): User preferences list.
* [alerts_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/alerts/presentation/screens/alerts_screen.dart): Alert logs listing emergency notifications.
* [notifications_permission_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/notifications/presentation/screens/notifications_permission_screen.dart): Prompts for system notification channels permissions.

---

### 🎨 Widgets & Components

#### Authentication Widgets
* [avatar_cluster.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/avatar_cluster.dart): Overlapping circle avatars UI.
* [avatar_item.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/avatar_item.dart): Selectable avatar item.
* [country_picker_bottom_sheet.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/country_picker_bottom_sheet.dart): Dialog displaying countries and dialing codes.
* [glow_blob.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/glow_blob.dart): Graphic background component for styling onboarding.
* [login_bottom_sheet.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/login_bottom_sheet.dart): Bottom dialog to login.
* [login_bottom_sheet_widgets.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/login_bottom_sheet_widgets.dart): Inner list items for the sheet.
* [onboarding_step_screen.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/onboarding_step_screen.dart): Card widget defining steps.
* [onboarding_top_icon.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/onboarding_top_icon.dart): Top illustration.
* [otp_bottom_sheet.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/otp_bottom_sheet.dart): Verification card panel.
* [otp_bottom_sheet_widgets.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/otp_bottom_sheet_widgets.dart): Input and resend fields.
* [otp_input_field.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/otp_input_field.dart): Customized code field with Pinput.
* [phone_input_field.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/phone_input_field.dart): Country selector + raw phone parser.
* [register_screen_widgets.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/register_screen_widgets.dart): Inner items for user form registration.
* [welcome_card.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/welcome_card.dart): Summary welcome card layout.

#### Authentication Styled Elements (`shared/`)
* [auth_background_ellipses.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/shared/auth_background_ellipses.dart): Curved styling ellipses background.
* [auth_bullet_list.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/shared/auth_bullet_list.dart): Lists benefits/instructions.
* [auth_primary_button.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/shared/auth_primary_button.dart): Core call-to-action button.
* [auth_secondary_button.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/shared/auth_secondary_button.dart): Muted action triggers.
* [auth_shared.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/shared/auth_shared.dart): Central styles.
* [auth_subtitle.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/shared/auth_subtitle.dart): Muted subtitle texts.
* [auth_title.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/auth/presentation/widgets/shared/auth_title.dart): Bold title layout.

#### Live Map & Navigation Widgets
* [address_text.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/address_text.dart): Geocoded text label showing member locations.
* [circle_card.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/circle_card.dart): Renders lists of circles on the map page.
* [heading_out_bottom_sheet.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/heading_out_bottom_sheet.dart): Dialog to quickly pick targets when traveling.
* [heading_out_button.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/heading_out_button.dart): Button to initiate destination selection.
* [map_card.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/map_card.dart): Embedded maps interface.
* [map_distance_badge.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/map_distance_badge.dart): Small distance-duration overlay.
* [map_styles.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/map_styles.dart): Custom JSON themes for Google Maps.
* [member_avatar_row.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/member_avatar_row.dart): Profiles header of circle members on the map screen.
* [top_bar.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/top_bar.dart): Map screen header.
* [welcome_header.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/welcome_header.dart): Display user status indicator.
* [you_are_live_bottom_sheet.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/live_map/you_are_live_bottom_sheet.dart): Sliding panel showing live sharing active state.
* [sos_broadcasts_section.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/presentation/widgets/sos_broadcasts_section.dart): Summary widget listing current alerts.

#### Circles Sheets
* [circle_ready_sheet.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/circles/presentation/widgets/circle_ready_sheet.dart): Group sharing initialization card.
* [you_are_in_sheet.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/circles/presentation/widgets/you_are_in_sheet.dart): Panel showing new circle joining confirmation.

---

### 📦 Services & API layers

#### Rest API clients (`core/services/api/`)
* [api_base.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/api/api_base.dart): Basic REST HTTP client with secure token headers and logs.
* [auth_api_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/api/auth_api_service.dart): Authenticates token exchanges and profile edits.
* [circles_api_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/api/circles_api_service.dart): Performs POST/GET commands for circles, members, and links.
* [journey_api_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/api/journey_api_service.dart): Interacts with backend tracking routes and ETAs.
* [location_api_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/api/location_api_service.dart): Sends user coordinate updates.
* [sos_api_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/api/sos_api_service.dart): Triggers, updates, or resolves broadcast distress calls.

#### Device & Core System Services (`core/services/`)
* [firebase_auth_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/firebase_auth_service.dart): Links phone OTP verifications with Firebase.
* [background_trigger_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/background_trigger_service.dart): Monitors background gestures or physical triggers.
* [notification_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/notification_service.dart): Configures Awesome Notifications, channels, and triggers.
* [weather_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/services/weather_service.dart): Gathers localized weather coordinates.
* [gps_service.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/features/location/services/gps_service.dart): High-accuracy location tracker tracking background coordinates.

---

### 🛡️ Security Modules (`core/security/`)
* [certificate_pinning.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/security/certificate_pinning.dart): Strict SSL pinning configs for backends.
* [device_integrity.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/security/device_integrity.dart): Checks root, hook packages, and sandbox environments.
* [secure_storage.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/security/secure_storage.dart): Wrapper storage for flutter_secure_storage keys.
* [token_manager.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/security/token_manager.dart): Automatically refreshes access tokens.

---

### ⚙️ Bootstrap & Configs
* [main.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/main.dart): Application entry point orchestrating startups.
* [firebase_options.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/firebase_options.dart): Firebase config.
* [export.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/export.dart): Global exports folder to prevent circular dependencies.
* [dependency_injection.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/bootstrap/dependency_injection.dart): Setup configurations with GetIt.
* [app_bloc_observer.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/bootstrap/app_bloc_observer.dart): Global BLoC state logger.
* [environment.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/bootstrap/environment.dart): Loads env targets.
* [env_config.dart](file:///home/sijibomi/solana/guardian/apps/mobile/lib/core/config/env_config.dart): Scopes environment values.

---

## 🦀 Backend Service (`apps/backend`)

### 🛰️ Routing & Setup
* [main.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/main.rs): App entry point. Connects to Postgres database via SQLx, applies migrations, and launches Axum listener.
* [bootstrap.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/bootstrap.rs): Configures AppState, DB pools, dependencies injection repositories.
* [routes/mod.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/routes/mod.rs): App router config (registers map configuration API, universal links endpoints, and nests feature routes).
* [routes/auth.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/routes/auth.rs): Main auth middleware application.
* [config/mod.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/config/mod.rs): Maps env variables to type-safe structs.

---

### 🏗️ Domain Driven Modules (`domains/`)

#### 👤 Identity Domain (`identity/`)
* [user.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/domain/entities/user.rs): Core database user struct mapping profile configurations.
* [user_session.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/domain/entities/user_session.rs): Active device session keys mapping.
* [phone_number.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/domain/value_objects/phone_number.rs): Value object for parsing, validating, and formatting numbers.
* [user_repository.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/domain/repositories/user_repository.rs): Trait definition for CRUD user records.
* [session_repository.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/domain/repositories/session_repository.rs): Trait definition for device sessions.
* [postgres_user_repo.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/infrastructure/postgres_user_repo.rs): Concrete Postgres UserRepository SQLx map.
* [postgres_session_repo.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/infrastructure/postgres_session_repo.rs): Concrete Postgres SessionRepository SQLx map.
* [handlers.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/api/handlers.rs): HTTP request handlers for authentication, logins, and preferences.
* [dto.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/api/dto.rs): Request/Response structures.
* [routes.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/api/routes.rs): Sub-router paths (`/login`, `/register`, `/verify`, `/profile`).
* [firebase_exchange.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/application/firebase_exchange.rs): Firebase token verification use case.
* [setup_profile.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/application/setup_profile.rs): Completes user registration profile setup.
* [refresh_token.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/application/refresh_token.rs): Re-authenticates expired JSON Web Tokens.
* [update_preferences.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/identity/application/update_preferences.rs): Modifies settings values.

#### 👥 Circles Domain (`circles/`)
* [circle.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/domain/entities/circle.rs): Circle group entity.
* [invite_token.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/domain/entities/invite_token.rs): Tracks temporary invite tokens.
* [membership.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/domain/entities/membership.rs): Maps users to roles inside circles.
* [circle_repository.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/domain/repositories/circle_repository.rs): Trait definition for CRUD circles.
* [invite_repository.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/domain/repositories/invite_repository.rs): Trait definition for invite codes.
* [postgres_circle_repo.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/infrastructure/postgres_circle_repo.rs): Postgres CircleRepository SQLx mapping.
* [postgres_invite_repo.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/infrastructure/postgres_invite_repo.rs): Postgres InviteRepository SQLx mapping.
* [handlers.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/api/handlers.rs): HTTP routing controllers for managing group lists.
* [routes.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/api/routes.rs): Sub-router registering `/create`, `/join`, `/invite`.
* [create_circle.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/application/create_circle.rs): Use case orchestrating new circle instances.
* [join_by_code.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/application/join_by_code.rs): Adds memberships via SMS invites.
* [join_by_link.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/circles/application/join_by_link.rs): Adds memberships via Universal links.

#### 📍 Location Domain (`location/`)
* [member_location.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/location/domain/entities/member_location.rs): Geolocation coordinates, timestamp, and metadata.
* [location_repository.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/location/domain/repositories/location_repository.rs): Trait definition for updates.
* [postgres_location_repo.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/location/infrastructure/postgres_location_repo.rs): Concrete Postgres LocationRepository SQLx mapper.
* [handlers.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/location/api/handlers.rs): Coordinates updates and queries active location lists.
* [routes.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/location/api/routes.rs): Router registering location endpoints.

#### 🚨 SOS Domain (`sos/`)
* [sos_broadcast.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/sos/domain/entities/sos_broadcast.rs): Emergency SOS incident object.
* [sos_repository.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/sos/domain/repositories/sos_repository.rs): Trait definition for emergencies.
* [postgres_sos_repo.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/sos/infrastructure/postgres_sos_repo.rs): Concrete Postgres repository.
* [handlers.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/sos/api/handlers.rs): Handlers to open or cancel SOS emergencies.
* [routes.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/domains/sos/api/routes.rs): Sub-router paths for emergency signals.

---

### 📡 WebSocket Stream Modules (`websocket/`)
* [connection_manager.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/websocket/connection_manager.rs): Central hub recording WebSocket streams and tracking active clients.
* [presence_stream.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/websocket/presence_stream.rs): Streams active updates when users go online or offline.
* [location_stream.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/websocket/location_stream.rs): Real-time member coordinate sharing stream.
* [sos_stream.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/websocket/sos_stream.rs): Broadcasts high-priority alert flags.

---

### 👷 Async Workers (`workers/`)
Processes deferred, high-overhead operations in the background:
* [notification_worker.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/workers/notification_worker.rs): Orchestrates push-notification dispatches.
* [geofence_worker.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/workers/geofence_worker.rs): Monitors users entering/exiting circle barriers.
* [audit_worker.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/workers/audit_worker.rs): Persists system logs locally.
* [blockchain_worker.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/workers/blockchain_worker.rs): Audits active SOS logs to the Solana blockchain.
* [analytics_worker.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/workers/analytics_worker.rs): Logs aggregated events.

---

### 🛡️ Shared Utilities (`shared/`)
* [jwt_auth.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/shared/middleware/jwt_auth.rs): Middleware parsing JWT authorization keys.
* [rate_limit.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/shared/middleware/rate_limit.rs): Rate limits API requests using Redis.
* [device_guard.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/shared/middleware/device_guard.rs): Validates clients based on hardware-integrity signatures.
* [request_logger.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/shared/middleware/request_logger.rs): Logs network events.
* [jwt.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/shared/auth/jwt.rs): Functions for creating and decoding tokens.
* [permissions.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/shared/auth/permissions.rs): Role parsing permissions inside circles.
* [errors.rs](file:///home/sijibomi/solana/guardian/apps/backend/src/shared/errors/mod.rs): Maps service failures to Axum HTTP response statuses.
