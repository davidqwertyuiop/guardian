use axum::{routing::{get, post, patch}, Router};
use crate::routes::AppState;
use super::handlers;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/send-otp",   post(handlers::send_otp))
        .route("/verify-otp", post(handlers::verify_otp))
        .route("/profile",    patch(handlers::setup_profile))
        .route("/refresh",    post(handlers::refresh_token))
        .route("/me",         get(handlers::get_me))
}
