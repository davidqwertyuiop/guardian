# circle.rs

* **File Path:** `apps/backend/src/domains/circles/domain/entities/circle.rs`
* **Type:** `RUST`

---

```rust
use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, Clone, sqlx::FromRow)]
pub struct Circle {
    pub id: Uuid,
    pub name: String,
    pub owner_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

```
