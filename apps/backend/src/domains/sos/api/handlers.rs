use axum::{
    extract::{Path, Query, State},
    Json,
};
use serde::Deserialize;
use uuid::Uuid;
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use super::dto::{SosActionResponse, SosBroadcastResponse, TriggerSosRequest};

// ── Query params ─────────────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct PaginationParams {
    #[serde(default = "default_limit")]
    pub limit: i64,
    #[serde(default)]
    pub offset: i64,
}

fn default_limit() -> i64 { 20 }

// ── POST /api/v1/sos ─────────────────────────────────────────────────────────
//
// Authenticated user triggers an SOS broadcast for a circle.
// Caller must be a member of the circle.

pub async fn trigger_sos(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<TriggerSosRequest>,
) -> Result<Json<SosActionResponse>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    let user = state.user_repo.find_by_id(user_id).await?
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
    let other_members_tokens: Vec<String> = sqlx::query_scalar(
        "SELECT dt.fcm_token 
         FROM device_tokens dt
         JOIN circle_memberships cm ON cm.user_id = dt.user_id
         WHERE cm.circle_id = $1 AND cm.user_id != $2"
    )
    .bind(body.circle_id)
    .bind(user_id)
    .fetch_all(&state.db_pool)
    .await
    .map_err(|e| AppError::Internal(format!("DB fetch FCM tokens: {e}")))?;

    let title = format!("EMERGENCY: {} triggered SOS!", user_name);
    let body_text = format!(
        "Address: {}. Tap to open live tracking.",
        body.address.as_deref().unwrap_or("Unknown location")
    );

    for token in &other_members_tokens {
        crate::infrastructure::push_notifications::send_push_notification(token, &title, &body_text).await;
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
    let user_id: Uuid = claims.sub.parse()
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
    let user_id: Uuid = claims.sub.parse()
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
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let broadcast = state.sos_repo.dismiss(id, user_id).await?;

    Ok(Json(SosActionResponse {
        id: broadcast.id.to_string(),
        status: broadcast.status,
    }))
}
