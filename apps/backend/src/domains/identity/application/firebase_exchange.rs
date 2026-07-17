use crate::config::AppConfig;
use crate::domains::identity::domain::entities::user_session::UserSession;
use crate::domains::identity::domain::repositories::{
    session_repository::SessionRepository, user_repository::UserRepository,
};
use crate::shared::auth::jwt::{sign_access_token, sign_refresh_token};
use crate::shared::errors::AppError;
use chrono::{Duration, Utc};
use std::sync::Arc;
use uuid::Uuid;

pub struct FirebaseExchangeUseCase {
    pub user_repo: Arc<dyn UserRepository>,
    pub session_repo: Arc<dyn SessionRepository>,
    pub config: AppConfig,
}

pub struct FirebaseExchangeOutput {
    pub access_token: String,
    pub refresh_token: String,
    pub user_id: String,
    pub phone: String,
    pub is_profile_complete: bool,
}

impl FirebaseExchangeUseCase {
    pub async fn execute(
        &self,
        phone: &str,
        device_name: &str,
        device_model: Option<String>,
        platform: &str,
    ) -> Result<FirebaseExchangeOutput, AppError> {
        let phone = phone.to_string();

        let user = match self.user_repo.find_by_phone(&phone).await? {
            Some(u) => u,
            None => self.user_repo.create(&phone).await?,
        };

        let user_id = user.id.to_string();
        let access_token = sign_access_token(&user_id, &phone, &self.config)?;
        let refresh_token = sign_refresh_token(&user_id, &phone, &self.config)?;
        // For simplicity, just store raw or md5/sha256 of refresh_token (In prod: hash it securely)
        let refresh_token_hash = refresh_token.clone();

        // Clear existing session for this same device (same device_name + platform)
        if let Ok(existing) = self.session_repo.list_for_user(user.id).await {
            for s in existing {
                if s.device_name.to_lowercase() == device_name.to_lowercase()
                    && s.platform.to_lowercase() == platform.to_lowercase()
                {
                    let _ = self
                        .session_repo
                        .delete_by_token_hash(&s.refresh_token_hash)
                        .await;
                }
            }
        }

        let session = UserSession {
            id: Uuid::new_v4(),
            user_id: user.id,
            device_name: device_name.to_string(),
            device_model,
            platform: platform.to_lowercase(),
            refresh_token_hash,
            expires_at: Utc::now() + Duration::days(30),
            last_active_at: Utc::now(),
            created_at: Utc::now(),
        };
        self.session_repo.create(&session).await?;

        Ok(FirebaseExchangeOutput {
            access_token,
            refresh_token,
            user_id: user.id.to_string(),
            phone: user.phone,
            is_profile_complete: user.is_profile_complete,
        })
    }
}
