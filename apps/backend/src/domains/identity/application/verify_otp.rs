use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use crate::config::AppConfig;
use crate::shared::{
    errors::AppError,
    auth::jwt::{sign_access_token, sign_refresh_token},
};
use crate::domains::identity::domain::repositories::{
    otp_repository::OtpRepository,
    user_repository::UserRepository,
};

pub struct VerifyOtpOutput {
    pub access_token: String,
    pub refresh_token: String,
    pub user_id: String,
    pub phone: String,
    pub is_profile_complete: bool,
}

pub struct VerifyOtpUseCase {
    pub otp_repo: Arc<dyn OtpRepository>,
    pub user_repo: Arc<dyn UserRepository>,
    pub config: AppConfig,
}

impl VerifyOtpUseCase {
    pub async fn execute(&self, phone: &str, code: &str) -> Result<VerifyOtpOutput, AppError> {
        let phone = phone.trim();
        let code = code.trim();

        if phone.is_empty() || code.is_empty() {
            return Err(AppError::InvalidInput("Phone and code are required".to_string()));
        }

        let entry = self
            .otp_repo
            .get(phone)
            .await?
            .ok_or_else(|| AppError::Unauthorized("No pending verification. Request a new code.".to_string()))?;

        // Check expiry
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs();
        let elapsed = now.saturating_sub(entry.created_at_secs);
        if elapsed > self.config.otp_ttl_seconds {
            self.otp_repo.delete(phone).await?;
            return Err(AppError::Unauthorized("Verification code has expired. Request a new one.".to_string()));
        }

        if entry.code.trim() != code {
            return Err(AppError::Unauthorized("Invalid verification code.".to_string()));
        }

        // Consume the OTP
        self.otp_repo.delete(phone).await?;

        // Fetch or create user
        let user = match self.user_repo.find_by_phone(phone).await? {
            Some(u) => u,
            None => self.user_repo.create(phone).await?,
        };

        let user_id = user.id.to_string();
        let access_token = sign_access_token(&user_id, phone, &self.config)?;
        let refresh_token = sign_refresh_token(&user_id, phone, &self.config)?;

        Ok(VerifyOtpOutput {
            access_token,
            refresh_token,
            user_id,
            phone: phone.to_string(),
            is_profile_complete: user.is_profile_complete,
        })
    }
}
