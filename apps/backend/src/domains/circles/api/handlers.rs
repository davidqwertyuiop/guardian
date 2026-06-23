use axum::{extract::{State, Path}, Json};
use uuid::Uuid;
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use crate::domains::circles::{
    application::{
        create_circle::CreateCircleUseCase,
        join_by_code::JoinByCodeUseCase,
        join_by_link::JoinByLinkUseCase,
    },
    api::dto::*,
};

/// Base URL for invite deep links — update to your production domain.
const INVITE_BASE_URL: &str = "https://guardian.app/invite";

// ── POST /api/v1/circles ────────────────────────────────────────────────────

pub async fn create_circle(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<CreateCircleRequest>,
) -> Result<Json<CreateCircleResponse>, AppError> {
    let owner_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let uc = CreateCircleUseCase {
        circle_repo: state.circle_repo.clone(),
        invite_repo: state.invite_repo.clone(),
    };
    let output = uc.execute(owner_id, &body.name).await?;

    Ok(Json(CreateCircleResponse {
        circle: CircleResponse {
            id: output.circle.id.to_string(),
            name: output.circle.name,
            owner_id: output.circle.owner_id.to_string(),
            created_at: output.circle.created_at,
        },
        invite: InviteResponse {
            code: output.invite.code.clone(),
            invite_link: format!("{}/{}", INVITE_BASE_URL, output.invite.token),
            code_expires_at: output.invite.code_expires_at,
            link_expires_at: output.invite.link_expires_at,
        },
    }))
}

// ── GET /api/v1/circles ─────────────────────────────────────────────────────

pub async fn list_circles(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
) -> Result<Json<Vec<CircleResponse>>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let circles = state.circle_repo.list_for_user(user_id).await?;
    let resp = circles.into_iter().map(|c| CircleResponse {
        id: c.id.to_string(),
        name: c.name,
        owner_id: c.owner_id.to_string(),
        created_at: c.created_at,
    }).collect();

    Ok(Json(resp))
}

// ── GET /api/v1/circles/:id/members ────────────────────────────────────────

pub async fn get_members(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Path(circle_id): Path<Uuid>,
) -> Result<Json<Vec<MemberResponse>>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // Only members can see the list
    if !state.circle_repo.is_member(circle_id, user_id).await? {
        return Err(AppError::Unauthorized("You are not a member of this circle.".into()));
    }

    let members = state.circle_repo.get_members(circle_id).await?;
    let resp = members.into_iter().map(|m| MemberResponse {
        user_id: m.user_id.to_string(),
        name: m.name,
        avatar_url: m.avatar_url,
        phone: m.phone,
        role: m.role,
        joined_at: m.joined_at,
    }).collect();

    Ok(Json(resp))
}

// ── POST /api/v1/circles/join/code ─────────────────────────────────────────

pub async fn join_by_code(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<JoinByCodeRequest>,
) -> Result<Json<JoinCircleResponse>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let uc = JoinByCodeUseCase {
        circle_repo: state.circle_repo.clone(),
        invite_repo: state.invite_repo.clone(),
    };
    let circle_id = uc.execute(user_id, &body.code).await?;

    Ok(Json(JoinCircleResponse {
        circle_id: circle_id.to_string(),
        message: "Successfully joined the circle".into(),
    }))
}

// ── POST /api/v1/circles/join/link ─────────────────────────────────────────

pub async fn join_by_link(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<JoinByLinkRequest>,
) -> Result<Json<JoinCircleResponse>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let uc = JoinByLinkUseCase {
        circle_repo: state.circle_repo.clone(),
        invite_repo: state.invite_repo.clone(),
    };
    let circle_id = uc.execute(user_id, &body.token).await?;

    Ok(Json(JoinCircleResponse {
        circle_id: circle_id.to_string(),
        message: "Successfully joined the circle via invite link".into(),
    }))
}
