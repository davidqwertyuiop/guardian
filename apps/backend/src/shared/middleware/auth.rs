use crate::routes::AppState;
use crate::shared::{
    auth::jwt::{verify_access_token, Claims},
    errors::AppError,
};
use axum::{extract::FromRequestParts, http::request::Parts};

/// Axum extractor that reads the `Authorization: Bearer <token>` header,
/// validates the JWT, and injects the `Claims` into the handler.
pub struct AuthUser(pub Claims);

impl FromRequestParts<AppState> for AuthUser {
    type Rejection = AppError;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        let auth_header = parts
            .headers
            .get("Authorization")
            .and_then(|v| v.to_str().ok())
            .ok_or_else(|| AppError::Unauthorized("Missing Authorization header".to_string()))?;

        let token = auth_header.strip_prefix("Bearer ").ok_or_else(|| {
            AppError::Unauthorized("Authorization header must start with 'Bearer '".to_string())
        })?;

        let claims = verify_access_token(token, &state.config)?;

        if claims.token_type != "access" {
            return Err(AppError::Unauthorized(
                "Token type must be 'access'".to_string(),
            ));
        }

        Ok(AuthUser(claims))
    }
}
