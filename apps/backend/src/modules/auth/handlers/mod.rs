use std::sync::Arc;
use axum::{extract::State, Json};
use serde_json::{json, Value};
use crate::routes::AppState;
use crate::shared::errors::AppError;
use super::dto::{SendOtpRequest, VerifyOtpRequest, AuthResponse};
use super::validators::validate_phone;
use crate::shared::auth::jwt::{sign_access_token, sign_refresh_token};

pub async fn health_handler() -> Json<Value> {
    Json(json!({ "status": "ok" }))
}

pub async fn send_otp_handler(
    State(state): State<AppState>,
    Json(payload): Json<SendOtpRequest>,
) -> Result<Json<Value>, AppError> {
    let phone = payload.phone.trim();
    validate_phone(phone)?;

    state.otp_store.generate_otp(phone, &state.config)?;

    Ok(Json(json!({ "message": "OTP sent successfully" })))
}

pub async fn verify_otp_handler(
    State(state): State<AppState>,
    Json(payload): Json<VerifyOtpRequest>,
) -> Result<Json<AuthResponse>, AppError> {
    let phone = payload.phone.trim();
    let code = payload.code.trim();

    if phone.is_empty() || code.is_empty() {
        return Err(AppError::InvalidInput("Phone and code are required".to_string()));
    }

    state.otp_store.verify_otp(phone, code, &state.config)?;

    let access_token = sign_access_token(phone, &state.config)?;
    let refresh_token = sign_refresh_token(phone, &state.config)?;

    Ok(Json(AuthResponse {
        access_token,
        refresh_token,
    }))
}

pub async fn latest_otp_handler(State(state): State<AppState>) -> Json<Value> {
    if let Some((phone, code)) = state.otp_store.get_latest_otp() {
        Json(json!({ "phone": phone, "code": code }))
    } else {
        Json(json!({ "error": "NOT_FOUND", "message": "No OTP generated yet." }))
    }
}
