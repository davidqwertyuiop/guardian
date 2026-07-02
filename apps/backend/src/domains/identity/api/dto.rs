use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

// ── Requests ────────────────────────────────────────────────────────────────



#[derive(Debug, Deserialize)]
pub struct SetupProfileRequest {
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdatePreferencesRequest {
    pub location_enabled: bool,
    pub notifications_enabled: bool,
}

#[derive(Debug, Deserialize)]
pub struct RefreshTokenRequest {
    pub refresh_token: String,
}

#[derive(Debug, Deserialize)]
pub struct FirebaseExchangeRequest {
    pub phone: String,
    pub id_token: String,
    pub platform: String,
    pub device_name: String,
    pub device_model: Option<String>,
}

// Responses 



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
    pub location_enabled: bool,
    pub notifications_enabled: bool,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize)]
pub struct RefreshTokenResponse {
    pub access_token: String,
}

#[derive(Debug, Serialize)]
pub struct SessionResponse {
    pub device_name: String,
    pub device_model: Option<String>,
    pub platform: String,
    pub last_active_at: DateTime<Utc>,
    pub created_at: DateTime<Utc>,
}
