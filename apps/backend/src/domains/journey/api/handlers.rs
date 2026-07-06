use axum::{extract::State, Json};
use uuid::Uuid;
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use super::dto::*;
use crate::infrastructure::push_notifications::send_push_notification;

// ── POST /api/v1/journey/start ──────────────────────────────────────────────

pub async fn start_journey(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<StartJourneyRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // 1. Verify membership
    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized("You are not a member of this circle.".into()));
    }

    // 2. Fetch broadcaster user name
    let user = state.user_repo.find_by_id(user_id).await?
        .ok_or_else(|| AppError::NotFound("Broadcaster user not found".into()))?;
    let user_name = user.name.unwrap_or_else(|| "Someone".into());

    // 3. Fetch FCM tokens for other circle members
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

    // 4. Notify all circle members
    let title = format!("{} is live!", user_name);
    let body_text = format!("They are heading to {} (ETA: {}).", body.destination, body.duration);

    for token in &other_members_tokens {
        send_push_notification(token, &title, &body_text).await;
    }

    tracing::info!(
        "Journey started: {} is broadcasting live to circle {} (destination: {}, duration: {}). Dispatched push notifications to {} devices.",
        user_name,
        body.circle_id,
        body.destination,
        body.duration,
        other_members_tokens.len()
    );

    Ok(Json(serde_json::json!({
        "success": true,
        "message": "Broadcast started successfully"
    })))
}

// ── POST /api/v1/journey/stay ───────────────────────────────────────────────

pub async fn stay_journey(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<StayJourneyRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // 1. Verify membership
    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized("You are not a member of this circle.".into()));
    }

    // 2. Fetch user name
    let user = state.user_repo.find_by_id(user_id).await?
        .ok_or_else(|| AppError::NotFound("User not found".into()))?;
    let user_name = user.name.unwrap_or_else(|| "Someone".into());

    tracing::info!(
        "Stay broadcast: User {} ({}) confirmed staying in circle {}.",
        user_name,
        user_id,
        body.circle_id
    );

    Ok(Json(serde_json::json!({
        "success": true,
        "message": "Stay option saved successfully"
    })))
}

// ── POST /api/v1/journey/stop ───────────────────────────────────────────────

pub async fn stop_journey(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<StopJourneyRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // 1. Verify membership
    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized("You are not a member of this circle.".into()));
    }

    // 2. Fetch user name
    let user = state.user_repo.find_by_id(user_id).await?
        .ok_or_else(|| AppError::NotFound("User not found".into()))?;
    let user_name = user.name.unwrap_or_else(|| "Someone".into());

    // 3. Fetch FCM tokens for other circle members
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

    // 4. Notify other circle members
    let title = format!("{} stopped broadcasting", user_name);
    let body_text = format!("They have safely stopped their journey.");

    for token in &other_members_tokens {
        send_push_notification(token, &title, &body_text).await;
    }

    tracing::info!(
        "Journey stopped: User {} ({}) in circle {}.",
        user_name,
        user_id,
        body.circle_id
    );

    Ok(Json(serde_json::json!({
        "success": true,
        "message": "Broadcast stopped successfully"
    })))
}

