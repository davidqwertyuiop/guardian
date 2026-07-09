use crate::domains::identity::domain::repositories::user_repository::UserRepository;
use crate::shared::errors::AppError;
use std::sync::Arc;
use uuid::Uuid;

pub struct DeleteAccountUseCase {
    pub user_repo: Arc<dyn UserRepository>,
}

impl DeleteAccountUseCase {
    pub async fn execute(&self, user_id: &str) -> Result<(), AppError> {
        let id = Uuid::parse_str(user_id)
            .map_err(|_| AppError::InvalidInput("Invalid user ID".to_string()))?;
        self.user_repo.delete(id).await
    }
}
