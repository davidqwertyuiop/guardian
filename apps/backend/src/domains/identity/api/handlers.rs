use axum::{extract::State, Json};
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use crate::domains::identity::{
    application::{
        send_otp::SendOtpUseCase,
        verify_otp::VerifyOtpUseCase,
        setup_profile::SetupProfileUseCase,
        refresh_token::RefreshTokenUseCase,
        get_profile::GetProfileUseCase,
    },
    api::dto::*,
};

// ── POST /api/v1/auth/send-otp ──────────────────────────────────────────────

pub async fn send_otp(
    State(state): State<AppState>,
    Json(body): Json<SendOtpRequest>,
) -> Result<Json<SendOtpResponse>, AppError> {
    let use_case = SendOtpUseCase {
        otp_repo: state.otp_repo.clone(),
        user_repo: state.user_repo.clone(),
        sms_gateway: state.sms_gateway.clone(),
        config: state.config.clone(),
    };
    use_case.execute(&body.phone).await?;
    Ok(Json(SendOtpResponse {
        message: "Verification code sent".to_string(),
    }))
}

// ── POST /api/v1/auth/verify-otp ───────────────────────────────────────────

pub async fn verify_otp(
    State(state): State<AppState>,
    Json(body): Json<VerifyOtpRequest>,
) -> Result<Json<AuthResponse>, AppError> {
    let use_case = VerifyOtpUseCase {
        otp_repo: state.otp_repo.clone(),
        user_repo: state.user_repo.clone(),
        config: state.config.clone(),
    };
    let output = use_case.execute(&body.phone, &body.code).await?;
    Ok(Json(AuthResponse {
        access_token: output.access_token,
        refresh_token: output.refresh_token,
        user_id: output.user_id,
        phone: output.phone,
        is_profile_complete: output.is_profile_complete,
    }))
}

// ── PATCH /api/v1/auth/profile ─────────────────────────────────────────────

pub async fn setup_profile(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<SetupProfileRequest>,
) -> Result<Json<ProfileResponse>, AppError> {
    let use_case = SetupProfileUseCase {
        user_repo: state.user_repo.clone(),
    };
    let user = use_case.execute(&claims.sub, &body.name).await?;
    Ok(Json(ProfileResponse {
        user_id: user.id.to_string(),
        phone: user.phone,
        name: user.name,
        avatar_url: user.avatar_url,
        is_profile_complete: user.is_profile_complete,
        created_at: user.created_at,
    }))
}

// ── POST /api/v1/auth/refresh ──────────────────────────────────────────────

pub async fn refresh_token(
    State(state): State<AppState>,
    Json(body): Json<RefreshTokenRequest>,
) -> Result<Json<RefreshTokenResponse>, AppError> {
    let use_case = RefreshTokenUseCase {
        user_repo: state.user_repo.clone(),
        config: state.config.clone(),
    };
    let output = use_case.execute(&body.refresh_token).await?;
    Ok(Json(RefreshTokenResponse {
        access_token: output.access_token,
    }))
}

// ── GET /api/v1/auth/me ────────────────────────────────────────────────────

pub async fn get_me(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
) -> Result<Json<ProfileResponse>, AppError> {
    let use_case = GetProfileUseCase {
        user_repo: state.user_repo.clone(),
    };
    let user = use_case.execute(&claims.sub).await?;
    Ok(Json(ProfileResponse {
        user_id: user.id.to_string(),
        phone: user.phone,
        name: user.name,
        avatar_url: user.avatar_url,
        is_profile_complete: user.is_profile_complete,
        created_at: user.created_at,
    }))
}
