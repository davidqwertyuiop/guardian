use super::handlers;
use crate::routes::AppState;
use axum::{
    routing::{get, post},
    Router,
};

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(handlers::list_notifications))
        .route("/mark-all-read", post(handlers::mark_all_read))
        .route("/{id}/read", post(handlers::mark_read))
}
