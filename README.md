# 🛡️ Guardian Monorepo Codebase Documentation

Welcome to the **Guardian** monorepo. This codebase houses a secure, real-time geolocation sharing and emergency SOS broadcasting system. The platform consists of a high-performance Rust backend, a cross-platform Flutter mobile client, deployment blueprints, local infrastructure configurations, and developer utility scripts.

---

## 📂 Project Structure Overview

The repository is organized as a monorepo containing the following directories:

```
guardian/
├── apps/
│   ├── backend/          # Rust backend built with Axum, SQLx, Tokio, and Postgres
│   ├── mobile/           # Flutter app built with Bloc, Geolocator, Google/Apple Maps
│   └── admin_panel/      # Admin panel configurations and documentation (.txt notes)
├── docs/                 # Documentation directory (empty)
├── infrastructure/       # Docker-compose configuration for local development
├── scripts/              # Verification, refactoring, and codebase management scripts
├── codemagic.yaml        # CI/CD configuration for iOS TestFlight publishing
└── render.yaml           # Deployment configuration for Render (Postgres & Backend)
```

---

## 🦀 Backend Service (`apps/backend`)

The backend is built with **Rust**, utilizing modern asynchronous frameworks and a Domain-Driven Design (DDD) layered architecture.

### Tech Stack
* **Web Framework:** [Axum](https://github.com/tokio-rs/axum) (v0.8) with [Tower-HTTP](https://github.com/tower-rs/tower-http) (CORS, HTTP tracing)
* **Database & Persistence:** [SQLx](https://github.com/launchbadge/sqlx) (v0.8) with PostgreSQL (async-pool, migrations, UUIDs, Chrono time types) and Redis (caching, pub/sub, jobs)
* **Asynchronous Runtime:** [Tokio](https://github.com/tokio-rs/tokio) (v1)
* **Auth & Security:** `firebase-auth`, `jsonwebtoken`, `argon2`, `password-hash`
* **Observability:** `tracing` & `tracing-subscriber` (JSON/env logging)

### Architecture & Folder Structure

```
apps/backend/src/
├── main.rs                   # App entry point, env loader, telemetry setup, server starter
├── bootstrap.rs              # App wireframe (wiring configuration, repositories, Router)
├── config/                   # Configuration loader from environment variables
├── routes/                   # Router bootstrap nesting all domain routes
├── websocket/                # Real-time WebSocket streaming handlers & presence managers
│   ├── connection_manager.rs # Central connection manager tracking client sessions
│   ├── presence_stream.rs    # User online/offline status stream
│   ├── location_stream.rs    # Real-time geolocation updates stream
│   └── sos_stream.rs         # Real-time SOS alerts stream
├── workers/                  # Asynchronous background job processors
│   ├── notification_worker.rs
│   ├── geofence_worker.rs
│   ├── audit_worker.rs
│   ├── blockchain_worker.rs
│   └── analytics_worker.rs
├── shared/                   # Common helpers, middleware, telemetry, crypto, error handling
│   ├── middleware/           # Rate limiters, JWT verification, logging, device guard
│   └── security/             # Encryption & hashing utilities
└── domains/                  # Core DDD layers containing API routes, DTOs, Handlers, Entities
    ├── identity/             # User profiles, session management, token exchanges
    ├── circles/              # Circle creation, joining, memberships, invite links
    ├── location/             # User location tracking & history
    ├── sos/                  # SOS alert broadcasting
    ├── journey/              # Active safety journeys tracking
    ├── blockchain_audit/     # Audits logged on Solana blockchain
    ├── billing/              # Subscription & checkout processing
    ├── geofencing/           # Geofence detection & alerts
    └── analytics/            # Tracking user activity patterns
```

### Key Modules Explained

1. **Bootstrap & Main (`main.rs`, `bootstrap.rs`)**: On startup, the application reads configurations from environment variables, initializes PostgreSQL connections via SQLx, runs migrations, and wires together repositories (Postgres repositories utilizing Arc pointers) into the Axum Router.
2. **WebSocket Real-time Layer (`websocket/`)**: Handlers connect clients via WebSockets and stream real-time updates. The `ConnectionManager` monitors active sessions, updating and dispatching users' locations and SOS streams.
3. **Background Processing Workers (`workers/`)**: Runs async job execution for intensive operations like geofencing (monitoring enter/exit notifications), Solana blockchain audit entries, push notification dispatching, and usage analytics.
4. **Domain-Driven Design (`domains/`)**: Features are strictly encapsulated within their own subdirectories containing:
   - **`domain/`**: Pure domain entities and repository traits.
   - **`api/`**: Axum handlers, routes, and DTOs.
   - **`infrastructure/`**: Concrete repository implementations mapping domains to PostgreSQL using SQLx.
   - **`application/`**: Use cases and orchestration logic (e.g., `refresh_token`, `firebase_exchange`).

---

## 📱 Mobile App (`apps/mobile`)

The mobile application is a cross-platform client built with **Flutter & Dart**, targeting iOS and Android. It uses a **Layered Clean Architecture** and the **Bloc** state management pattern.

### Tech Stack
* **State Management:** [Bloc](https://pub.dev/packages/bloc) & [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
* **Real-time Map & GPS:** [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter), [Apple Maps Flutter](https://pub.dev/packages/apple_maps_flutter), [Geolocator](https://pub.dev/packages/geolocator)
* **Auth:** Firebase Core/Auth integration alongside a custom secure token manager
* **Services:** `http` for REST client API calls, Awesome Notifications for local trigger alerts, device sensors, and vibrations.

### Directory Structure & Features

```
apps/mobile/lib/
├── main.dart                  # App runner (initializes Firebase, notifications, background triggers)
├── bootstrap/                 # Dependency injection, environment setup, bloc logging configuration
├── core/                      # Global theme, utility classes, constants, secure storages
│   ├── services/              # API and system services (Firebase Auth, Weather, Notifications, API client)
│   ├── security/              # Device integrity, cert pinning, secure token storage
│   ├── theme/                 # Light/Dark curated Outfit & Inter typography-based themes
│   └── widgets/               # Adaptive UI elements (Android/iOS shells, bottom navbars)
└── features/                  # UI, Business Logic & Data sources scoped by feature
    ├── auth/                  # Onboarding, Multi-step login, SMS OTP verify, profile setup
    ├── location/              # Live Map screen, member positioning, historical lines, permission guard
    ├── circles/               # Create circles, join sheets, member lists
    ├── journey/               # Start journey screen, active route watcher, completion card
    ├── settings/              # User preferences & device configuration
    └── alerts/                # Urgent alert dashboard
```

### Key Modules Explained

1. **Authentication Feature (`features/auth/`)**: Coordinates Firebase authentication workflows, OTP verifications, onboarding steps, and user profiles. Uses Bloc components (`auth_bloc`, events, states) and handler modules (`phone_auth_handler`, `profile_handler`, etc.).
2. **Live Map & Location Feature (`features/location/`)**: Renders custom maps with user-specific elements, status widgets, bottom sheets, alerts, and permissions.
3. **Core Services (`core/services/`)**: Centralizes application-wide capabilities like location geocoding, notification channels, background trigger tracking, and REST endpoints.
4. **Security Layer (`core/security/`)**: Controls token storage (via `flutter_secure_storage`), certificate pinning, and device integrity checks to avoid compromised environments.

---

## ⚙️ Infrastructure & Deployment

### 1. Local Development (`infrastructure/docker-compose.yml`)
Spins up the environment locally using Docker:
* **`backend`**: Built from the `apps/backend/Dockerfile`. Bound to port `8080`.
* **`postgres`**: Run on `postgres:15-alpine` (uses volume mapping `postgres-data`).
* **`redis`**: Run on `redis:7-alpine` (uses volume mapping `redis-data`).

### 2. Cloud Deployment (`render.yaml`)
A blueprint to deploy the Rust backend and database automatically to Render:
* **PostgreSQL (`guardian-db`)**: Managed Postgres instance.
* **Web Service (`guardian-backend`)**: Dockerized backend deployment pulling environment configurations like Apple Universal Links (`apple-app-site-association`), Google Maps API keys, and Firebase Project settings.

### 3. CI/CD Pipeline (`codemagic.yaml`)
Automated builder configured for TestFlight publishing:
* **Workflow:** Runs on a macOS M2 runner (`mac_mini_m2`).
* **App signing:** Automatically pulls profiles and certificates via App Store Connect.
* **Build command:** Compiles release IPA with custom version settings (`flutter build ipa --release`).
* **Publishing:** Deploys directly to TestFlight and alerts team members via email.

---

## 🔧 Developer Utility Scripts (`scripts/`)

* **`check_codebase.sh`**: A shell validator that checks if any modified Dart file in the authentication package exceeds a **100-line constraint** to promote clean code and runs static analysis (`flutter analyze`).
* **`split_live_map.py` / `rewrite_live_map.py`**: Python refactoring utilities used to segment the massive map screen codebase into maintainable component structures.
* **`refactor.dart`**: General Dart project reorganization script.
