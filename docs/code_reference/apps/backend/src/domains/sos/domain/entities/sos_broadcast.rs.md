# sos_broadcast.rs

* **File Path:** `apps/backend/src/domains/sos/domain/entities/sos_broadcast.rs`
* **Type:** `RUST`

---

```rust
use chrono::{DateTime, Utc};
use uuid::Uuid;

/// A distress broadcast triggered by a circle member.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct SosBroadcast {
    pub id: Uuid,
    pub user_id: Uuid,
    pub circle_id: Uuid,
    pub latitude: Option<f64>,
    pub longitude: Option<f64>,
    pub address: Option<String>,
    pub status: String,
    pub resolved_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
}

/// SOS broadcast enriched with the triggering member's public profile.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct SosBroadcastWithProfile {
    pub id: Uuid,
    pub user_id: Uuid,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub latitude: Option<f64>,
    pub longitude: Option<f64>,
    pub address: Option<String>,
    pub status: String,
    pub created_at: DateTime<Utc>,
}

/// Lifecycle state of an SOS broadcast.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SosStatus {
    Active,
    Resolved,
    Dismissed,
}

impl SosStatus {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Active    => "active",
            Self::Resolved  => "resolved",
            Self::Dismissed => "dismissed",
        }
    }
}

```
