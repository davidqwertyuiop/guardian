use crate::domains::identity::domain::{
    entities::user::User, repositories::user_repository::UserRepository,
};
use crate::shared::errors::AppError;
use std::path::PathBuf;
use std::sync::Arc;
use uuid::Uuid;

pub struct UpdateAvatarUseCase {
    pub user_repo: Arc<dyn UserRepository>,
    /// Base directory where uploaded avatars are written, e.g. "./uploads/avatars"
    pub uploads_dir: PathBuf,
    /// Public base URL prefix, e.g. "http://localhost:8080/uploads/avatars"
    pub public_base_url: String,
}

impl UpdateAvatarUseCase {
    pub async fn execute(
        &self,
        user_id_str: &str,
        filename: &str,
        bytes: Vec<u8>,
    ) -> Result<User, AppError> {
        if bytes.is_empty() {
            return Err(AppError::InvalidInput("Avatar file is empty".into()));
        }
        // 5 MB guard
        if bytes.len() > 5 * 1024 * 1024 {
            return Err(AppError::InvalidInput(
                "Avatar must be smaller than 5 MB".into(),
            ));
        }

        let ext = Self::safe_ext(filename)?;
        let id: Uuid = user_id_str
            .parse()
            .map_err(|_| AppError::InvalidInput("Invalid user id".into()))?;

        // Write to disk — filename is deterministic per user so re-upload just
        // overwrites the previous file with no orphaned data.
        tokio::fs::create_dir_all(&self.uploads_dir)
            .await
            .map_err(|e| AppError::Internal(format!("Cannot create uploads dir: {e}")))?;

        let disk_name = format!("avatar_{id}.{ext}");
        let path = self.uploads_dir.join(&disk_name);
        tokio::fs::write(&path, &bytes)
            .await
            .map_err(|e| AppError::Internal(format!("Failed to write avatar: {e}")))?;

        let url = format!("{}/{}", self.public_base_url.trim_end_matches('/'), disk_name);
        let user = self.user_repo.update_avatar_url(id, &url).await?;
        Ok(user)
    }

    fn safe_ext(filename: &str) -> Result<&'static str, AppError> {
        let lower = filename.to_lowercase();
        if lower.ends_with(".jpg") || lower.ends_with(".jpeg") {
            Ok("jpg")
        } else if lower.ends_with(".png") {
            Ok("png")
        } else if lower.ends_with(".webp") {
            Ok("webp")
        } else {
            Err(AppError::InvalidInput(
                "Only jpg, png, or webp avatars are accepted".into(),
            ))
        }
    }
}
