use axum::{extract::State, Json};
//use crate::domains::identity::domain::entities::user_session::UserSession;
use crate::domains::identity::{
    api::dto::*,
    application::{
        firebase_exchange::FirebaseExchangeUseCase, get_profile::GetProfileUseCase,
        refresh_token::RefreshTokenUseCase, send_otp::SendOtpUseCase,
        setup_profile::SetupProfileUseCase, update_preferences::UpdatePreferencesUseCase,
        verify_otp::VerifyOtpUseCase,
    },
};
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};

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
        sms_gateway: todo!(),
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
        location_enabled: user.location_enabled,
        notifications_enabled: user.notifications_enabled,
        created_at: user.created_at,
    }))
}

// ── PATCH /api/v1/auth/preferences ─────────────────────────────────────────

pub async fn update_preferences(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<UpdatePreferencesRequest>,
) -> Result<Json<ProfileResponse>, AppError> {
    let use_case = UpdatePreferencesUseCase {
        user_repo: state.user_repo.clone(),
    };
    let user = use_case
        .execute(
            &claims.sub,
            body.location_enabled,
            body.notifications_enabled,
        )
        .await?;
    Ok(Json(ProfileResponse {
        user_id: user.id.to_string(),
        phone: user.phone,
        name: user.name,
        avatar_url: user.avatar_url,
        is_profile_complete: user.is_profile_complete,
        location_enabled: user.location_enabled,
        notifications_enabled: user.notifications_enabled,
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
        location_enabled: user.location_enabled,
        notifications_enabled: user.notifications_enabled,
        created_at: user.created_at,
    }))
}

// ── GET /api/v1/auth/sessions ──────────────────────────────────────────────

pub async fn get_sessions(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
) -> Result<Json<Vec<SessionResponse>>, AppError> {
    let user_id: uuid::Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let sessions = state.session_repo.list_for_user(user_id).await?;

    let resp = sessions
        .into_iter()
        .map(|s| SessionResponse {
            device_name: s.device_name,
            device_model: s.device_model,
            platform: s.platform,
            last_active_at: s.last_active_at,
            created_at: s.created_at,
        })
        .collect();

    Ok(Json(resp))
}

// ── DELETE /api/v1/auth/sessions/:hash ──────────────────────────────────────

pub async fn revoke_session(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    axum::extract::Path(hash): axum::extract::Path<String>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id: uuid::Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // Make sure the session belongs to the user
    if let Some(session) = state.session_repo.find_by_token_hash(&hash).await? {
        if session.user_id != user_id {
            return Err(AppError::Unauthorized("Cannot revoke this session.".into()));
        }
        state.session_repo.delete_by_token_hash(&hash).await?;
    }

    Ok(Json(
        serde_json::json!({ "message": "Session revoked successfully" }),
    ))
}

// ── POST /api/v1/auth/firebase-exchange ────────────────────────────────────

pub async fn firebase_exchange(
    State(state): State<AppState>,
    Json(body): Json<FirebaseExchangeRequest>,
) -> Result<Json<AuthResponse>, AppError> {
    #[derive(serde::Deserialize)]
    struct FirebaseClaims {
        pub sub: String,
        pub phone_number: Option<String>,
    }

    // Parse JWT payload without verification for dev prototyping
    let parts: Vec<&str> = body.id_token.split('.').collect();
    if parts.len() != 3 {
        return Err(AppError::Unauthorized("Invalid token format".into()));
    }

    let payload_b64 = parts[1].replace('-', "+").replace('_', "/");
    let payload_bytes = base64::Engine::decode(
        &base64::engine::general_purpose::STANDARD_NO_PAD,
        pad_base64(&payload_b64),
    )
    .map_err(|_| AppError::Unauthorized("Invalid token payload".into()))?;

    let token_data: FirebaseClaims = serde_json::from_slice(&payload_bytes)
        .map_err(|_| AppError::Unauthorized("Invalid token claims".into()))?;

    // Use token's phone_number if present, otherwise trust the client body (for test numbers)
    let phone = token_data.phone_number.unwrap_or(body.phone);
    let device_name = "Guardian App"; // Future enhancement: pass this via header or body

    let use_case = FirebaseExchangeUseCase {
        user_repo: state.user_repo.clone(),
        session_repo: state.session_repo.clone(),
        config: state.config.clone(),
    };

    let output = use_case.execute(&phone, device_name).await?;

    Ok(Json(AuthResponse {
        access_token: output.access_token,
        refresh_token: output.refresh_token,
        user_id: output.user_id,
        phone: output.phone,
        is_profile_complete: output.is_profile_complete,
    }))
}

fn pad_base64(input: &str) -> String {
    let mut s = input.to_string();
    while s.len() % 4 != 0 {
        s.push('=');
    }
    s
}
