use serde::{Deserialize, Serialize};
use uuid::Uuid;
use chrono::{DateTime, Utc};

/// Core user entity in the identity domain.
#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct User {
    pub id: Uuid,
    pub phone: String,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub is_profile_complete: bool,
    pub location_enabled: bool,
    pub notifications_enabled: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
