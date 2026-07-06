use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

// ── Requests ────────────────────────────────────────────────────────────────

/// Body for `POST /api/v1/sos` — trigger a new SOS broadcast.
#[derive(Debug, Deserialize)]
pub struct TriggerSosRequest {
    pub circle_id: Uuid,
    pub latitude: Option<f64>,
    pub longitude: Option<f64>,
    pub address: Option<String>,
}

/// Body for `POST /api/v1/sos/:id/resolve`.
#[derive(Debug, Deserialize)]
pub struct ResolveSosRequest {
    // Reserved for future note/message field.
}

// ── Responses ───────────────────────────────────────────────────────────────

/// Trimmed broadcast response for list views.
#[derive(Debug, Serialize)]
pub struct SosBroadcastResponse {
    pub id: String,
    pub user_id: String,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub latitude: Option<f64>,
    pub longitude: Option<f64>,
    pub address: Option<String>,
    pub status: String,
    pub created_at: DateTime<Utc>,
}

/// Minimal response returned after creating or mutating a broadcast.
#[derive(Debug, Serialize)]
pub struct SosActionResponse {
    pub id: String,
    pub status: String,
}
