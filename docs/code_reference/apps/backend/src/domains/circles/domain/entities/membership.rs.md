# membership.rs

* **File Path:** `apps/backend/src/domains/circles/domain/entities/membership.rs`
* **Type:** `RUST`

---

```rust
use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, Clone, sqlx::FromRow)]
pub struct Membership {
    pub id: Uuid,
    pub circle_id: Uuid,
    pub user_id: Uuid,
    pub role: String,
    pub joined_at: DateTime<Utc>,
}

/// A member with their public profile — returned in the members list.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct MemberWithProfile {
    pub user_id: Uuid,
    pub circle_id: Uuid,
    pub role: String,
    pub joined_at: DateTime<Utc>,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub phone: String,
}

```
