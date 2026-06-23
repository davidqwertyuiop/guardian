use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;

// ── Requests ────────────────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct CreateCircleRequest {
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct JoinByCodeRequest {
    pub code: String,
}

#[derive(Debug, Deserialize)]
pub struct JoinByLinkRequest {
    pub token: String,
}

// ── Responses ───────────────────────────────────────────────────────────────

#[derive(Debug, Serialize)]
pub struct CircleResponse {
    pub id: String,
    pub name: String,
    pub owner_id: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize)]
pub struct InviteResponse {
    /// 4-char human code, valid for 3 days
    pub code: String,
    /// Full deep-link URL, valid for 60 days
    pub invite_link: String,
    pub code_expires_at: DateTime<Utc>,
    pub link_expires_at: DateTime<Utc>,
}

#[derive(Debug, Serialize)]
pub struct CreateCircleResponse {
    pub circle: CircleResponse,
    pub invite: InviteResponse,
}

#[derive(Debug, Serialize)]
pub struct MemberResponse {
    pub user_id: String,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub phone: String,
    pub role: String,
    pub joined_at: DateTime<Utc>,
}

#[derive(Debug, Serialize)]
pub struct JoinCircleResponse {
    pub circle_id: String,
    pub message: String,
}
