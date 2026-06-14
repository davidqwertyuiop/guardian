use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Invalid request input: {0}")]
    InvalidInput(String),

    #[error("Rate limit exceeded. Please wait {0} seconds.")]
    RateLimit(u64),

    #[error("Unauthorized: {0}")]
    Unauthorized(String),

    #[error("Internal server error: {0}")]
    Internal(String),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, error_type, message) = match self {
            AppError::InvalidInput(msg) => (StatusCode::BAD_REQUEST, "INVALID_INPUT", msg),
            AppError::RateLimit(secs) => (
                StatusCode::TOO_MANY_REQUESTS,
                "RATE_LIMIT",
                format!("Please wait {} seconds before requesting another code.", secs),
            ),
            AppError::Unauthorized(msg) => (StatusCode::UNAUTHORIZED, "UNAUTHORIZED", msg),
            AppError::Internal(msg) => (StatusCode::INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", msg),
        };

        let body = Json(json!({
            "error": error_type,
            "message": message
        }));

        (status, body).into_response()
    }
}
