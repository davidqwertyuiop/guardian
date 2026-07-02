use axum::Router;
use sqlx::PgPool;
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

use crate::config::AppConfig;
use crate::domains::circles::infrastructure::{
    postgres_circle_repo::PostgresCircleRepository, postgres_invite_repo::PostgresInviteRepository,
};
use crate::domains::identity::infrastructure::{
    in_memory_otp_repo::InMemoryOtpRepository,
    postgres_session_repo::PostgresSessionRepository,
    postgres_user_repo::PostgresUserRepository,
    sms_gateway::{InfobipSmsGateway, MockSmsGateway, SmsGateway},
};
use crate::routes::{create_router, AppState};

/// Wires together the application: config, repos, gateways → Router.
pub async fn build_router(pool: PgPool, config: AppConfig) -> Router {
    let user_repo = Arc::new(PostgresUserRepository { pool: pool.clone() });
    let session_repo = Arc::new(PostgresSessionRepository { pool: pool.clone() });
    let otp_repo = Arc::new(InMemoryOtpRepository::new());
    let circle_repo = Arc::new(PostgresCircleRepository { pool: pool.clone() });
    let invite_repo = Arc::new(PostgresInviteRepository { pool: pool.clone() });

    // ── SMS Gateway ────────────────────────────────────────────────────────────
    // When all five INFOBIP_* env vars are present → use Infobip 2FA gateway.
    // Otherwise fall back to MockSmsGateway (OTP is logged to the server console).
    let sms_gw: Arc<dyn SmsGateway> = {
        let api_key = std::env::var("INFOBIP_API_KEY").ok();
        let base_url = std::env::var("INFOBIP_BASE_URL").ok();
        let application_id = std::env::var("INFOBIP_APPLICATION_ID").ok();
        let message_id = std::env::var("INFOBIP_MESSAGE_ID").ok();
        let sender = std::env::var("INFOBIP_SENDER").ok();

        match (api_key, base_url, application_id, message_id, sender) {
            (Some(key), Some(url), Some(app_id), Some(msg_id), Some(sndr)) => {
                tracing::info!("📱 SMS: Infobip 2FA gateway active (base: {})", url);
                Arc::new(InfobipSmsGateway::new(key, url, app_id, msg_id, sndr))
            }
            _ => {
                tracing::warn!(
                    "⚠️  SMS: INFOBIP_* env vars not fully set — using MockSmsGateway (OTP logged to console)"
                );
                Arc::new(MockSmsGateway)
            }
        }
    };
    // ──────────────────────────────────────────────────────────────────────────

    let state = AppState {
        config,
        db_pool: pool,
        user_repo,
        session_repo,
        otp_repo,
        sms_gateway: sms_gw,
        circle_repo,
        invite_repo,
    };

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    create_router(state)
        .layer(TraceLayer::new_for_http())
        .layer(cors)
}
