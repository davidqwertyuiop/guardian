use super::handlers;
use crate::routes::AppState;
use axum::{
    routing::{get, patch, post},
    Router,
};

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/firebase-exchange", post(handlers::firebase_exchange))
        .route("/profile", patch(handlers::setup_profile))
        .route("/preferences", patch(handlers::update_preferences))
        .route("/refresh", post(handlers::refresh_token))
        .route("/me", get(handlers::get_me))
        .route("/sessions", get(handlers::get_sessions))
        .route("/devices", post(handlers::register_device))
        .route(
            "/sessions/{hash}",
            axum::routing::delete(handlers::revoke_session),
        )
}
