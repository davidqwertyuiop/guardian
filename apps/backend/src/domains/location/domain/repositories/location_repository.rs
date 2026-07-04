use async_trait::async_trait;
use uuid::Uuid;
use crate::shared::errors::AppError;
use crate::domains::location::domain::entities::member_location::{
    MemberLocation, MemberLocationWithProfile,
};

/// Contract for persisting and querying member GPS locations.
#[async_trait]
pub trait LocationRepository: Send + Sync {
    /// Upsert the caller's location for a given circle.
    /// Called on every device location ping.
    async fn upsert(
        &self,
        user_id: Uuid,
        circle_id: Uuid,
        latitude: f64,
        longitude: f64,
        accuracy: Option<f32>,
        heading: Option<f32>,
        speed: Option<f32>,
    ) -> Result<MemberLocation, AppError>;

    /// Return the latest known location for every member of a circle,
    /// enriched with name and avatar for the map overlay.
    async fn get_circle_member_locations(
        &self,
        circle_id: Uuid,
    ) -> Result<Vec<MemberLocationWithProfile>, AppError>;

    /// Return the latest known location for a single user within a circle.
    async fn get_user_location(
        &self,
        user_id: Uuid,
        circle_id: Uuid,
    ) -> Result<Option<MemberLocation>, AppError>;
}
