use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserSession {
    pub phone: String,
    pub device_id: String,
    pub platform: String,
}
