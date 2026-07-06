# request_logger.rs

* **File Path:** `apps/backend/src/shared/middleware/request_logger.rs`
* **Type:** `RUST`

---

```rust
use axum::{
    body::Body,
    http::Request,
    middleware::Next,
    response::Response,
};
use std::time::Instant;

pub async fn log_requests(req: Request<Body>, next: Next) -> Response {
    let start = Instant::now();
    let method = req.method().clone();
    let uri = req.uri().clone();

    let response = next.run(req).await;

    let duration = start.elapsed();
    tracing::info!(
        method = %method,
        uri = %uri,
        status = %response.status().as_u16(),
        duration = ?duration,
        "HTTP Request Processed"
    );

    response
}

```
