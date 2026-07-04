use axum::{routing::{get, post}, Router};
use crate::routes::AppState;
use super::handlers::{
    dismiss_sos, list_sos_broadcasts, resolve_sos, trigger_sos,
};

pub fn router() -> Router<AppState> {
    Router::new()
        // Trigger a new SOS broadcast.
        .route("/", post(trigger_sos))
        // List broadcasts for a circle (paginated, newest first).
        .route("/circles/{id}", get(list_sos_broadcasts))
        // Resolve an active SOS broadcast (any circle member).
        .route("/{id}/resolve", post(resolve_sos))
        // Dismiss own broadcast (broadcast owner only).
        .route("/{id}/dismiss", post(dismiss_sos))
}
