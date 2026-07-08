use crate::shared::errors::AppError;
use serde_json::Value;
use sqlx::PgPool;
use uuid::Uuid;

pub async fn create_notifications(
    pool: &PgPool,
    user_ids: &[Uuid],
    actor_user_id: Option<Uuid>,
    kind: &str,
    title: &str,
    body: &str,
    data: Value,
) -> Result<(), AppError> {
    for user_id in user_ids {
        sqlx::query(
            "INSERT INTO notifications
             (user_id, actor_user_id, kind, title, body, data)
             VALUES ($1, $2, $3, $4, $5, $6)",
        )
        .bind(user_id)
        .bind(actor_user_id)
        .bind(kind)
        .bind(title)
        .bind(body)
        .bind(data.clone())
        .execute(pool)
        .await
        .map_err(|e| AppError::Internal(format!("Create notification error: {e}")))?;
    }

    Ok(())
}
