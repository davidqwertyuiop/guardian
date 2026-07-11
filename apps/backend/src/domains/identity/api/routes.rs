use super::handlers;
use crate::routes::AppState;
use axum::{
    routing::{delete, get, patch, post},
    Router,
};

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/firebase-exchange", post(handlers::firebase_exchange))
        .route("/otp/send", post(handlers::send_otp_handler))
        .route("/otp/verify", post(handlers::verify_otp_handler))
        .route("/profile", patch(handlers::setup_profile))
        .route("/preferences", patch(handlers::update_preferences))
        .route("/avatar", post(handlers::update_avatar))
        .route("/refresh", post(handlers::refresh_token))
        .route("/me", get(handlers::get_me))
        .route("/sessions", get(handlers::get_sessions))
        .route("/devices", post(handlers::register_device))
        .route("/account", delete(handlers::delete_account))
        .route(
            "/sessions/{hash}",
            delete(handlers::revoke_session),
        )
}

