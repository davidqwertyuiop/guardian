use super::super::entities::user::User;
use crate::shared::errors::AppError;
use async_trait::async_trait;
use uuid::Uuid;

#[async_trait]
pub trait UserRepository: Send + Sync {
    /// Find a user by their phone number.
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>, AppError>;

    /// Find a user by their UUID.
    async fn find_by_id(&self, id: Uuid) -> Result<Option<User>, AppError>;

    /// Create a new user with just a phone number. Returns the created user.
    async fn create(&self, phone: &str) -> Result<User, AppError>;

    /// Update name and mark profile as complete.
    async fn update_profile(&self, id: Uuid, name: &str) -> Result<User, AppError>;

    /// Update user preferences for location and notifications.
    async fn update_preferences(
        &self,
        id: Uuid,
        location_enabled: bool,
        notify_sos: bool,
        notify_broadcast: bool,
        notify_new_member: bool,
        location_paused_until: Option<chrono::DateTime<chrono::Utc>>,
    ) -> Result<User, AppError>;

    /// Permanently delete a user account.
    async fn delete(&self, id: Uuid) -> Result<(), AppError>;

    /// Update the stored avatar URL for a user.
    async fn update_avatar_url(&self, id: Uuid, avatar_url: &str) -> Result<User, AppError>;
}
