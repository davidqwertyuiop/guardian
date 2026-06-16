use axum::{routing::{get, post}, Router};
use crate::routes::AppState;
use super::handlers::{send_otp_handler, verify_otp_handler, latest_otp_handler, update_profile_handler};

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/otp/send", post(send_otp_handler))
        .route("/otp/verify", post(verify_otp_handler))
        .route("/otp/latest", get(latest_otp_handler))
        .route("/profile", post(update_profile_handler))
}
