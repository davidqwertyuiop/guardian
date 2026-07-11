use super::dto::{SosActionResponse, SosBroadcastResponse, TriggerSosRequest};
use crate::domains::notifications::service::create_notifications;
use crate::infrastructure::push_notifications::send_push_notification;
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use axum::{
    extract::{Path, Query, State},
    Json,
};
use serde::Deserialize;
use sqlx::Row;
use uuid::Uuid;

// ── Query params ─────────────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct PaginationParams {
    #[serde(default = "default_limit")]
    pub limit: i64,
    #[serde(default)]
    pub offset: i64,
}

fn default_limit() -> i64 {
    20
}

// ── POST /api/v1/sos ─────────────────────────────────────────────────────────
//
// Authenticated user triggers an SOS broadcast for a circle.
// Caller must be a member of the circle.

pub async fn trigger_sos(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<TriggerSosRequest>,
) -> Result<Json<SosActionResponse>, AppError> {
    let user_id: Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    let user = state
        .user_repo
        .find_by_id(user_id)
        .await?
        .ok_or_else(|| AppError::NotFound("Triggering user not found".into()))?;
    let user_name = user.name.unwrap_or_else(|| "Someone".into());

    let broadcast = state
        .sos_repo
        .create(
            user_id,
            body.circle_id,
            body.latitude,
            body.longitude,
            body.address.clone(),
        )
        .await?;

    // Fetch FCM tokens of other members in this circle to notify them
    let recipients = sqlx::query(
        "SELECT cm.user_id, dt.fcm_token, u.name as user_name
         FROM circle_memberships cm
         LEFT JOIN device_tokens dt ON dt.user_id = cm.user_id
         LEFT JOIN users u ON u.id = cm.user_id
         WHERE cm.circle_id = $1 AND cm.user_id != $2",
    )
    .bind(body.circle_id)
    .bind(user_id)
    .fetch_all(&state.db_pool)
    .await
    .map_err(|e| AppError::Internal(format!("DB fetch recipients: {e}")))?;
    let recipient_ids: Vec<Uuid> = recipients.iter().map(|row| row.get("user_id")).collect();
    let other_members_tokens: Vec<String> = recipients
        .iter()
        .filter_map(|row| row.try_get("fcm_token").ok())
        .collect();
    let title = format!("EMERGENCY: {} triggered SOS!", user_name);
    let body_text = format!(
        "⚠️ SOS — {} needs help\n{} · just now",
        user_name,
        body.address.as_deref().unwrap_or("Unknown location")
    );

    let data = serde_json::json!({
        "circle_id": body.circle_id,
        "broadcast_id": broadcast.id,
        "route": "sos",
        "address": body.address
    });
    create_notifications(
        &state.db_pool,
        &recipient_ids,
        Some(user_id),
        "sos_active",
        &title,
        &body_text,
        data,
    )
    .await?;

    for row in &recipients {
        if let Ok(token) = row.try_get::<String, _>("fcm_token") {
            let recipient_name = row.try_get::<Option<String>, _>("user_name")
                .unwrap_or(None)
                .unwrap_or_else(|| "Guardian User".into());
            let personalized_title = format!("Hi {}!", recipient_name);
            let extra_data = serde_json::json!({
                "type": "sos",
                "circle_id": body.circle_id,
                "broadcast_id": broadcast.id,
                "route": "sos",
                "phone": user.phone,
                "name": user_name,
                "address": body.address.as_deref().unwrap_or("Unknown location")
            });
            crate::infrastructure::push_notifications::send_push_notification(
                &token, &personalized_title, &body_text, Some(extra_data)
            )
            .await;
        }
    }

    tracing::info!(
        "SOS triggered by user {} for circle {}. Push notifications dispatched to {} devices.",
        user_id,
        body.circle_id,
        other_members_tokens.len()
    );

    Ok(Json(SosActionResponse {
        id: broadcast.id.to_string(),
        status: broadcast.status,
    }))
}

// ── GET /api/v1/sos/circles/:id ─────────────────────────────────────────────
//
// List all SOS broadcasts for a circle, newest first, paginated.
// Enriched with triggering member's name + avatar for the UI.

pub async fn list_sos_broadcasts(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Path(circle_id): Path<Uuid>,
    Query(params): Query<PaginationParams>,
) -> Result<Json<Vec<SosBroadcastResponse>>, AppError> {
    let user_id: Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    if !state.circle_repo.is_member(circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    let limit = params.limit.clamp(1, 100);
    let broadcasts = state
        .sos_repo
        .list_for_circle(circle_id, limit, params.offset)
        .await?;

    let resp = broadcasts
        .into_iter()
        .map(|b| SosBroadcastResponse {
            id: b.id.to_string(),
            user_id: b.user_id.to_string(),
            name: b.name,
            avatar_url: b.avatar_url,
            latitude: b.latitude,
            longitude: b.longitude,
            address: b.address,
            status: b.status,
            created_at: b.created_at,
        })
        .collect();

    Ok(Json(resp))
}

// ── POST /api/v1/sos/:id/resolve ─────────────────────────────────────────────
//
// Any circle member may mark an active broadcast as resolved.

pub async fn resolve_sos(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Path(id): Path<Uuid>,
) -> Result<Json<SosActionResponse>, AppError> {
    let user_id: Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let broadcast = state.sos_repo.resolve(id, user_id).await?;

    Ok(Json(SosActionResponse {
        id: broadcast.id.to_string(),
        status: broadcast.status,
    }))
}

// ── POST /api/v1/sos/:id/dismiss ─────────────────────────────────────────────
//
// Only the broadcast owner may dismiss their own active SOS.

pub async fn dismiss_sos(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Path(id): Path<Uuid>,
) -> Result<Json<SosActionResponse>, AppError> {
    let user_id: Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let broadcast = state.sos_repo.dismiss(id, user_id).await?;

    let user = state
        .user_repo
        .find_by_id(user_id)
        .await?
        .ok_or_else(|| AppError::NotFound("Triggering user not found".into()))?;
    let user_name = user.name.unwrap_or_else(|| "Someone".into());

    let recipients = sqlx::query(
        "SELECT cm.user_id, dt.fcm_token, u.name as user_name
         FROM circle_memberships cm
         LEFT JOIN device_tokens dt ON dt.user_id = cm.user_id
         LEFT JOIN users u ON u.id = cm.user_id
         WHERE cm.circle_id = $1 AND cm.user_id != $2",
    )
    .bind(broadcast.circle_id)
    .bind(user_id)
    .fetch_all(&state.db_pool)
    .await
    .map_err(|e| AppError::Internal(format!("DB fetch recipients: {e}")))?;
    let recipient_ids: Vec<Uuid> = recipients.iter().map(|row| row.get("user_id")).collect();

    let title = format!("{} is safe", user_name);
    let body_text = "Their SOS has been cancelled. They marked themselves safe.";
    let data = serde_json::json!({
        "circle_id": broadcast.circle_id,
        "broadcast_id": broadcast.id,
        "route": "sos",
        "status": "dismissed"
    });
    create_notifications(
        &state.db_pool,
        &recipient_ids,
        Some(user_id),
        "sos_cancelled",
        &title,
        body_text,
        data,
    )
    .await?;

    for row in &recipients {
        if let Ok(token) = row.try_get::<String, _>("fcm_token") {
            let recipient_name = row.try_get::<Option<String>, _>("user_name")
                .unwrap_or(None)
                .unwrap_or_else(|| "Guardian User".into());
            let personalized_title = format!("Hi {}!", recipient_name);
            let extra_data = serde_json::json!({
                "type": "sos_dismissed",
                "circle_id": broadcast.circle_id,
                "broadcast_id": broadcast.id,
                "route": "sos",
                "status": "dismissed",
                "name": user_name
            });
            send_push_notification(&token, &personalized_title, body_text, Some(extra_data)).await;
        }
    }

    tracing::info!(
        "SOS dismissed by user {} for circle {}. Safety notifications dispatched to {} devices.",
        user_id,
        broadcast.circle_id,
        recipients.len()
    );

    Ok(Json(SosActionResponse {
        id: broadcast.id.to_string(),
        status: broadcast.status,
    }))
}
