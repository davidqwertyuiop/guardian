use axum::{routing::{get, put}, Router};
use crate::routes::AppState;
use super::handlers::{get_circle_locations, update_location};

pub fn router() -> Router<AppState> {
    Router::new()
        // Device pushes its current GPS fix.
        .route("/", put(update_location))
        // Fetch all member locations for the map overlay.
        .route("/circles/{id}", get(get_circle_locations))
}
