use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Core user entity in the identity domain.
#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct User {
    pub id: Uuid,
    pub phone: String,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub is_profile_complete: bool,
    pub location_enabled: bool,
    pub notify_sos: bool,
    pub notify_broadcast: bool,
    pub notify_new_member: bool,
    pub location_paused_until: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
