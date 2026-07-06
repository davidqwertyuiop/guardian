# jwt.rs

* **File Path:** `apps/backend/src/shared/auth/jwt.rs`
* **Type:** `RUST`

---

```rust
use serde::{Deserialize, Serialize};
use std::time::{SystemTime, UNIX_EPOCH};
use jsonwebtoken::{encode, decode, Header, EncodingKey, DecodingKey, Validation};
use crate::config::AppConfig;
use crate::shared::errors::AppError;

/// JWT claims for both access and refresh tokens.
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    /// Subject: user_id (UUID string)
    pub sub: String,
    /// Expiry (Unix timestamp)
    pub exp: usize,
    /// Token type: "access" | "refresh"
    pub token_type: String,
    /// Phone number — kept for convenience in handlers
    pub phone: String,
}

fn now_secs() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

/// Sign a short-lived access token (15 min).
pub fn sign_access_token(user_id: &str, phone: &str, config: &AppConfig) -> Result<String, AppError> {
    let exp = (now_secs() + 900) as usize;
    let claims = Claims {
        sub: user_id.to_string(),
        exp,
        token_type: "access".to_string(),
        phone: phone.to_string(),
    };
    encode(&Header::default(), &claims, &EncodingKey::from_secret(config.jwt_secret.as_bytes()))
        .map_err(|e| AppError::Internal(format!("Failed to sign access token: {}", e)))
}

/// Sign a long-lived refresh token (30 days).
pub fn sign_refresh_token(user_id: &str, phone: &str, config: &AppConfig) -> Result<String, AppError> {
    let exp = (now_secs() + 30 * 86400) as usize;
    let claims = Claims {
        sub: user_id.to_string(),
        exp,
        token_type: "refresh".to_string(),
        phone: phone.to_string(),
    };
    encode(&Header::default(), &claims, &EncodingKey::from_secret(config.jwt_refresh_secret.as_bytes()))
        .map_err(|e| AppError::Internal(format!("Failed to sign refresh token: {}", e)))
}

/// Verify and decode an access token.
pub fn verify_access_token(token: &str, config: &AppConfig) -> Result<Claims, AppError> {
    decode::<Claims>(
        token,
        &DecodingKey::from_secret(config.jwt_secret.as_bytes()),
        &Validation::default(),
    )
    .map(|data| data.claims)
    .map_err(|e| AppError::Unauthorized(format!("Invalid or expired token: {}", e)))
}

/// Verify and decode a refresh token.
pub fn verify_refresh_token(token: &str, config: &AppConfig) -> Result<Claims, AppError> {
    decode::<Claims>(
        token,
        &DecodingKey::from_secret(config.jwt_refresh_secret.as_bytes()),
        &Validation::default(),
    )
    .map(|data| data.claims)
    .map_err(|e| AppError::Unauthorized(format!("Invalid or expired refresh token: {}", e)))
}

```
