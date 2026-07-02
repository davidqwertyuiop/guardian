use async_trait::async_trait;
use crate::shared::errors::AppError;

/// SMS/OTP gateway trait.
/// `send_otp`   → sends the code, returns an opaque session token.
/// `verify_otp` → verifies the code using that session token.
///
/// Swap implementations at any time — the rest of the app is unaffected.
#[async_trait]
pub trait SmsGateway: Send + Sync {
    /// Send an OTP to `phone`. Returns a session token (e.g. Infobip pinId)
    /// that must be stored and passed back to `verify_otp`.
    async fn send_otp(&self, phone: &str) -> Result<String, AppError>;

    /// Verify `code` using the `session_token` returned by `send_otp`.
    async fn verify_otp(&self, session_token: &str, code: &str) -> Result<(), AppError>;
}

// ─── Mock (local dev) ─────────────────────────────────────────────────────────

/// Development mock: logs OTP to server console instead of sending a real SMS.
/// The session token IS the code, so verification is a simple equality check.
pub struct MockSmsGateway;

#[async_trait]
impl SmsGateway for MockSmsGateway {
    async fn send_otp(&self, phone: &str) -> Result<String, AppError> {
        let code = format!("{:06}", rand::random::<u32>() % 1_000_000);
        tracing::info!("📱 [MOCK SMS] Guardian OTP for {}: {}", phone, code);
        // Return the code itself as the session token
        Ok(code)
    }

    async fn verify_otp(&self, session_token: &str, code: &str) -> Result<(), AppError> {
        if session_token == code {
            Ok(())
        } else {
            Err(AppError::Unauthorized("Invalid verification code.".to_string()))
        }
    }
}

// ─── Infobip 2FA ──────────────────────────────────────────────────────────────

/// Infobip 2FA gateway — production OTP via Infobip's managed 2FA service.
///
/// Required env vars:
///   INFOBIP_API_KEY        — your API key from the Infobip dashboard
///   INFOBIP_BASE_URL       — e.g. "554ppj.api.infobip.com"
///   INFOBIP_APPLICATION_ID — the 2FA application ID
///   INFOBIP_MESSAGE_ID     — the 2FA message template ID
///   INFOBIP_SENDER         — sender number/ID e.g. "447491163443"
pub struct InfobipSmsGateway {
    client:         reqwest::Client,
    api_key:        String,
    base_url:       String,
    application_id: String,
    message_id:     String,
    sender:         String,
}

impl InfobipSmsGateway {
    pub fn new(
        api_key:        String,
        base_url:       String,
        application_id: String,
        message_id:     String,
        sender:         String,
    ) -> Self {
        Self {
            client: reqwest::Client::new(),
            api_key,
            base_url,
            application_id,
            message_id,
            sender,
        }
    }
}

#[async_trait]
impl SmsGateway for InfobipSmsGateway {
    /// Calls POST /2fa/2/pin → Infobip sends the SMS and returns a pinId.
    async fn send_otp(&self, phone: &str) -> Result<String, AppError> {
        let url = format!("https://{}/2fa/2/pin", self.base_url);

        let body = serde_json::json!({
            "applicationId": self.application_id,
            "messageId":     self.message_id,
            "from":          self.sender,
            "to":            phone
        });

        let resp = self.client
            .post(&url)
            .header("Authorization", format!("App {}", self.api_key))
            .header("Content-Type", "application/json")
            .header("Accept", "application/json")
            .json(&body)
            .send()
            .await
            .map_err(|e| AppError::Internal(format!("Infobip send error: {}", e)))?;

        let status = resp.status();
        let json: serde_json::Value = resp
            .json()
            .await
            .map_err(|e| AppError::Internal(format!("Infobip response parse error: {}", e)))?;

        if !status.is_success() {
            let msg = json["requestError"]["serviceException"]["text"]
                .as_str()
                .unwrap_or("Unknown Infobip error");
            tracing::error!("❌ [Infobip] Send failed to {} — {}: {}", phone, status, msg);
            return Err(AppError::Internal(format!("Failed to send OTP: {}", msg)));
        }

        let pin_id = json["pinId"]
            .as_str()
            .ok_or_else(|| AppError::Internal("Infobip response missing pinId".to_string()))?
            .to_string();

        tracing::info!("📱 [Infobip] OTP sent to {} (pinId: {})", phone, pin_id);
        Ok(pin_id)
    }

    /// Calls POST /2fa/2/pin/{pinId}/verify → Infobip checks the code.
    async fn verify_otp(&self, pin_id: &str, code: &str) -> Result<(), AppError> {
        let url = format!("https://{}/2fa/2/pin/{}/verify", self.base_url, pin_id);

        let body = serde_json::json!({ "pin": code });

        let resp = self.client
            .post(&url)
            .header("Authorization", format!("App {}", self.api_key))
            .header("Content-Type", "application/json")
            .header("Accept", "application/json")
            .json(&body)
            .send()
            .await
            .map_err(|e| AppError::Internal(format!("Infobip verify error: {}", e)))?;

        let status = resp.status();
        let json: serde_json::Value = resp
            .json()
            .await
            .map_err(|e| AppError::Internal(format!("Infobip verify parse error: {}", e)))?;

        if !status.is_success() {
            let msg = json["requestError"]["serviceException"]["text"]
                .as_str()
                .unwrap_or("Invalid verification code.");
            tracing::warn!("⚠️ [Infobip] Verify failed — {}", msg);
            return Err(AppError::Unauthorized("Invalid verification code.".to_string()));
        }

        let verified = json["verified"].as_bool().unwrap_or(false);
        if !verified {
            return Err(AppError::Unauthorized("Invalid verification code.".to_string()));
        }

        tracing::info!("✅ [Infobip] PIN verified (pinId: {})", pin_id);
        Ok(())
    }
}
