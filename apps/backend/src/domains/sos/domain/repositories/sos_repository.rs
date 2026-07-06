use crate::domains::sos::domain::entities::sos_broadcast::{SosBroadcast, SosBroadcastWithProfile};
use crate::shared::errors::AppError;
use async_trait::async_trait;
use uuid::Uuid;

/// Contract for persisting and querying SOS broadcast events.
#[async_trait]
pub trait SosRepository: Send + Sync {
    /// Create a new active SOS broadcast for a user in a circle.
    async fn create(
        &self,
        user_id: Uuid,
        circle_id: Uuid,
        latitude: Option<f64>,
        longitude: Option<f64>,
        address: Option<String>,
    ) -> Result<SosBroadcast, AppError>;

    /// Return all broadcasts for a circle, newest first, enriched with
    /// the triggering member's profile (name + avatar) for the UI list.
    async fn list_for_circle(
        &self,
        circle_id: Uuid,
        limit: i64,
        offset: i64,
    ) -> Result<Vec<SosBroadcastWithProfile>, AppError>;

    /// Mark an active SOS broadcast as resolved.
    async fn resolve(&self, id: Uuid, resolver_user_id: Uuid) -> Result<SosBroadcast, AppError>;

    /// Mark an active SOS broadcast as dismissed by the triggering user.
    async fn dismiss(&self, id: Uuid, user_id: Uuid) -> Result<SosBroadcast, AppError>;
}
