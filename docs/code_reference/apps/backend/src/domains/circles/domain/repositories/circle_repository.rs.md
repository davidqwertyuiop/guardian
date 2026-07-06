# circle_repository.rs

* **File Path:** `apps/backend/src/domains/circles/domain/repositories/circle_repository.rs`
* **Type:** `RUST`

---

```rust
use async_trait::async_trait;
use uuid::Uuid;
use crate::shared::errors::AppError;
use crate::domains::circles::domain::entities::{
    circle::Circle,
    membership::{Membership, MemberWithProfile},
};

#[async_trait]
pub trait CircleRepository: Send + Sync {
    async fn create(&self, name: &str, owner_id: Uuid) -> Result<Circle, AppError>;
    async fn find_by_id(&self, id: Uuid) -> Result<Option<Circle>, AppError>;
    async fn find_by_owner_and_name(&self, owner_id: Uuid, name: &str) -> Result<Option<Circle>, AppError>;
    async fn list_for_user(&self, user_id: Uuid) -> Result<Vec<Circle>, AppError>;

    async fn add_member(&self, circle_id: Uuid, user_id: Uuid, role: &str) -> Result<Membership, AppError>;
    async fn is_member(&self, circle_id: Uuid, user_id: Uuid) -> Result<bool, AppError>;
    async fn get_members(&self, circle_id: Uuid) -> Result<Vec<MemberWithProfile>, AppError>;
    async fn has_any_member_except_owner(&self, circle_id: Uuid, owner_id: Uuid) -> Result<bool, AppError>;
    async fn remove_member(&self, circle_id: Uuid, user_id: Uuid) -> Result<(), AppError>;
}

```
