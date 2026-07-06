# user_session.rs

* **File Path:** `apps/backend/src/domains/identity/domain/entities/user_session.rs`
* **Type:** `RUST`

---

```rust
use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, Clone, sqlx::FromRow)]
pub struct UserSession {
    pub id: Uuid,
    pub user_id: Uuid,
    pub device_name: String,
    pub device_model: Option<String>,
    pub platform: String,
    pub refresh_token_hash: String,
    pub expires_at: DateTime<Utc>,
    pub last_active_at: DateTime<Utc>,
    pub created_at: DateTime<Utc>,
}

```
