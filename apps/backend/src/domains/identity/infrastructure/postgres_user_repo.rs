use crate::domains::identity::domain::{
    entities::user::User, repositories::user_repository::UserRepository,
};
use crate::shared::errors::AppError;
use async_trait::async_trait;
use sqlx::PgPool;
use uuid::Uuid;

pub struct PostgresUserRepository {
    pub pool: PgPool,
}

#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>, AppError> {
        sqlx::query_as::<_, User>(
            "SELECT id, phone, name, avatar_url, is_profile_complete, location_enabled, notifications_enabled, created_at, updated_at
             FROM users WHERE phone = $1"
        )
        .bind(phone)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB error (find_by_phone): {}", e)))
    }

    async fn find_by_id(&self, id: Uuid) -> Result<Option<User>, AppError> {
        sqlx::query_as::<_, User>(
            "SELECT id, phone, name, avatar_url, is_profile_complete, location_enabled, notifications_enabled, created_at, updated_at
             FROM users WHERE id = $1"
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB error (find_by_id): {}", e)))
    }

    async fn create(&self, phone: &str) -> Result<User, AppError> {
        sqlx::query_as::<_, User>(
            "INSERT INTO users (phone)
             VALUES ($1)
             RETURNING id, phone, name, avatar_url, is_profile_complete, location_enabled, notifications_enabled, created_at, updated_at"
        )
        .bind(phone)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB error (create user): {}", e)))
    }

    async fn update_profile(&self, id: Uuid, name: &str) -> Result<User, AppError> {
        sqlx::query_as::<_, User>(
            "UPDATE users
             SET name = $1, is_profile_complete = TRUE
             WHERE id = $2
             RETURNING id, phone, name, avatar_url, is_profile_complete, location_enabled, notifications_enabled, created_at, updated_at"
        )
        .bind(name)
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB error (update_profile): {}", e)))?
        .ok_or_else(|| AppError::NotFound("User not found".to_string()))
    }

    async fn update_preferences(
        &self,
        id: Uuid,
        location_enabled: bool,
        notifications_enabled: bool,
    ) -> Result<User, AppError> {
        sqlx::query_as::<_, User>(
            "UPDATE users
             SET location_enabled = $1, notifications_enabled = $2
             WHERE id = $3
             RETURNING id, phone, name, avatar_url, is_profile_complete, location_enabled, notifications_enabled, created_at, updated_at"
        )
        .bind(location_enabled)
        .bind(notifications_enabled)
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB error (update_preferences): {}", e)))?
        .ok_or_else(|| AppError::NotFound("User not found".to_string()))
    }
}
