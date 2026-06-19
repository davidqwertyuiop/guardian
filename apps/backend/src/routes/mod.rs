use std::sync::Arc;
use axum::{routing::get, Router};
use sqlx::PgPool;
use crate::config::AppConfig;
use crate::domains::identity::domain::repositories::{
    user_repository::UserRepository,
    otp_repository::OtpRepository,
};
use crate::domains::identity::infrastructure::sms_gateway::SmsGateway;

/// Central application state — cloned into every request handler.
#[derive(Clone)]
pub struct AppState {
    pub config: AppConfig,
    pub db_pool: PgPool,
    pub user_repo: Arc<dyn UserRepository>,
    pub otp_repo: Arc<dyn OtpRepository>,
    pub sms_gateway: Arc<dyn SmsGateway>,
}

/// Build the complete Axum router with all domain routes nested.
pub fn create_router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(|| async { "Guardian API v2 — OK" }))
        .nest("/api/v1/auth", crate::domains::identity::api::routes::router())
        // Future domains nested here as they are implemented:
        // .nest("/api/v1/circles",   crate::domains::circles::api::routes::router())
        // .nest("/api/v1/location",  crate::domains::location::api::routes::router())
        // .nest("/api/v1/sos",       crate::domains::sos::api::routes::router())
        .with_state(state)
}
