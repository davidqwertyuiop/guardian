use super::dto::{NotificationListResponse, NotificationResponse};
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use axum::{
    extract::{Path, Query, State},
    Json,
};
use serde::Deserialize;
use sqlx::Row;
use uuid::Uuid;

#[derive(Debug, Deserialize)]
pub struct ListParams {
    #[serde(default = "default_limit")]
    pub limit: i64,
}

fn default_limit() -> i64 {
    50
}

pub async fn list_notifications(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Query(params): Query<ListParams>,
) -> Result<Json<NotificationListResponse>, AppError> {
    let user_id = parse_user_id(&claims.sub)?;
    let limit = params.limit.clamp(1, 100);
    let unread_count: i64 = sqlx::query_scalar(
        "SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = FALSE",
    )
    .bind(user_id)
    .fetch_one(&state.db_pool)
    .await
    .map_err(db_error)?;

    let rows = sqlx::query(
        r#"
        SELECT
            n.id,
            n.kind,
            n.title,
            n.body,
            n.is_read,
            n.created_at,
            n.data,
            u.name AS "actor_name?",
            u.avatar_url AS "actor_avatar_url?"
        FROM notifications n
        LEFT JOIN users u ON u.id = n.actor_user_id
        WHERE n.user_id = $1
        ORDER BY n.created_at DESC
        LIMIT $2
        "#,
    )
    .bind(user_id)
    .bind(limit)
    .fetch_all(&state.db_pool)
    .await
    .map_err(db_error)?;

    let items = rows
        .into_iter()
        .map(|row| NotificationResponse {
            id: row.get::<Uuid, _>("id").to_string(),
            kind: row.get("kind"),
            title: row.get("title"),
            body: row.get("body"),
            is_read: row.get("is_read"),
            created_at: row.get("created_at"),
            actor_name: row.get("actor_name"),
            actor_avatar_url: row.get("actor_avatar_url"),
            data: row.get("data"),
        })
        .collect();

    Ok(Json(NotificationListResponse {
        unread_count,
        items,
    }))
}

pub async fn mark_all_read(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id = parse_user_id(&claims.sub)?;
    sqlx::query(
        "UPDATE notifications
         SET is_read = TRUE, read_at = NOW()
         WHERE user_id = $1 AND is_read = FALSE",
    )
    .bind(user_id)
    .execute(&state.db_pool)
    .await
    .map_err(db_error)?;

    Ok(Json(serde_json::json!({ "success": true })))
}

pub async fn mark_read(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Path(id): Path<Uuid>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id = parse_user_id(&claims.sub)?;
    let result = sqlx::query(
        "UPDATE notifications
         SET is_read = TRUE, read_at = NOW()
         WHERE id = $1 AND user_id = $2",
    )
    .bind(id)
    .bind(user_id)
    .execute(&state.db_pool)
    .await
    .map_err(db_error)?;

    if result.rows_affected() == 0 {
        return Err(AppError::NotFound("Notification not found".into()));
    }

    Ok(Json(serde_json::json!({ "success": true })))
}

fn parse_user_id(value: &str) -> Result<Uuid, AppError> {
    value
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))
}

fn db_error(error: sqlx::Error) -> AppError {
    AppError::Internal(format!("Notifications database error: {error}"))
}
