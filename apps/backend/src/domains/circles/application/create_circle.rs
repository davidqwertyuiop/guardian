use std::sync::Arc;
use uuid::Uuid;
use rand::{Rng, distributions::Alphanumeric};
use chrono::Utc;
use crate::shared::errors::AppError;
use crate::domains::circles::domain::{
    entities::{circle::Circle, invite_token::InviteToken},
    repositories::{circle_repository::CircleRepository, invite_repository::InviteRepository},
};

pub struct CreateCircleOutput {
    pub circle: Circle,
    pub invite: InviteToken,
}

pub struct CreateCircleUseCase {
    pub circle_repo: Arc<dyn CircleRepository>,
    pub invite_repo: Arc<dyn InviteRepository>,
}

impl CreateCircleUseCase {
    pub async fn execute(
        &self,
        owner_id: Uuid,
        name: &str,
    ) -> Result<CreateCircleOutput, AppError> {
        let name = name.trim();
        if name.is_empty() {
            return Err(AppError::InvalidInput("Circle name cannot be empty".into()));
        }

        // Check if the owner already has a circle with this name
        if let Some(_) = self.circle_repo.find_by_owner_and_name(owner_id, name).await? {
            return Err(AppError::InvalidInput("A circle with this name already exists".into()));
        }

        // 1. Create the circle
        let circle = self.circle_repo.create(name, owner_id).await?;

        // 2. Add the owner as the first member
        self.circle_repo
            .add_member(circle.id, owner_id, "owner")
            .await?;

        // 3. Generate a 4-char alphanumeric code and a 6-byte URL-safe token
        let code  = generate_code(4);
        let token = generate_token(6);

        let now = Utc::now();
        let invite = self.invite_repo
            .create(circle.id, owner_id, &code, &token)
            .await?;

        let _ = now; // suppress warning

        Ok(CreateCircleOutput { circle, invite })
    }
}

/// 4-char uppercase alphanumeric code.
fn generate_code(len: usize) -> String {
    rand::thread_rng()
        .sample_iter(Alphanumeric)
        .take(len)
        .map(|c| (c as char).to_ascii_uppercase())
        .collect()
}

/// URL-safe random token of `len` bytes (hex-encoded → `len * 2` chars).
fn generate_token(len: usize) -> String {
    let bytes: Vec<u8> = (0..len).map(|_| rand::thread_rng().gen()).collect();
    hex::encode(bytes)
}
