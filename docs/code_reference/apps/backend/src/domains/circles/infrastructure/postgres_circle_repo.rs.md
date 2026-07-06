# postgres_circle_repo.rs

* **File Path:** `apps/backend/src/domains/circles/infrastructure/postgres_circle_repo.rs`
* **Type:** `RUST`

---

```rust
use async_trait::async_trait;
use sqlx::PgPool;
use uuid::Uuid;
use crate::shared::errors::AppError;
use crate::domains::circles::domain::{
    entities::{circle::Circle, membership::{Membership, MemberWithProfile}},
    repositories::circle_repository::CircleRepository,
};

pub struct PostgresCircleRepository {
    pub pool: PgPool,
}

#[async_trait]
impl CircleRepository for PostgresCircleRepository {
    async fn create(&self, name: &str, owner_id: Uuid) -> Result<Circle, AppError> {
        sqlx::query_as::<_, Circle>(
            "INSERT INTO circles (name, owner_id)
             VALUES ($1, $2)
             RETURNING id, name, owner_id, created_at, updated_at",
        )
        .bind(name)
        .bind(owner_id)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB create circle: {e}")))
    }

    async fn find_by_id(&self, id: Uuid) -> Result<Option<Circle>, AppError> {
        sqlx::query_as::<_, Circle>(
            "SELECT id, name, owner_id, created_at, updated_at FROM circles WHERE id = $1",
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB find circle: {e}")))
    }

    async fn find_by_owner_and_name(&self, owner_id: Uuid, name: &str) -> Result<Option<Circle>, AppError> {
        sqlx::query_as::<_, Circle>(
            "SELECT id, name, owner_id, created_at, updated_at 
             FROM circles 
             WHERE owner_id = $1 AND LOWER(name) = LOWER($2)",
        )
        .bind(owner_id)
        .bind(name)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB find circle by owner/name: {e}")))
    }

    async fn list_for_user(&self, user_id: Uuid) -> Result<Vec<Circle>, AppError> {
        sqlx::query_as::<_, Circle>(
            "SELECT c.id, c.name, c.owner_id, c.created_at, c.updated_at
             FROM circles c
             JOIN circle_memberships cm ON cm.circle_id = c.id
             WHERE cm.user_id = $1
             ORDER BY cm.joined_at DESC",
        )
        .bind(user_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB list circles: {e}")))
    }

    async fn add_member(&self, circle_id: Uuid, user_id: Uuid, role: &str) -> Result<Membership, AppError> {
        sqlx::query_as::<_, Membership>(
            "INSERT INTO circle_memberships (circle_id, user_id, role)
             VALUES ($1, $2, $3)
             ON CONFLICT (circle_id, user_id) DO UPDATE SET role = EXCLUDED.role
             RETURNING id, circle_id, user_id, role, joined_at",
        )
        .bind(circle_id)
        .bind(user_id)
        .bind(role)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB add member: {e}")))
    }

    async fn is_member(&self, circle_id: Uuid, user_id: Uuid) -> Result<bool, AppError> {
        let row: (bool,) = sqlx::query_as(
            "SELECT EXISTS(SELECT 1 FROM circle_memberships WHERE circle_id = $1 AND user_id = $2)",
        )
        .bind(circle_id)
        .bind(user_id)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB is_member: {e}")))?;
        Ok(row.0)
    }

    async fn get_members(&self, circle_id: Uuid) -> Result<Vec<MemberWithProfile>, AppError> {
        sqlx::query_as::<_, MemberWithProfile>(
            "SELECT cm.user_id, cm.circle_id, cm.role, cm.joined_at,
                    u.name, u.avatar_url, u.phone
             FROM circle_memberships cm
             JOIN users u ON u.id = cm.user_id
             WHERE cm.circle_id = $1
             ORDER BY cm.joined_at ASC",
        )
        .bind(circle_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB get_members: {e}")))
    }

    async fn has_any_member_except_owner(
        &self,
        circle_id: Uuid,
        owner_id: Uuid,
    ) -> Result<bool, AppError> {
        let row: (bool,) = sqlx::query_as(
            "SELECT EXISTS(
               SELECT 1 FROM circle_memberships
               WHERE circle_id = $1 AND user_id != $2
             )",
        )
        .bind(circle_id)
        .bind(owner_id)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB has_members: {e}")))?;
        Ok(row.0)
    }

    async fn remove_member(&self, circle_id: Uuid, user_id: Uuid) -> Result<(), AppError> {
        sqlx::query(
            "DELETE FROM circle_memberships
             WHERE circle_id = $1 AND user_id = $2"
        )
        .bind(circle_id)
        .bind(user_id)
        .execute(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB remove member: {e}")))?;
        Ok(())
    }
}

```
