use super::dto::*;
use crate::domains::notifications::service::create_notifications;
use crate::infrastructure::push_notifications::send_push_notification;
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use axum::{extract::State, Json};
use sqlx::Row;
use uuid::Uuid;

// ── POST /api/v1/journey/start ──────────────────────────────────────────────

pub async fn start_journey(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<StartJourneyRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id: Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // 1. Verify membership
    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    // 2. Fetch broadcaster user name
    let user = state
        .user_repo
        .find_by_id(user_id)
        .await?
        .ok_or_else(|| AppError::NotFound("Broadcaster user not found".into()))?;
    let user_name = user.name.unwrap_or_else(|| "Someone".into());

    // 3. Fetch FCM tokens for other circle members
    let title = format!("{} is live!", user_name);
    let body_text = format!(
        "They are heading to {} (ETA: {}).",
        body.destination, body.duration
    );
    let recipients = sqlx::query(
        "SELECT cm.user_id, dt.fcm_token
         FROM circle_memberships cm
         LEFT JOIN device_tokens dt ON dt.user_id = cm.user_id
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
    create_notifications(
        &state.db_pool,
        &recipient_ids,
        Some(user_id),
        "journey_started",
        &title,
        &body_text,
        serde_json::json!({
            "circle_id": body.circle_id,
            "route": "journey",
            "destination": body.destination,
            "duration": body.duration
        }),
    )
    .await?;

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
    let user_id: Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // 1. Verify membership
    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    // 2. Fetch user name
    let user = state
        .user_repo
        .find_by_id(user_id)
        .await?
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
    let user_id: Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // 1. Verify membership
    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    // 2. Fetch user name
    let user = state
        .user_repo
        .find_by_id(user_id)
        .await?
        .ok_or_else(|| AppError::NotFound("User not found".into()))?;
    let user_name = user.name.unwrap_or_else(|| "Someone".into());

    // 3. Fetch FCM tokens for other circle members
    let title = format!("{} stopped broadcasting", user_name);
    let body_text = "They have safely stopped their journey.";
    let recipients = sqlx::query(
        "SELECT cm.user_id, dt.fcm_token
         FROM circle_memberships cm
         LEFT JOIN device_tokens dt ON dt.user_id = cm.user_id
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
    create_notifications(
        &state.db_pool,
        &recipient_ids,
        Some(user_id),
        "journey_stopped",
        &title,
        body_text,
        serde_json::json!({
            "circle_id": body.circle_id,
            "route": "journey",
            "status": "stopped"
        }),
    )
    .await?;

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
