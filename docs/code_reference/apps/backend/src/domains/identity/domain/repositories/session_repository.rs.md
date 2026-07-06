# session_repository.rs

* **File Path:** `apps/backend/src/domains/identity/domain/repositories/session_repository.rs`
* **Type:** `RUST`

---

```rust
use async_trait::async_trait;
use uuid::Uuid;
use crate::shared::errors::AppError;
use crate::domains::identity::domain::entities::user_session::UserSession;

#[async_trait]
pub trait SessionRepository: Send + Sync {
    async fn create(&self, session: &UserSession) -> Result<(), AppError>;
    async fn find_by_token_hash(&self, hash: &str) -> Result<Option<UserSession>, AppError>;
    async fn list_for_user(&self, user_id: Uuid) -> Result<Vec<UserSession>, AppError>;
    async fn update_last_active(&self, hash: &str) -> Result<(), AppError>;
    async fn delete_by_token_hash(&self, hash: &str) -> Result<(), AppError>;
    async fn delete_all_for_user(&self, user_id: Uuid) -> Result<(), AppError>;
}

```
