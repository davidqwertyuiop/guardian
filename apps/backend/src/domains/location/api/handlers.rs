use axum::{extract::{Path, State}, Json};
use uuid::Uuid;
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use super::dto::{MemberLocationResponse, UpdateLocationRequest, UpdateLocationResponse};

// ── PUT /api/v1/location ────────────────────────────────────────────────────
//
// Device posts its current GPS fix for a specific circle.
// Upserts a single row per (user_id, circle_id) pair so the table stays lean.

pub async fn update_location(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<UpdateLocationRequest>,
) -> Result<Json<UpdateLocationResponse>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // Verify the caller is a member of the target circle before accepting
    // their location — prevents cross-circle spoofing.
    if !state.circle_repo.is_member(body.circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    let updated = state
        .location_repo
        .upsert(
            user_id,
            body.circle_id,
            body.latitude,
            body.longitude,
            body.accuracy,
            body.heading,
            body.speed,
        )
        .await?;

    Ok(Json(UpdateLocationResponse {
        updated_at: updated.updated_at,
    }))
}

// ── GET /api/v1/location/circles/:id ───────────────────────────────────────
//
// Returns the latest known location for every member of a circle.
// Used by the Flutter map overlay to render member markers.

pub async fn get_circle_locations(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Path(circle_id): Path<Uuid>,
) -> Result<Json<Vec<MemberLocationResponse>>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // Membership check — only circle members can query locations.
    if !state.circle_repo.is_member(circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    let locations = state.location_repo.get_circle_member_locations(circle_id).await?;

    let resp = locations
        .into_iter()
        .map(|loc| MemberLocationResponse {
            user_id: loc.user_id.to_string(),
            name: loc.name,
            avatar_url: loc.avatar_url,
            latitude: loc.latitude,
            longitude: loc.longitude,
            accuracy: loc.accuracy,
            updated_at: loc.updated_at,
        })
        .collect();

    Ok(Json(resp))
}
