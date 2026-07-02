use async_trait::async_trait;
use crate::shared::errors::AppError;
use super::super::entities::otp_entry::OtpEntry;

#[async_trait]
pub trait OtpRepository: Send + Sync {
    /// Store an OTP session for a phone number (overwrites any existing one).
    /// `session_token` is the Infobip pinId (or raw code for MockSmsGateway).
    async fn store(&self, phone: &str, session_token: &str) -> Result<(), AppError>;

    /// Retrieve the OTP entry for a phone number.
    async fn get(&self, phone: &str) -> Result<Option<OtpEntry>, AppError>;

    /// Delete the OTP after successful verification.
    async fn delete(&self, phone: &str) -> Result<(), AppError>;
}
