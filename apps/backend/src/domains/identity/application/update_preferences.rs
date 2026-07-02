use std::sync::Arc;
use uuid::Uuid;
use crate::shared::errors::AppError;
use crate::domains::identity::domain::{
    entities::user::User,
    repositories::user_repository::UserRepository,
};

pub struct UpdatePreferencesUseCase {
    pub user_repo: Arc<dyn UserRepository>,
}

impl UpdatePreferencesUseCase {
    pub async fn execute(
        &self,
        user_id: &str,
        location_enabled: bool,
        notifications_enabled: bool,
    ) -> Result<User, AppError> {
        let id = Uuid::parse_str(user_id)
            .map_err(|_| AppError::InvalidInput("Invalid user ID".to_string()))?;

        let user = self.user_repo
            .update_preferences(id, location_enabled, notifications_enabled)
            .await?;
        
        Ok(user)
    }
}
