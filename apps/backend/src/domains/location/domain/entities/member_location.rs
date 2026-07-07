use chrono::{DateTime, Utc};
use uuid::Uuid;

/// Represents the most-recent known GPS location of a circle member.
/// One row per (user_id, circle_id) pair — upserted on every device ping.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct MemberLocation {
    pub id: Uuid,
    pub user_id: Uuid,
    pub circle_id: Uuid,
    pub latitude: f64,
    pub longitude: f64,
    pub accuracy: Option<f32>,
    pub heading: Option<f32>,
    pub speed: Option<f32>,
    pub battery_level: Option<i32>,
    pub connectivity_type: Option<String>,
    pub recorded_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// Member location enriched with public profile data — for the map overlay.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct MemberLocationWithProfile {
    pub user_id: Uuid,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub latitude: f64,
    pub longitude: f64,
    pub accuracy: Option<f32>,
    pub battery_level: Option<i32>,
    pub connectivity_type: Option<String>,
    pub updated_at: DateTime<Utc>,
}
