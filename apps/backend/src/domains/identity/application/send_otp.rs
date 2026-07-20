use crate::infrastructure::cache::otp_store::OtpStore;
use crate::infrastructure::sms::sendchamp::SendchampSmsService;
use crate::shared::errors::AppError;
use std::sync::Arc;

pub struct SendOtpUseCase {
    pub otp_store: Arc<OtpStore>,
    pub sms_service: Arc<SendchampSmsService>,
}

impl SendOtpUseCase {
    pub async fn execute(&self, phone: &str) -> Result<(), AppError> {
        if phone.is_empty() {
            return Err(AppError::InvalidInput(
                "Phone number cannot be empty".into(),
            ));
        }

        let code = self.otp_store.generate(phone).await;
        self.sms_service.send_otp(phone, &code).await?;
        Ok(())
    }
}
