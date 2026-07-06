use super::handlers::*;
use crate::routes::AppState;
use axum::{routing::post, Router};

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/start", post(start_journey))
        .route("/stay", post(stay_journey))
        .route("/stop", post(stop_journey))
}
