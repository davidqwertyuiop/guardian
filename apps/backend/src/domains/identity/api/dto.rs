use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

// ── Requests ────────────────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct SendOtpRequest {
    pub phone: String,
}

#[derive(Debug, Deserialize)]
pub struct VerifyOtpRequest {
    pub phone: String,
    pub code: String,
}

#[derive(Debug, Deserialize)]
pub struct SetupProfileRequest {
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct RefreshTokenRequest {
    pub refresh_token: String,
}

// ── Responses ───────────────────────────────────────────────────────────────

#[derive(Debug, Serialize)]
pub struct SendOtpResponse {
    pub message: String,
}

#[derive(Debug, Serialize)]
pub struct AuthResponse {
    pub access_token: String,
    pub refresh_token: String,
    pub user_id: String,
    pub phone: String,
    pub is_profile_complete: bool,
}

#[derive(Debug, Serialize)]
pub struct ProfileResponse {
    pub user_id: String,
    pub phone: String,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub is_profile_complete: bool,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize)]
pub struct RefreshTokenResponse {
    pub access_token: String,
}
