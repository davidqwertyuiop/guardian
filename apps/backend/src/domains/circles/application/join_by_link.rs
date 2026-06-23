use std::sync::Arc;
use uuid::Uuid;
use chrono::Utc;
use crate::shared::errors::AppError;
use crate::domains::circles::domain::repositories::{
    circle_repository::CircleRepository,
    invite_repository::InviteRepository,
};

pub struct JoinByLinkUseCase {
    pub circle_repo: Arc<dyn CircleRepository>,
    pub invite_repo: Arc<dyn InviteRepository>,
}

impl JoinByLinkUseCase {
    pub async fn execute(&self, user_id: Uuid, token: &str) -> Result<Uuid, AppError> {
        let token = token.trim();

        // 1. Fetch the invite record
        let invite = self
            .invite_repo
            .find_by_token(token)
            .await?
            .ok_or_else(|| AppError::NotFound("Invite link not found.".into()))?;

        // 2. Check link_expires_at (60-day window)
        if Utc::now() > invite.link_expires_at {
            return Err(AppError::InvalidInput(
                "This invite link has expired. Ask the circle owner to share a new one.".into(),
            ));
        }

        // 3. Check max_uses if set
        if let Some(max) = invite.max_uses {
            if invite.used_count >= max {
                return Err(AppError::InvalidInput(
                    "This invite link has reached its usage limit.".into(),
                ));
            }
        }

        // 4. Idempotent membership check
        if self.circle_repo.is_member(invite.circle_id, user_id).await? {
            return Ok(invite.circle_id);
        }

        // 5. Add membership
        self.circle_repo
            .add_member(invite.circle_id, user_id, "member")
            .await?;

        // 6. Bump used_count
        self.invite_repo.increment_used(invite.id).await?;

        Ok(invite.circle_id)
    }
}
