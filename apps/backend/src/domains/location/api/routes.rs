use super::handlers::{get_circle_locations, get_nearest_member_location, update_location};
use crate::routes::AppState;
use axum::{
    routing::{get, put},
    Router,
};

pub fn router() -> Router<AppState> {
    Router::new()
        // Device pushes its current GPS fix.
        .route("/", put(update_location))
        // Fetch all member locations for the map overlay.
        .route("/circles/{id}", get(get_circle_locations))
        // Fetch nearest circle member location relative to the caller.
        .route("/circles/{id}/nearest", get(get_nearest_member_location))
}
