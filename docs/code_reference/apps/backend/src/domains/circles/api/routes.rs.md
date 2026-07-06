# routes.rs

* **File Path:** `apps/backend/src/domains/circles/api/routes.rs`
* **Type:** `RUST`

---

```rust
use axum::{routing::{get, post}, Router};
use crate::routes::AppState;
use super::handlers::*;

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
}

```
