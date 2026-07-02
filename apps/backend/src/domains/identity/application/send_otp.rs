use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use crate::config::AppConfig;
use crate::shared::errors::AppError;
use crate::domains::identity::domain::{
    value_objects::phone_number::PhoneNumber,
    repositories::{otp_repository::OtpRepository, user_repository::UserRepository},
};
use crate::domains::identity::infrastructure::sms_gateway::SmsGateway;

pub struct SendOtpUseCase {
    pub otp_repo:    Arc<dyn OtpRepository>,
    pub user_repo:   Arc<dyn UserRepository>,
    pub sms_gateway: Arc<dyn SmsGateway>,
    pub config:      AppConfig,
}

impl SendOtpUseCase {
    pub async fn execute(&self, raw_phone: &str) -> Result<(), AppError> {
        // 1. Validate phone format
        let phone = PhoneNumber::parse(raw_phone)?;

        // 2. Rate limiting — check if there's a recent OTP session
        if let Some(existing) = self.otp_repo.get(phone.as_str()).await? {
            let now = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap_or_default()
                .as_secs();
            let elapsed = now.saturating_sub(existing.created_at_secs);
            if elapsed < self.config.rate_limit_window_seconds {
                let remaining = self.config.rate_limit_window_seconds - elapsed;
                return Err(AppError::RateLimit(remaining));
            }
        }

        // 3. Upsert user so they exist in the DB before verification
        if self.user_repo.find_by_phone(phone.as_str()).await?.is_none() {
            self.user_repo.create(phone.as_str()).await?;
        }

        // 4. Send OTP via gateway — returns a session token (Infobip pinId or mock code)
        let session_token = self.sms_gateway.send_otp(phone.as_str()).await?;

        // 5. Store session token keyed by phone
        self.otp_repo.store(phone.as_str(), &session_token).await?;

        Ok(())
    }
}
