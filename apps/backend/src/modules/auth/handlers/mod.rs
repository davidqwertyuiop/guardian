use std::sync::Arc;
use axum::{extract::State, Json};
use serde_json::{json, Value};
use sqlx::Row;
use crate::routes::AppState;
use crate::shared::errors::AppError;
use super::dto::{SendOtpRequest, VerifyOtpRequest, AuthResponse, UpdateProfileRequest, ProfileResponse};
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

    // Fetch user from DB or create new user
    let user_row = sqlx::query("SELECT id, name FROM users WHERE phone = $1")
        .bind(phone)
        .fetch_optional(&state.db_pool)
        .await
        .map_err(|e| AppError::Internal(format!("Database query error: {}", e)))?;

    let (user_id, name) = match user_row {
        Some(row) => {
            let id: uuid::Uuid = row.get("id");
            let name: Option<String> = row.get("name");
            (id.to_string(), name)
        }
        None => {
            let new_row = sqlx::query("INSERT INTO users (phone) VALUES ($1) RETURNING id, name")
                .bind(phone)
                .fetch_one(&state.db_pool)
                .await
                .map_err(|e| AppError::Internal(format!("Database insert error: {}", e)))?;
            let id: uuid::Uuid = new_row.get("id");
            let name: Option<String> = new_row.get("name");
            (id.to_string(), name)
        }
    };

    let access_token = sign_access_token(phone, &state.config)?;
    let refresh_token = sign_refresh_token(phone, &state.config)?;

    Ok(Json(AuthResponse {
        token: access_token.clone(),
        access_token,
        refresh_token,
        user_id,
        name,
    }))
}

pub async fn update_profile_handler(
    State(state): State<AppState>,
    Json(payload): Json<UpdateProfileRequest>,
) -> Result<Json<ProfileResponse>, AppError> {
    let phone = payload.phone.trim();
    let name = payload.name.trim();

    if phone.is_empty() || name.is_empty() {
        return Err(AppError::InvalidInput("Phone and name are required".to_string()));
    }

    let row = sqlx::query("UPDATE users SET name = $1 WHERE phone = $2 RETURNING id")
        .bind(name)
        .bind(phone)
        .fetch_optional(&state.db_pool)
        .await
        .map_err(|e| AppError::Internal(format!("Database update error: {}", e)))?;

    match row {
        Some(r) => {
            let id: uuid::Uuid = r.get("id");
            Ok(Json(ProfileResponse {
                user_id: id.to_string(),
                phone: phone.to_string(),
                name: name.to_string(),
            }))
        }
        None => {
            let new_row = sqlx::query("INSERT INTO users (phone, name) VALUES ($1, $2) RETURNING id")
                .bind(phone)
                .bind(name)
                .fetch_one(&state.db_pool)
                .await
                .map_err(|e| AppError::Internal(format!("Database insert error: {}", e)))?;
            let id: uuid::Uuid = new_row.get("id");
            Ok(Json(ProfileResponse {
                user_id: id.to_string(),
                phone: phone.to_string(),
                name: name.to_string(),
            }))
        }
    }
}

pub async fn latest_otp_handler(State(state): State<AppState>) -> Json<Value> {
    if let Some((phone, code)) = state.otp_store.get_latest_otp() {
        Json(json!({ "phone": phone, "code": code }))
    } else {
        Json(json!({ "error": "NOT_FOUND", "message": "No OTP generated yet." }))
    }
}
