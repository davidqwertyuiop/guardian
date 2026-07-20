use crate::domains::identity::{
    api::dto::*,
    application::{
        delete_account::DeleteAccountUseCase, firebase_exchange::FirebaseExchangeUseCase,
        get_profile::GetProfileUseCase, refresh_token::RefreshTokenUseCase,
        send_otp::SendOtpUseCase, setup_profile::SetupProfileUseCase,
        update_avatar::UpdateAvatarUseCase, update_preferences::UpdatePreferencesUseCase,
        verify_otp::VerifyOtpUseCase,
    },
};
use crate::infrastructure::sms::sendchamp::SendchampSmsService;
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use axum::extract::Multipart;
use axum::{extract::State, Json};
use std::sync::Arc;

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
        notify_sos: user.notify_sos,
        notify_broadcast: user.notify_broadcast,
        notify_new_member: user.notify_new_member,
        location_paused_until: user.location_paused_until,
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
            body.notify_sos,
            body.notify_broadcast,
            body.notify_new_member,
            body.location_paused_until,
        )
        .await?;
    Ok(Json(ProfileResponse {
        user_id: user.id.to_string(),
        phone: user.phone,
        name: user.name,
        avatar_url: user.avatar_url,
        is_profile_complete: user.is_profile_complete,
        location_enabled: user.location_enabled,
        notify_sos: user.notify_sos,
        notify_broadcast: user.notify_broadcast,
        notify_new_member: user.notify_new_member,
        location_paused_until: user.location_paused_until,
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
        notify_sos: user.notify_sos,
        notify_broadcast: user.notify_broadcast,
        notify_new_member: user.notify_new_member,
        location_paused_until: user.location_paused_until,
        created_at: user.created_at,
    }))
}

// ── DELETE /api/v1/auth/account ────────────────────────────────────────────

pub async fn delete_account(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
) -> Result<Json<serde_json::Value>, AppError> {
    let use_case = DeleteAccountUseCase {
        user_repo: state.user_repo.clone(),
    };
    use_case.execute(&claims.sub).await?;
    Ok(Json(serde_json::json!({ "success": true })))
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

    let mut unique_sessions = Vec::new();
    let mut seen_devices = std::collections::HashSet::new();

    for s in sessions {
        let key = format!(
            "{}:{}",
            s.device_name.to_lowercase(),
            s.platform.to_lowercase()
        );
        if seen_devices.contains(&key) {
            // This is an older duplicate session. Delete it in background to keep DB clean
            let session_repo = state.session_repo.clone();
            let token_hash = s.refresh_token_hash.clone();
            tokio::spawn(async move {
                let _ = session_repo.delete_by_token_hash(&token_hash).await;
            });
        } else {
            seen_devices.insert(key);
            unique_sessions.push(s);
        }
    }

    let resp = unique_sessions
        .into_iter()
        .map(|s| SessionResponse {
            id: s.refresh_token_hash,
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

    let use_case = FirebaseExchangeUseCase {
        user_repo: state.user_repo.clone(),
        session_repo: state.session_repo.clone(),
        config: state.config.clone(),
    };

    let output = use_case
        .execute(&phone, &body.device_name, body.device_model, &body.platform)
        .await?;

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

// ── POST /api/v1/auth/devices ──────────────────────────────────────────────

pub async fn register_device(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<RegisterDeviceRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id: uuid::Uuid = claims
        .sub
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let platform = body.platform.to_lowercase();
    if platform != "ios" && platform != "android" {
        return Err(AppError::InvalidInput(
            "Platform must be 'ios' or 'android'".into(),
        ));
    }

    sqlx::query(
        "INSERT INTO device_tokens (user_id, fcm_token, platform, updated_at)
         VALUES ($1, $2, $3, NOW())
         ON CONFLICT (user_id, platform)
         DO UPDATE SET fcm_token = EXCLUDED.fcm_token, updated_at = NOW()",
    )
    .bind(user_id)
    .bind(body.fcm_token)
    .bind(platform)
    .execute(&state.db_pool)
    .await
    .map_err(|e| AppError::Internal(format!("DB register device error: {}", e)))?;

    Ok(Json(serde_json::json!({
        "success": true,
        "message": "Device token registered successfully"
    })))
}

// ── POST /api/v1/auth/avatar ───────────────────────────────────────────────

pub async fn update_avatar(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    mut multipart: Multipart,
) -> Result<Json<ProfileResponse>, AppError> {
    let mut filename = String::new();
    let mut bytes = Vec::new();

    loop {
        match multipart
            .next_field()
            .await
            .map_err(|e| AppError::InvalidInput(format!("Multipart error: {e}")))?
        {
            None => break,
            Some(field) => {
                if field.name() == Some("avatar") {
                    filename = field.file_name().unwrap_or("avatar.jpg").to_string();
                    bytes = field
                        .bytes()
                        .await
                        .map_err(|e| AppError::InvalidInput(format!("Read error: {e}")))?
                        .to_vec();
                    break;
                }
            }
        }
    }

    if bytes.is_empty() {
        return Err(AppError::InvalidInput(
            "No 'avatar' field in multipart body".into(),
        ));
    }

    let use_case = UpdateAvatarUseCase {
        user_repo: state.user_repo.clone(),
        http_client: state.http_client.clone(),
        aws_access_key_id: state.config.aws_access_key_id.clone(),
        aws_secret_access_key: state.config.aws_secret_access_key.clone(),
        s3_bucket: state.s3_bucket.clone(),
        s3_region: state.s3_region.clone(),
        public_base_url: state.config.invite_base_url.clone(),
    };

    let user = use_case.execute(&claims.sub, &filename, bytes).await?;
    Ok(Json(ProfileResponse {
        user_id: user.id.to_string(),
        phone: user.phone,
        name: user.name,
        avatar_url: user.avatar_url,
        is_profile_complete: user.is_profile_complete,
        location_enabled: user.location_enabled,
        notify_sos: user.notify_sos,
        notify_broadcast: user.notify_broadcast,
        notify_new_member: user.notify_new_member,
        location_paused_until: user.location_paused_until,
        created_at: user.created_at,
    }))
}

// ── POST /api/v1/auth/otp/send ─────────────────────────────────────────────

pub async fn send_otp_handler(
    State(state): State<AppState>,
    Json(body): Json<SendOtpRequest>,
) -> Result<Json<SendOtpResponse>, AppError> {
    let phone = body.phone.trim().to_string();
    if phone.is_empty() {
        return Err(AppError::InvalidInput(
            "Phone number cannot be empty".into(),
        ));
    }

    let sms_service = Arc::new(SendchampSmsService::new(
        state.http_client.clone(),
        state.config.sendchamp_base_url.clone(),
        state.config.sendchamp_api_key.clone(),
        state.config.sendchamp_sender.clone(),
        state.config.sendchamp_route.clone(),
    ));

    let use_case = SendOtpUseCase {
        otp_store: state.otp_store.clone(),
        sms_service,
    };

    use_case.execute(&phone).await?;

    Ok(Json(SendOtpResponse {
        message: "OTP sent successfully".into(),
    }))
}

// ── POST /api/v1/auth/otp/verify ───────────────────────────────────────────

pub async fn verify_otp_handler(
    State(state): State<AppState>,
    Json(body): Json<VerifyOtpRequest>,
) -> Result<Json<AuthResponse>, AppError> {
    let use_case = VerifyOtpUseCase {
        otp_store: state.otp_store.clone(),
        user_repo: state.user_repo.clone(),
        session_repo: state.session_repo.clone(),
        config: state.config.clone(),
    };

    let output = use_case
        .execute(
            body.phone.trim(),
            body.code.trim(),
            &body.device_name,
            body.device_model,
            &body.platform,
        )
        .await?;

    Ok(Json(AuthResponse {
        access_token: output.access_token,
        refresh_token: output.refresh_token,
        user_id: output.user_id,
        phone: output.phone,
        is_profile_complete: output.is_profile_complete,
    }))
}

// ── GET /api/v1/auth/avatar/{user_id} ──────────────────────────────────────
// Public endpoint — proxies the avatar image from private S3 so the bucket
// doesn't need public-read access.

pub async fn serve_avatar(
    State(state): State<AppState>,
    axum::extract::Path(user_id): axum::extract::Path<String>,
) -> Result<axum::response::Response, AppError> {
    use axum::response::IntoResponse;
    use chrono::Utc;
    use hmac::{Hmac, Mac};
    use sha2::{Digest, Sha256};

    type HmacSha256 = Hmac<Sha256>;

    let id: uuid::Uuid = user_id
        .parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id".into()))?;

    // Look up the user to find their stored avatar_url (contains the S3 key)
    let user = state
        .user_repo
        .find_by_id(id)
        .await?
        .ok_or_else(|| AppError::NotFound("User not found".into()))?;
    let avatar_url = user.avatar_url.as_deref().unwrap_or("");

    if avatar_url.is_empty() {
        return Err(AppError::NotFound("No avatar set".into()));
    }

    // Extract the S3 key from the stored URL.
    // Stored format: "https://bucket.s3.region.amazonaws.com/avatars/avatar_UUID.ext"
    // OR the new proxy format: "https://host/api/v1/auth/avatar/UUID" (in which case
    // we derive the key from the user_id and try common extensions).
    let bucket = &state.s3_bucket;
    let region = &state.s3_region;
    let host = format!("{}.s3.{}.amazonaws.com", bucket, region);

    let s3_key = if avatar_url.contains("s3.") || avatar_url.contains("amazonaws.com") {
        // Direct S3 URL — extract key after the host
        avatar_url
            .rsplit_once(".amazonaws.com/")
            .map(|(_, key)| key.to_string())
            .unwrap_or_else(|| format!("avatars/avatar_{}.jpg", id))
    } else {
        // Proxy URL or legacy — derive key
        format!("avatars/avatar_{}.jpg", id)
    };

    // ── AWS SigV4 for GET ──────────────────────────────────────────────────
    let now = Utc::now();
    let amzdate = now.format("%Y%m%dT%H%M%SZ").to_string();
    let datestamp = now.format("%Y%m%d").to_string();
    let service = "s3";

    let payload_hash = "UNSIGNED-PAYLOAD";

    let canonical_headers = format!(
        "host:{}\nx-amz-content-sha256:{}\nx-amz-date:{}\n",
        host, payload_hash, amzdate
    );
    let signed_headers = "host;x-amz-content-sha256;x-amz-date";

    let canonical_request = format!(
        "GET\n/{}\n\n{}\n{}\n{}",
        s3_key, canonical_headers, signed_headers, payload_hash
    );

    let credential_scope = format!("{}/{}/{}/aws4_request", datestamp, region, service);
    let string_to_sign = format!(
        "AWS4-HMAC-SHA256\n{}\n{}\n{}",
        amzdate,
        credential_scope,
        hex::encode(Sha256::digest(canonical_request.as_bytes()))
    );

    // Derive signing key
    fn hmac_sign(key: &[u8], data: &[u8]) -> Vec<u8> {
        let mut mac = HmacSha256::new_from_slice(key).expect("HMAC key");
        mac.update(data);
        mac.finalize().into_bytes().to_vec()
    }

    let key_date = hmac_sign(
        format!("AWS4{}", state.config.aws_secret_access_key).as_bytes(),
        datestamp.as_bytes(),
    );
    let key_region = hmac_sign(&key_date, region.as_bytes());
    let key_service = hmac_sign(&key_region, service.as_bytes());
    let signing_key = hmac_sign(&key_service, b"aws4_request");

    let mut mac = HmacSha256::new_from_slice(&signing_key)
        .map_err(|e| AppError::Internal(format!("HMAC error: {e}")))?;
    mac.update(string_to_sign.as_bytes());
    let signature = hex::encode(mac.finalize().into_bytes());

    let authorization = format!(
        "AWS4-HMAC-SHA256 Credential={}/{}, SignedHeaders={}, Signature={}",
        state.config.aws_access_key_id, credential_scope, signed_headers, signature
    );

    let s3_url = format!("https://{}/{}", host, s3_key);

    let resp = state
        .http_client
        .get(&s3_url)
        .header("x-amz-content-sha256", payload_hash)
        .header("x-amz-date", &amzdate)
        .header("Authorization", &authorization)
        .send()
        .await
        .map_err(|e| AppError::Internal(format!("S3 GET failed: {e}")))?;

    if !resp.status().is_success() {
        return Err(AppError::NotFound("Avatar not found in storage".into()));
    }

    let content_type = resp
        .headers()
        .get("content-type")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("image/jpeg")
        .to_string();

    let bytes = resp
        .bytes()
        .await
        .map_err(|e| AppError::Internal(format!("Failed to read S3 response: {e}")))?;

    Ok((
        [
            (axum::http::header::CONTENT_TYPE, content_type),
            (
                axum::http::header::CACHE_CONTROL,
                "public, max-age=86400".to_string(),
            ),
        ],
        bytes,
    )
        .into_response())
}
