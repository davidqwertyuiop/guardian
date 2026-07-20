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
    /// It first tries to send using the custom sender name on the DND route.
    /// If that fails, it falls back to the default route without specifying the route.
    pub async fn send_otp(&self, phone: &str, code: &str) -> Result<(), AppError> {
        let recipient = normalize_phone(phone)?;
        let url = format!("{}{}", self.base_url, SEND_SMS_PATH);
        
        // Try stage 1: Approved custom Sender ID on DND route
        let body_primary = json!({
            "to": [recipient.clone()],
            "message": format!(
                "Your Guardian verification code is: {}. It expires in 5 minutes.",
                code
            ),
            "sender_name": self.sender,
            "route": self.route,
        });

        let response = self
            .client
            .post(&url)
            .bearer_auth(&self.api_key)
            .header("Accept", "application/json")
            .json(&body_primary)
            .timeout(Duration::from_secs(10))
            .send()
            .await;

        let success = match response {
            Ok(res) => res.status().is_success(),
            Err(_) => false,
        };

        if success {
            return Ok(());
        }

        // Try stage 2 (Fallback): Default route (omitted route parameter)
        let body_fallback = json!({
            "to": [recipient],
            "message": format!(
                "Your Guardian verification code is: {}. It expires in 5 minutes.",
                code
            ),
            "sender_name": "Sendchamp", 
        });

        let response_fallback = self
            .client
            .post(&url)
            .bearer_auth(&self.api_key)
            .header("Accept", "application/json")
            .json(&body_fallback)
            .timeout(Duration::from_secs(10))
            .send()
            .await
            .map_err(|error| AppError::Internal(format!("Sendchamp fallback request failed: {error}")))?;

        let status = response_fallback.status();
        if !status.is_success() {
            let provider_message = response_fallback.text().await.unwrap_or_default();
            return Err(AppError::Internal(format!(
                "Sendchamp fallback returned {status}: {}",
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
