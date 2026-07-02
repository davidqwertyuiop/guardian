use std::sync::Arc;
use axum::{routing::get, Router};
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
}

/// Build the complete Axum router with all domain routes nested.
pub fn create_router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(|| async { "Guardian API v2 — OK" }))
        .route("/invite/{token}", get(crate::domains::circles::api::handlers::invite_landing_page))
        .nest("/api/v1/auth", crate::domains::identity::api::routes::router())
        .nest("/api/v1/circles", crate::domains::circles::api::routes::router())
        // Future domains nested here as they are implemented:
        // .nest("/api/v1/location",  crate::domains::location::api::routes::router())
        // .nest("/api/v1/sos",       crate::domains::sos::api::routes::router())
        .with_state(state)
}
