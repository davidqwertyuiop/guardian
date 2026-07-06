use crate::domains::circles::domain::{
    entities::invite_token::InviteToken, repositories::invite_repository::InviteRepository,
};
use crate::shared::errors::AppError;
use async_trait::async_trait;
use chrono::Utc;
use sqlx::PgPool;
use uuid::Uuid;

pub struct PostgresInviteRepository {
    pub pool: PgPool,
}

#[async_trait]
impl InviteRepository for PostgresInviteRepository {
    async fn create(
        &self,
        circle_id: Uuid,
        created_by: Uuid,
        code: &str,
        token: &str,
    ) -> Result<InviteToken, AppError> {
        let now = Utc::now();
        let code_expires = now + chrono::Duration::days(3);
        let link_expires = now + chrono::Duration::days(60);

        sqlx::query_as::<_, InviteToken>(
            "INSERT INTO invite_tokens
               (circle_id, created_by, code, token, code_expires_at, link_expires_at)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id, circle_id, code, token, created_by,
                       code_expires_at, link_expires_at,
                       used_count, max_uses, created_at",
        )
        .bind(circle_id)
        .bind(created_by)
        .bind(code)
        .bind(token)
        .bind(code_expires)
        .bind(link_expires)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB create invite: {e}")))
    }

    async fn find_by_code(&self, code: &str) -> Result<Option<InviteToken>, AppError> {
        sqlx::query_as::<_, InviteToken>(
            "SELECT id, circle_id, code, token, created_by,
                    code_expires_at, link_expires_at,
                    used_count, max_uses, created_at
             FROM invite_tokens
             WHERE code = $1 AND code_expires_at > NOW()",
        )
        .bind(code)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB find_by_code: {e}")))
    }

    async fn find_by_token(&self, token: &str) -> Result<Option<InviteToken>, AppError> {
        sqlx::query_as::<_, InviteToken>(
            "SELECT id, circle_id, code, token, created_by,
                    code_expires_at, link_expires_at,
                    used_count, max_uses, created_at
             FROM invite_tokens
             WHERE token = $1",
        )
        .bind(token)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB find_by_token: {e}")))
    }

    async fn increment_used(&self, id: Uuid) -> Result<(), AppError> {
        sqlx::query("UPDATE invite_tokens SET used_count = used_count + 1 WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await
            .map_err(|e| AppError::Internal(format!("DB increment_used: {e}")))?;
        Ok(())
    }

    async fn circle_has_members(&self, circle_id: Uuid, owner_id: Uuid) -> Result<bool, AppError> {
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
        .map_err(|e| AppError::Internal(format!("DB circle_has_members: {e}")))?;
        Ok(row.0)
    }
}
