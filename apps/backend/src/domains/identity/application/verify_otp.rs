use crate::config::AppConfig;
use crate::domains::identity::domain::entities::user_session::UserSession;
use crate::domains::identity::domain::repositories::{
    session_repository::SessionRepository, user_repository::UserRepository,
};
use crate::infrastructure::cache::otp_store::OtpStore;
use crate::shared::auth::jwt::{sign_access_token, sign_refresh_token};
use crate::shared::errors::AppError;
use chrono::{Duration, Utc};
use std::sync::Arc;
use uuid::Uuid;

pub struct VerifyOtpOutput {
    pub access_token: String,
    pub refresh_token: String,
    pub user_id: String,
    pub phone: String,
    pub is_profile_complete: bool,
}

pub struct VerifyOtpUseCase {
    pub otp_store: Arc<OtpStore>,
    pub user_repo: Arc<dyn UserRepository>,
    pub session_repo: Arc<dyn SessionRepository>,
    pub config: AppConfig,
}

impl VerifyOtpUseCase {
    pub async fn execute(
        &self,
        phone: &str,
        code: &str,
        device_name: &str,
        device_model: Option<String>,
        platform: &str,
    ) -> Result<VerifyOtpOutput, AppError> {
        // 1. Verify OTP
        let valid = self.otp_store.verify(phone, code).await;
        if !valid {
            return Err(AppError::Unauthorized(
                "Invalid or expired verification code".into(),
            ));
        }

        // 2. Upsert user (same logic as firebase_exchange)
        let user = match self.user_repo.find_by_phone(phone).await? {
            Some(u) => u,
            None => self.user_repo.create(phone).await?,
        };

        // 3. Issue tokens
        let user_id = user.id.to_string();
        let access_token = sign_access_token(&user_id, phone, &self.config)?;
        let refresh_token = sign_refresh_token(&user_id, phone, &self.config)?;

        // 4. Clear any existing session for this device, then create a new one
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
            refresh_token_hash: refresh_token.clone(),
            expires_at: Utc::now() + Duration::days(30),
            last_active_at: Utc::now(),
            created_at: Utc::now(),
        };
        self.session_repo.create(&session).await?;

        Ok(VerifyOtpOutput {
            access_token,
            refresh_token,
            user_id: user.id.to_string(),
            phone: user.phone,
            is_profile_complete: user.is_profile_complete,
        })
    }
}
