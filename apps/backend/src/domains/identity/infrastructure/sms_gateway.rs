use async_trait::async_trait;
use crate::shared::errors::AppError;

/// SMS gateway trait — swap MockSmsGateway for TwilioSmsGateway at any time.
#[async_trait]
pub trait SmsGateway: Send + Sync {
    async fn send(&self, phone: &str, code: &str) -> Result<(), AppError>;
}

/// Development mock — logs the OTP to console (and returns it via the debug endpoint).
pub struct MockSmsGateway;

#[async_trait]
impl SmsGateway for MockSmsGateway {
    async fn send(&self, phone: &str, code: &str) -> Result<(), AppError> {
        tracing::info!(
            "📱 [MOCK SMS] Guardian OTP for {}: {}  (bypass: 8823)",
            phone, code
        );
        Ok(())
    }
}
