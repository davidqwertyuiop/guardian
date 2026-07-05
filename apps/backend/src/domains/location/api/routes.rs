use axum::{routing::{get, put}, Router};
use crate::routes::AppState;
use super::handlers::{get_circle_locations, update_location, get_nearest_member_location};

pub fn router() -> Router<AppState> {
    Router::new()
        // Device pushes its current GPS fix.
        .route("/", put(update_location))
        // Fetch all member locations for the map overlay.
        .route("/circles/{id}", get(get_circle_locations))
        // Fetch nearest circle member location relative to the caller.
        .route("/circles/{id}/nearest", get(get_nearest_member_location))
}
