# invite_token.rs

* **File Path:** `apps/backend/src/domains/circles/domain/entities/invite_token.rs`
* **Type:** `RUST`

---

```rust
use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, Clone, sqlx::FromRow)]
pub struct InviteToken {
    pub id: Uuid,
    pub circle_id: Uuid,
    pub code: String,
    pub token: String,
    pub created_by: Uuid,
    pub code_expires_at: DateTime<Utc>,
    pub link_expires_at: DateTime<Utc>,
    pub used_count: i32,
    pub max_uses: Option<i32>,
    pub created_at: DateTime<Utc>,
}

```
