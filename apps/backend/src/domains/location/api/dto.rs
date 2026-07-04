use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;

// ── Requests ────────────────────────────────────────────────────────────────

/// Body for `PUT /api/v1/location` — device posts its current GPS fix.
#[derive(Debug, Deserialize)]
pub struct UpdateLocationRequest {
    pub circle_id: Uuid,
    pub latitude: f64,
    pub longitude: f64,
    /// Horizontal accuracy in metres (optional).
    pub accuracy: Option<f32>,
    /// Compass heading in degrees 0–360 (optional).
    pub heading: Option<f32>,
    /// Ground speed in m/s (optional).
    pub speed: Option<f32>,
}

// ── Responses ───────────────────────────────────────────────────────────────

/// Sparse location acknowledgement returned after a successful upsert.
#[derive(Debug, Serialize)]
pub struct UpdateLocationResponse {
    pub updated_at: DateTime<Utc>,
}

/// A single circle member's latest location, returned in the map overlay list.
#[derive(Debug, Serialize)]
pub struct MemberLocationResponse {
    pub user_id: String,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub latitude: f64,
    pub longitude: f64,
    pub accuracy: Option<f32>,
    pub updated_at: DateTime<Utc>,
}
