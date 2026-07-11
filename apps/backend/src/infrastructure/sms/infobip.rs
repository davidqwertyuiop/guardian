use crate::shared::errors::AppError;
use reqwest::Client;
use serde_json::json;
use std::sync::Arc;

/// Sends SMS messages via the Infobip REST API.
#[derive(Clone)]
pub struct InfobipSmsService {
    pub client: Arc<Client>,
    /// e.g. "pd1jn3.api.infobip.com"
    pub base_url: String,
    /// Infobip API key
    pub api_key: String,
    /// Sender ID, e.g. "ServiceSMS" or your registered brand
    pub sender: String,
}

impl InfobipSmsService {
    pub fn new(base_url: String, api_key: String, sender: String) -> Self {
        Self {
            client: Arc::new(Client::new()),
            base_url,
            api_key,
            sender,
        }
    }

    /// Sends a 6-digit OTP code to the given E.164 phone number.
    pub async fn send_otp(&self, phone: &str, code: &str) -> Result<(), AppError> {
        let url = format!("https://{}/sms/3/messages", self.base_url);

        let body = json!({
            "messages": [{
                "destinations": [{"to": phone}],
                "sender": self.sender,
                "content": {
                    "text": format!(
                        "Your Guardian verification code is: {}. It expires in 5 minutes.",
                        code
                    )
                }
            }]
        });

        let resp = self
            .client
            .post(&url)
            .header("Authorization", format!("App {}", self.api_key))
            .header("Content-Type", "application/json")
            .header("Accept", "application/json")
            .json(&body)
            .send()
            .await
            .map_err(|e| AppError::Internal(format!("Infobip request failed: {e}")))?;

        let status = resp.status();
        if !status.is_success() {
            let text = resp.text().await.unwrap_or_default();
            return Err(AppError::Internal(format!(
                "Infobip returned {status}: {text}"
            )));
        }

        Ok(())
    }
}
