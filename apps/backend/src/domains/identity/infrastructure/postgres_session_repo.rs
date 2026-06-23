use async_trait::async_trait;
use sqlx::PgPool;
use uuid::Uuid;
use crate::shared::errors::AppError;
use crate::domains::identity::domain::{
    entities::user_session::UserSession,
    repositories::session_repository::SessionRepository,
};

pub struct PostgresSessionRepository {
    pub pool: PgPool,
}

#[async_trait]
impl SessionRepository for PostgresSessionRepository {
    async fn create(&self, session: &UserSession) -> Result<(), AppError> {
        sqlx::query(
            "INSERT INTO user_sessions (id, user_id, device_name, device_model, platform, refresh_token_hash, expires_at, last_active_at, created_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)"
        )
        .bind(session.id)
        .bind(session.user_id)
        .bind(&session.device_name)
        .bind(&session.device_model)
        .bind(&session.platform)
        .bind(&session.refresh_token_hash)
        .bind(session.expires_at)
        .bind(session.last_active_at)
        .bind(session.created_at)
        .execute(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB insert session error: {e}")))?;
        Ok(())
    }

    async fn find_by_token_hash(&self, hash: &str) -> Result<Option<UserSession>, AppError> {
        sqlx::query_as::<_, UserSession>(
            "SELECT id, user_id, device_name, device_model, platform, refresh_token_hash, expires_at, last_active_at, created_at
             FROM user_sessions WHERE refresh_token_hash = $1"
        )
        .bind(hash)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB select session error: {e}")))
    }

    async fn list_for_user(&self, user_id: Uuid) -> Result<Vec<UserSession>, AppError> {
        sqlx::query_as::<_, UserSession>(
            "SELECT id, user_id, device_name, device_model, platform, refresh_token_hash, expires_at, last_active_at, created_at
             FROM user_sessions WHERE user_id = $1 ORDER BY last_active_at DESC"
        )
        .bind(user_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB list sessions error: {e}")))
    }

    async fn update_last_active(&self, hash: &str) -> Result<(), AppError> {
        sqlx::query(
            "UPDATE user_sessions SET last_active_at = NOW() WHERE refresh_token_hash = $1"
        )
        .bind(hash)
        .execute(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB update session error: {e}")))?;
        Ok(())
    }

    async fn delete_by_token_hash(&self, hash: &str) -> Result<(), AppError> {
        sqlx::query("DELETE FROM user_sessions WHERE refresh_token_hash = $1")
            .bind(hash)
            .execute(&self.pool)
            .await
            .map_err(|e| AppError::Internal(format!("DB delete session error: {e}")))?;
        Ok(())
    }

    async fn delete_all_for_user(&self, user_id: Uuid) -> Result<(), AppError> {
        sqlx::query("DELETE FROM user_sessions WHERE user_id = $1")
            .bind(user_id)
            .execute(&self.pool)
            .await
            .map_err(|e| AppError::Internal(format!("DB delete all user sessions error: {e}")))?;
        Ok(())
    }
}
