use serde::{Deserialize, Serialize};
use std::time::{SystemTime, UNIX_EPOCH};
use jsonwebtoken::{encode, Header, EncodingKey};
use crate::config::AppConfig;
use crate::shared::errors::AppError;

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String, // Phone number
    pub exp: usize,  // Expiration time
    pub token_type: String, // "access" or "refresh"
}

pub fn sign_access_token(phone: &str, config: &AppConfig) -> Result<String, AppError> {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    // Access Token: 15 minutes (900 seconds)
    let expiration = now + 900;

    let claims = Claims {
        sub: phone.to_string(),
        exp: expiration as usize,
        token_type: "access".to_string(),
    };

    let header = Header::default();
    let encoding_key = EncodingKey::from_secret(config.jwt_secret.as_bytes());

    encode(&header, &claims, &encoding_key)
        .map_err(|e| AppError::Internal(format!("Failed to sign access token: {}", e)))
}

pub fn sign_refresh_token(phone: &str, config: &AppConfig) -> Result<String, AppError> {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    // Refresh Token: 30 days (30 * 86400 seconds)
    let expiration = now + (30 * 86400);

    let claims = Claims {
        sub: phone.to_string(),
        exp: expiration as usize,
        token_type: "refresh".to_string(),
    };

    let header = Header::default();
    let encoding_key = EncodingKey::from_secret(config.jwt_secret.as_bytes());

    encode(&header, &claims, &encoding_key)
        .map_err(|e| AppError::Internal(format!("Failed to sign refresh token: {}", e)))
}
