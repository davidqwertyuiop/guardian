use crate::shared::errors::AppError;
use reqwest::Client;
use serde_json::json;
use std::{sync::Arc, time::Duration};

const SEND_SMS_PATH: &str = "/sms/send";

/// Sends transactional SMS messages through the Sendchamp REST API.
#[derive(Clone)]
pub struct SendchampSmsService {
    client: Arc<Client>,
    base_url: String,
    api_key: String,
    sender: String,
    route: String,
}

impl SendchampSmsService {
    pub fn new(
        client: Arc<Client>,
        base_url: String,
        api_key: String,
        sender: String,
        route: String,
    ) -> Self {
        Self {
            client,
            base_url: base_url.trim_end_matches('/').to_string(),
            api_key,
            sender,
            route,
        }
    }

    /// Sends a 6-digit OTP to an international-format phone number.
    pub async fn send_otp(&self, phone: &str, code: &str) -> Result<(), AppError> {
        let recipient = normalize_phone(phone)?;
        let url = format!("{}{}", self.base_url, SEND_SMS_PATH);
        let body = json!({
            "to": [recipient],
            "message": format!(
                "Your Guardian verification code is: {}. It expires in 5 minutes.",
                code
            ),
            "sender_name": self.sender,
        });

        let response = self
            .client
            .post(url)
            .bearer_auth(&self.api_key)
            .header("Accept", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(15))
            .send()
            .await
            .map_err(|error| AppError::Internal(format!("Sendchamp request failed: {error}")))?;

        let status = response.status();
        if !status.is_success() {
            let provider_message = response.text().await.unwrap_or_default();
            return Err(AppError::Internal(format!(
                "Sendchamp returned {status}: {}",
                truncate(&provider_message, 500)
            )));
        }

        Ok(())
    }
}

fn normalize_phone(phone: &str) -> Result<String, AppError> {
    let normalized = phone.trim().trim_start_matches('+');
    if !(8..=15).contains(&normalized.len())
        || !normalized
            .chars()
            .all(|character| character.is_ascii_digit())
    {
        return Err(AppError::InvalidInput(
            "Phone number must use international format, for example +2349012345678".into(),
        ));
    }

    Ok(normalized.to_string())
}

fn truncate(value: &str, max_chars: usize) -> String {
    value.chars().take(max_chars).collect()
}

#[cfg(test)]
mod tests {
    use super::normalize_phone;

    #[test]
    fn normalizes_e164_phone_for_sendchamp() {
        assert_eq!(normalize_phone("+2349012345678").unwrap(), "2349012345678");
    }

    #[test]
    fn rejects_non_numeric_phone() {
        assert!(normalize_phone("+234-901-234-5678").is_err());
    }
}
