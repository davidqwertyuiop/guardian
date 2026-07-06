# auth.rs

* **File Path:** `apps/backend/src/routes/auth.rs`
* **Type:** `RUST`

---

```rust
use std::sync::Arc;
use axum::{
    extract::State,
    Json,
};
use serde_json::{json, Value};

use crate::config::AppConfig;
use crate::error::AppError;
use crate::models::auth::{AuthResponse, SendOtpRequest, SendOtpResponse, VerifyOtpRequest};
use crate::services::otp::OtpStore;
use crate::services::jwt::sign_token;

#[derive(Clone)]
pub struct AppState {
    pub config: AppConfig,
    pub otp_store: Arc<OtpStore>,
}

pub async fn health_handler() -> Json<Value> {
    Json(json!({ "status": "ok" }))
}

pub async fn send_otp_handler(
    State(state): State<AppState>,
    Json(payload): Json<SendOtpRequest>,
) -> Result<Json<SendOtpResponse>, AppError> {
    let phone = payload.phone.trim();

    // Basic validation
    if phone.is_empty() {
        return Err(AppError::InvalidInput("Phone number cannot be empty.".to_string()));
    }
    if phone.len() < 7 {
        return Err(AppError::InvalidInput("Invalid phone number format.".to_string()));
    }

    state.otp_store.generate_otp(phone, &state.config)?;

    Ok(Json(SendOtpResponse {
        message: "OTP sent successfully".to_string(),
    }))
}

pub async fn verify_otp_handler(
    State(state): State<AppState>,
    Json(payload): Json<VerifyOtpRequest>,
) -> Result<Json<AuthResponse>, AppError> {
    let phone = payload.phone.trim();
    let code = payload.code.trim();

    if phone.is_empty() {
        return Err(AppError::InvalidInput("Phone number cannot be empty.".to_string()));
    }
    if code.is_empty() {
        return Err(AppError::InvalidInput("Verification code cannot be empty.".to_string()));
    }

    // Verify OTP against store
    state.otp_store.verify_otp(phone, code, &state.config)?;

    // Generate JWT token
    let token = sign_token(phone, &state.config)?;

    Ok(Json(AuthResponse {
        token,
        expires_in: 86400,
    }))
}

pub async fn latest_otp_handler(
    State(state): State<AppState>,
) -> Json<Value> {
    if let Some((phone, code)) = state.otp_store.get_latest_otp() {
        Json(json!({
            "phone": phone,
            "code": code
        }))
    } else {
        Json(json!({
            "error": "NOT_FOUND",
            "message": "No OTP generated yet."
        }))
    }
}

```
