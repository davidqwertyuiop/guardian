use crate::domains::identity::domain::{
    entities::user::User, repositories::user_repository::UserRepository,
};
use crate::shared::errors::AppError;
use std::sync::Arc;
use uuid::Uuid;

pub struct SetupProfileUseCase {
    pub user_repo: Arc<dyn UserRepository>,
}

impl SetupProfileUseCase {
    pub async fn execute(&self, user_id: &str, name: &str) -> Result<User, AppError> {
        let name = name.trim();
        if name.is_empty() {
            return Err(AppError::InvalidInput("Name cannot be empty".to_string()));
        }
        if name.len() > 100 {
            return Err(AppError::InvalidInput(
                "Name must be 100 characters or fewer".to_string(),
            ));
        }

        let id = Uuid::parse_str(user_id)
            .map_err(|_| AppError::InvalidInput("Invalid user ID".to_string()))?;

        let user = self.user_repo.update_profile(id, name).await?;
        Ok(user)
    }
}
