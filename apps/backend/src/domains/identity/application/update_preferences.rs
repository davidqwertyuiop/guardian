use crate::domains::identity::domain::{
    entities::user::User, repositories::user_repository::UserRepository,
};
use crate::shared::errors::AppError;
use std::sync::Arc;
use uuid::Uuid;

pub struct UpdatePreferencesUseCase {
    pub user_repo: Arc<dyn UserRepository>,
}

impl UpdatePreferencesUseCase {
    pub async fn execute(
        &self,
        user_id: &str,
        location_enabled: bool,
        notify_sos: bool,
        notify_broadcast: bool,
        notify_new_member: bool,
        location_paused_until: Option<chrono::DateTime<chrono::Utc>>,
    ) -> Result<User, AppError> {
        let id = Uuid::parse_str(user_id)
            .map_err(|_| AppError::InvalidInput("Invalid user ID".to_string()))?;

        let user = self
            .user_repo
            .update_preferences(
                id,
                location_enabled,
                notify_sos,
                notify_broadcast,
                notify_new_member,
                location_paused_until,
            )
            .await?;

        Ok(user)
    }
}
