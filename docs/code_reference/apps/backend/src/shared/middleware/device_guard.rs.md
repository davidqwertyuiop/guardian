# device_guard.rs

* **File Path:** `apps/backend/src/shared/middleware/device_guard.rs`
* **Type:** `RUST`

---

```rust
use axum::{
    body::Body,
    http::Request,
    middleware::Next,
    response::Response,
};
use crate::shared::errors::AppError;

pub async fn device_guard(req: Request<Body>, next: Next) -> Result<Response, AppError> {
    // Check request headers for Device-ID and ensure it is authenticated/registered
    if let Some(_device_id) = req.headers().get("X-Device-ID") {
        // Validation logic here
    }
    
    Ok(next.run(req).await)
}

```
