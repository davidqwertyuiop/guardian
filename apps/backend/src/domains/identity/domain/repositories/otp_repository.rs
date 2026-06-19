use async_trait::async_trait;
use crate::shared::errors::AppError;
use super::super::entities::otp_entry::OtpEntry;

#[async_trait]
pub trait OtpRepository: Send + Sync {
    /// Store an OTP for a phone number (overwrites any existing one).
    async fn store(&self, phone: &str, code: &str) -> Result<(), AppError>;

    /// Retrieve the OTP entry for a phone number.
    async fn get(&self, phone: &str) -> Result<Option<OtpEntry>, AppError>;

    /// Delete the OTP after successful verification.
    async fn delete(&self, phone: &str) -> Result<(), AppError>;
}
