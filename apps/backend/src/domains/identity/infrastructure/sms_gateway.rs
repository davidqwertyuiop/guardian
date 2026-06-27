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

/// AWS SNS implementation for production SMS delivery.
pub struct AwsSmsGateway {
    client: aws_sdk_sns::Client,
}

impl AwsSmsGateway {
    pub fn new(client: aws_sdk_sns::Client) -> Self {
        Self { client }
    }
}

#[async_trait]
impl SmsGateway for AwsSmsGateway {
    async fn send(&self, phone: &str, code: &str) -> Result<(), AppError> {
        let message = format!("< {} > is your Guardian verification code.", code);
        
        // AWS SNS recommends setting the DataType to String and StringValue to Transactional for OTPs
        let message_attributes = aws_sdk_sns::types::MessageAttributeValue::builder()
            .data_type("String")
            .string_value("Transactional")
            .build()
            .map_err(|e| AppError::Internal(format!("Failed to build message attribute: {}", e)))?;

        self.client
            .publish()
            .phone_number(phone)
            .message(&message)
            .message_attributes("AWS.SNS.SMS.SMSType", message_attributes)
            .send()
            .await
            .map_err(|e| {
                tracing::error!("AWS SNS Error: {:?}", e);
                AppError::Internal(format!("Failed to send SMS via AWS: {}", e))
            })?;

        tracing::info!("📱 [AWS SMS] OTP sent to {}", phone);
        Ok(())
    }
}
