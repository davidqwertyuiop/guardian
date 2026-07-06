# jwt_auth.rs

* **File Path:** `apps/backend/src/shared/middleware/jwt_auth.rs`
* **Type:** `RUST`

---

```rust
use axum::{
    async_trait,
    extract::FromRequestParts,
    http::{request::Parts, header::AUTHORIZATION},
};
use jsonwebtoken::{decode, DecodingKey, Validation};
use crate::config::AppConfig;
use crate::shared::auth::jwt::Claims;
use crate::shared::errors::AppError;

pub struct AuthenticatedUser {
    pub phone: String,
}

#[async_trait]
impl<S> FromRequestParts<S> for AuthenticatedUser
where
    S: Send + Sync,
{
    type Rejection = AppError;

    async fn from_request_parts(parts: &mut Parts, _state: &S) -> Result<Self, Self::Rejection> {
        // 1. Extract Authorization header
        let auth_header = parts
            .headers
            .get(AUTHORIZATION)
            .and_then(|value| value.to_str().ok())
            .ok_or_else(|| AppError::Unauthorized("Missing authorization header".to_string()))?;

        if !auth_header.starts_with("Bearer ") {
            return Err(AppError::Unauthorized("Invalid authorization format".to_string()));
        }

        let token = &auth_header[7..];

        // 2. We extract config from extension (which we will add in main.rs)
        let config = parts
            .extensions
            .get::<AppConfig>()
            .ok_or_else(|| AppError::Internal("Config not loaded".to_string()))?;

        // 3. Decode token
        let validation = Validation::default();
        let token_data = decode::<Claims>(
            token,
            &DecodingKey::from_secret(config.jwt_secret.as_bytes()),
            &validation,
        )
        .map_err(|_| AppError::Unauthorized("Invalid or expired token".to_string()))?;

        if token_data.claims.token_type != "access" {
            return Err(AppError::Unauthorized("Invalid token type".to_string()));
        }

        Ok(AuthenticatedUser {
            phone: token_data.claims.sub,
        })
    }
}

```
