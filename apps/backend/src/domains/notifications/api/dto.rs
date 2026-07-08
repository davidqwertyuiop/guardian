use chrono::{DateTime, Utc};
use serde::Serialize;
use serde_json::Value;

#[derive(Debug, Serialize)]
pub struct NotificationListResponse {
    pub unread_count: i64,
    pub items: Vec<NotificationResponse>,
}

#[derive(Debug, Serialize)]
pub struct NotificationResponse {
    pub id: String,
    pub kind: String,
    pub title: String,
    pub body: String,
    pub is_read: bool,
    pub created_at: DateTime<Utc>,
    pub actor_name: Option<String>,
    pub actor_avatar_url: Option<String>,
    pub data: Value,
}
