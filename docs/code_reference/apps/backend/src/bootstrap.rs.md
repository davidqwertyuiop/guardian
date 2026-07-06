# bootstrap.rs

* **File Path:** `apps/backend/src/bootstrap.rs`
* **Type:** `RUST`

---

```rust
use axum::Router;
use sqlx::PgPool;
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

use crate::config::AppConfig;
use crate::domains::circles::infrastructure::{
    postgres_circle_repo::PostgresCircleRepository,
    postgres_invite_repo::PostgresInviteRepository,
};
use crate::domains::identity::infrastructure::{
    postgres_session_repo::PostgresSessionRepository,
    postgres_user_repo::PostgresUserRepository,
};
use crate::domains::location::infrastructure::postgres_location_repo::PostgresLocationRepository;
use crate::domains::sos::infrastructure::postgres_sos_repo::PostgresSosRepository;
use crate::routes::{create_router, AppState};

/// Wires together the application: config, repos, gateways → Router.
pub async fn build_router(pool: PgPool, config: AppConfig) -> Router {
    let user_repo     = Arc::new(PostgresUserRepository     { pool: pool.clone() });
    let session_repo  = Arc::new(PostgresSessionRepository  { pool: pool.clone() });
    let circle_repo   = Arc::new(PostgresCircleRepository   { pool: pool.clone() });
    let invite_repo   = Arc::new(PostgresInviteRepository   { pool: pool.clone() });
    let location_repo = Arc::new(PostgresLocationRepository { pool: pool.clone() });
    let sos_repo      = Arc::new(PostgresSosRepository      { pool: pool.clone() });

    let state = AppState {
        config,
        db_pool: pool,
        user_repo,
        session_repo,
        circle_repo,
        invite_repo,
        location_repo,
        sos_repo,
    };

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    create_router(state)
        .layer(TraceLayer::new_for_http())
        .layer(cors)
}

```
