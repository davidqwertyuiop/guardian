use std::sync::Arc;
use axum::Router;
use sqlx::PgPool;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

use crate::config::AppConfig;
use crate::routes::{AppState, create_router};
use crate::domains::identity::infrastructure::{
    postgres_user_repo::PostgresUserRepository,
    postgres_session_repo::PostgresSessionRepository,
    in_memory_otp_repo::InMemoryOtpRepository,
};
use crate::domains::circles::infrastructure::{
    postgres_circle_repo::PostgresCircleRepository,
    postgres_invite_repo::PostgresInviteRepository,
};

/// Wires together the application: config, repos, gateways → Router.
/// Called once during app startup in main.rs.
pub async fn build_router(pool: PgPool, config: AppConfig) -> Router {
    let user_repo = Arc::new(PostgresUserRepository { pool: pool.clone() });
    let session_repo = Arc::new(PostgresSessionRepository { pool: pool.clone() });
    let otp_repo  = Arc::new(InMemoryOtpRepository::new());
    let circle_repo = Arc::new(PostgresCircleRepository { pool: pool.clone() });
    let invite_repo = Arc::new(PostgresInviteRepository { pool: pool.clone() });

    // Load AWS config from env vars
    let aws_config = aws_config::load_defaults(aws_config::BehaviorVersion::latest()).await;
    let aws_client = aws_sdk_sns::Client::new(&aws_config);
    let sms_gw    = Arc::new(crate::domains::identity::infrastructure::sms_gateway::AwsSmsGateway::new(aws_client));

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
