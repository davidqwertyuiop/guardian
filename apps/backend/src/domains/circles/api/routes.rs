use super::handlers::*;
use crate::routes::AppState;
use axum::{
    routing::{delete, get, post},
    Router,
};

pub fn router() -> Router<AppState> {
    Router::new()
        // Create a new circle (owner)
        .route("/", post(create_circle))
        // List circles I'm a member of
        .route("/", get(list_circles))
        // Get members of a specific circle
        .route("/{id}/members", get(get_members))
        // Join by 4-char code
        .route("/join/code", post(join_by_code))
        // Join by URL-safe link token
        .route("/join/link", post(join_by_link))
        // Leave a circle
        .route("/{id}/leave", post(leave_circle))
        // Delete a circle
        .route("/{id}", delete(delete_circle))
        // Get specific circle invite details
        .route("/{id}/invite", get(get_invite_details))
        // Remove a member
        .route("/{id}/members/{member_id}", delete(remove_circle_member))
}
