# refresh_token.rs

* **File Path:** `apps/backend/src/domains/identity/application/refresh_token.rs`
* **Type:** `RUST`

---

```rust
use std::sync::Arc;
use crate::config::AppConfig;
use crate::shared::{
    errors::AppError,
    auth::jwt::{verify_refresh_token, sign_access_token},
};
use crate::domains::identity::domain::repositories::user_repository::UserRepository;

pub struct RefreshTokenOutput {
    pub access_token: String,
}

pub struct RefreshTokenUseCase {
    pub user_repo: Arc<dyn UserRepository>,
    pub config: AppConfig,
}

impl RefreshTokenUseCase {
    pub async fn execute(&self, refresh_token: &str) -> Result<RefreshTokenOutput, AppError> {
        let claims = verify_refresh_token(refresh_token, &self.config)?;

        if claims.token_type != "refresh" {
            return Err(AppError::Unauthorized("Token must be a refresh token".to_string()));
        }

        // Verify user still exists
        let uuid = uuid::Uuid::parse_str(&claims.sub)
            .map_err(|_| AppError::Unauthorized("Invalid token subject".to_string()))?;
        self.user_repo
            .find_by_id(uuid)
            .await?
            .ok_or_else(|| AppError::Unauthorized("User not found".to_string()))?;

        let access_token = sign_access_token(&claims.sub, &claims.phone, &self.config)?;
        Ok(RefreshTokenOutput { access_token })
    }
}

```
