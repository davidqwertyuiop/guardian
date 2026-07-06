# routes.rs

* **File Path:** `apps/backend/src/domains/journey/api/routes.rs`
* **Type:** `RUST`

---

```rust
use axum::{routing::post, Router};
use crate::routes::AppState;
use super::handlers::*;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/start", post(start_journey))
        .route("/stay", post(stay_journey))
        .route("/stop", post(stop_journey))
}

```
