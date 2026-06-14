use std::sync::Arc;
use axum::{routing::get, Router};
use crate::config::AppConfig;
use crate::modules::auth::services::otp::OtpStore;

#[derive(Clone)]
pub struct AppState {
    pub config: AppConfig,
    pub otp_store: Arc<OtpStore>,
}

pub fn create_router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(|| async { "OK" }))
        .nest("/api/v1/auth", crate::modules::auth::routes::router())
        .nest("/api/v1/family", crate::modules::family::routes::router())
        .nest("/api/v1/location", crate::modules::location::routes::router())
        .nest("/api/v1/journey", crate::modules::journey::routes::router())
        .nest("/api/v1/emergency", crate::modules::emergency::routes::router())
        .nest("/api/v1/alerts", crate::modules::alerts::routes::router())
        .nest("/api/v1/settings", crate::modules::settings::routes::router())
        .with_state(state)
}
