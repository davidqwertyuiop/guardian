use crate::domains::circles::domain::entities::invite_token::InviteToken;
use crate::shared::errors::AppError;
use async_trait::async_trait;
use uuid::Uuid;

#[async_trait]
pub trait InviteRepository: Send + Sync {
    /// Store a new invite with both a short code (3-day) and URL token (60-day).
    async fn create(
        &self,
        circle_id: Uuid,
        created_by: Uuid,
        code: &str,
        token: &str,
    ) -> Result<InviteToken, AppError>;

    /// Find by the 4-char human code (only if code_expires_at is in the future).
    async fn find_by_code(&self, code: &str) -> Result<Option<InviteToken>, AppError>;

    /// Find by the URL-safe token (only if link_expires_at is in the future).
    async fn find_by_token(&self, token: &str) -> Result<Option<InviteToken>, AppError>;

    /// Increment used_count after a successful join.
    async fn increment_used(&self, id: Uuid) -> Result<(), AppError>;

    /// Check whether a circle has at least one member other than the owner.
    async fn circle_has_members(&self, circle_id: Uuid, owner_id: Uuid) -> Result<bool, AppError>;
}
