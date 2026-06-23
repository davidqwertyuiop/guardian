use std::sync::Arc;
use uuid::Uuid;
use crate::shared::errors::AppError;
use crate::domains::circles::domain::repositories::{
    circle_repository::CircleRepository,
    invite_repository::InviteRepository,
};

pub struct JoinByCodeUseCase {
    pub circle_repo: Arc<dyn CircleRepository>,
    pub invite_repo: Arc<dyn InviteRepository>,
}

impl JoinByCodeUseCase {
    pub async fn execute(&self, user_id: Uuid, code: &str) -> Result<Uuid, AppError> {
        let code = code.trim().to_uppercase();

        // 1. Look up the invite (partial index guarantees only active codes found)
        let invite = self
            .invite_repo
            .find_by_code(&code)
            .await?
            .ok_or_else(|| AppError::NotFound(
                "Invite code not found or expired. Codes are valid for 3 days.".into(),
            ))?;

        // 2. Check max_uses if set
        if let Some(max) = invite.max_uses {
            if invite.used_count >= max {
                return Err(AppError::InvalidInput("This invite code has reached its usage limit.".into()));
            }
        }

        // 3. Already a member?
        if self.circle_repo.is_member(invite.circle_id, user_id).await? {
            return Ok(invite.circle_id); // idempotent
        }

        // 4. Add membership
        self.circle_repo
            .add_member(invite.circle_id, user_id, "member")
            .await?;

        // 5. Increment used count
        self.invite_repo.increment_used(invite.id).await?;

        Ok(invite.circle_id)
    }
}
