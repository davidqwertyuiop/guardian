use axum::{routing::get, Router};
use crate::routes::AppState;

pub fn router() -> Router<AppState> {
    Router::new().route("/", get(|| async { "emergency SOS placeholder" }))
}
