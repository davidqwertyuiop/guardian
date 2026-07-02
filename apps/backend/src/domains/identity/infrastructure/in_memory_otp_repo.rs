use std::collections::HashMap;
use std::sync::Mutex;
use std::time::{SystemTime, UNIX_EPOCH};
use async_trait::async_trait;
use crate::shared::errors::AppError;
use crate::domains::identity::domain::{
    entities::otp_entry::OtpEntry,
    repositories::otp_repository::OtpRepository,
};

/// In-memory OTP store for development / MVP.
/// Swap out for a Redis implementation when scaling.
pub struct InMemoryOtpRepository {
    store: Mutex<HashMap<String, OtpEntry>>,
}

impl InMemoryOtpRepository {
    pub fn new() -> Self {
        Self { store: Mutex::new(HashMap::new()) }
    }
}

impl Default for InMemoryOtpRepository {
    fn default() -> Self { Self::new() }
}

#[async_trait]
impl OtpRepository for InMemoryOtpRepository {
    async fn store(&self, phone: &str, session_token: &str) -> Result<(), AppError> {
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs();

        let entry = OtpEntry {
            phone:           phone.to_string(),
            session_token:   session_token.to_string(),
            created_at_secs: now,
            attempts:        0,
        };

        self.store
            .lock()
            .map_err(|_| AppError::Internal("OTP store lock poisoned".to_string()))?
            .insert(phone.to_string(), entry);

        Ok(())
    }

    async fn get(&self, phone: &str) -> Result<Option<OtpEntry>, AppError> {
        let guard = self.store
            .lock()
            .map_err(|_| AppError::Internal("OTP store lock poisoned".to_string()))?;
        Ok(guard.get(phone).cloned())
    }

    async fn delete(&self, phone: &str) -> Result<(), AppError> {
        self.store
            .lock()
            .map_err(|_| AppError::Internal("OTP store lock poisoned".to_string()))?
            .remove(phone);
        Ok(())
    }
}
