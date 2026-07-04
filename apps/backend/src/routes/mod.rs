use std::sync::Arc;
use axum::{extract::State, routing::get, Router};
use sqlx::PgPool;
use crate::config::AppConfig;
use crate::domains::identity::domain::repositories::{
    user_repository::UserRepository,
    session_repository::SessionRepository,
};
use crate::domains::circles::domain::repositories::{
    circle_repository::CircleRepository,
    invite_repository::InviteRepository,
};
use crate::domains::location::domain::repositories::location_repository::LocationRepository;
use crate::domains::sos::domain::repositories::sos_repository::SosRepository;

/// Central application state — cloned into every request handler.
#[derive(Clone)]
pub struct AppState {
    pub config: AppConfig,
    pub db_pool: PgPool,
    // Identity domain
    pub user_repo: Arc<dyn UserRepository>,
    pub session_repo: Arc<dyn SessionRepository>,
    // Circles domain
    pub circle_repo: Arc<dyn CircleRepository>,
    pub invite_repo: Arc<dyn InviteRepository>,
    // Location domain
    pub location_repo: Arc<dyn LocationRepository>,
    // SOS domain
    pub sos_repo: Arc<dyn SosRepository>,
}

/// Build the complete Axum router with all domain routes nested.
pub fn create_router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(|| async { "Guardian API v2 — OK" }))
        .route("/invite/{token}", get(crate::domains::circles::api::handlers::invite_landing_page))
        .route("/api/v1/config/maps", get(maps_config))
        .route("/.well-known/apple-app-site-association", get(apple_app_site_association))
        .route("/.well-known/assetlinks.json", get(assetlinks_json))
        .nest("/api/v1/auth", crate::domains::identity::api::routes::router())
        .nest("/api/v1/circles", crate::domains::circles::api::routes::router())
        .nest("/api/v1/location", crate::domains::location::api::routes::router())
        .nest("/api/v1/sos",      crate::domains::sos::api::routes::router())
        .with_state(state)
}

async fn maps_config(State(state): State<AppState>) -> axum::Json<serde_json::Value> {
    axum::Json(serde_json::json!({
        "android_key": state.config.maps_api_key_android,
        "ios_key": state.config.maps_api_key_ios
    }))
}

// ── Universal Links Endpoints ───────────────────────────────────────────────

async fn apple_app_site_association(State(state): State<AppState>) -> axum::Json<serde_json::Value> {
    let app_id = format!("{}.com.sijibomi.guardian", state.config.apple_team_id);
    axum::Json(serde_json::json!({
        "applinks": {
            "apps": [],
            "details": [
                {
                    "appID": app_id,
                    "paths": ["/invite/*"]
                }
            ]
        }
    }))
}

async fn assetlinks_json(State(state): State<AppState>) -> axum::Json<serde_json::Value> {
    axum::Json(serde_json::json!([
        {
            "relation": ["delegate_permission/common.handle_all_urls"],
            "target": {
                "namespace": "android_app",
                "package_name": "com.sijibomi.guardian",
                "sha256_cert_fingerprints": [
                    state.config.android_sha256_cert_fingerprint
                ]
            }
        }
    ]))
}
