# handlers.rs

* **File Path:** `apps/backend/src/domains/location/api/handlers.rs`
* **Type:** `RUST`

---

```rust
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

fn haversine_distance(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    let r = 6371000.0; // Earth radius in meters
    let phi1 = lat1.to_radians();
    let phi2 = lat2.to_radians();
    let delta_phi = (lat2 - lat1).to_radians();
    let delta_lambda = (lon2 - lon1).to_radians();

    let a = (delta_phi / 2.0).sin().powi(2)
        + phi1.cos() * phi2.cos() * (delta_lambda / 2.0).sin().powi(2);
    let c = 2.0 * a.sqrt().atan2((1.0 - a).sqrt());

    r * c
}

#[derive(serde::Serialize)]
pub struct NearestMemberResponse {
    pub name: String,
    pub avatar_url: Option<String>,
    pub distance_km: f64,
    pub duration_mins: i32,
}

pub async fn get_nearest_member_location(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Path(circle_id): Path<Uuid>,
) -> Result<Json<Option<NearestMemberResponse>>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // Verify membership
    if !state.circle_repo.is_member(circle_id, user_id).await? {
        return Err(AppError::Unauthorized(
            "You are not a member of this circle.".into(),
        ));
    }

    // Fetch user's own location
    let user_loc = match state.location_repo.get_user_location(user_id, circle_id).await? {
        Some(loc) => loc,
        None => return Ok(Json(None)),
    };

    // Fetch all members' locations
    let members = state.location_repo.get_circle_member_locations(circle_id).await?;

    let mut nearest_member = None;
    let mut min_distance = f64::MAX;

    for m in &members {
        if m.user_id == user_id {
            continue;
        }
        let dist = haversine_distance(user_loc.latitude, user_loc.longitude, m.latitude, m.longitude);
        if dist < min_distance {
            min_distance = dist;
            nearest_member = Some(m);
        }
    }

    if let Some(m) = nearest_member {
        let distance_km = min_distance / 1000.0;
        let duration_mins = (distance_km / 40.0 * 60.0).round() as i32;
        Ok(Json(Some(NearestMemberResponse {
            name: m.name.clone().unwrap_or_else(|| "Member".into()),
            avatar_url: m.avatar_url.clone(),
            distance_km,
            duration_mins: duration_mins.clamp(1, 120),
        })))
    } else {
        Ok(Json(None))
    }
}

```
