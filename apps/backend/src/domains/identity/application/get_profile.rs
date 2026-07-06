use crate::domains::identity::domain::{
    entities::user::User, repositories::user_repository::UserRepository,
};
use crate::shared::errors::AppError;
use std::sync::Arc;
use uuid::Uuid;

pub struct GetProfileUseCase {
    pub user_repo: Arc<dyn UserRepository>,
}

impl GetProfileUseCase {
    pub async fn execute(&self, user_id: &str) -> Result<User, AppError> {
        let id = Uuid::parse_str(user_id)
            .map_err(|_| AppError::InvalidInput("Invalid user ID".to_string()))?;
        self.user_repo
            .find_by_id(id)
            .await?
            .ok_or_else(|| AppError::NotFound("User not found".to_string()))
    }
}
