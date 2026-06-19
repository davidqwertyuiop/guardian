use std::sync::Arc;
use axum::Router;
use sqlx::PgPool;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

use crate::config::AppConfig;
use crate::routes::{AppState, create_router};
use crate::domains::identity::infrastructure::{
    postgres_user_repo::PostgresUserRepository,
    in_memory_otp_repo::InMemoryOtpRepository,
    sms_gateway::MockSmsGateway,
};

/// Wires together the application: config, repos, gateways → Router.
/// Called once during app startup in main.rs.
pub async fn build_router(pool: PgPool, config: AppConfig) -> Router {
    let user_repo = Arc::new(PostgresUserRepository { pool: pool.clone() });
    let otp_repo  = Arc::new(InMemoryOtpRepository::new());
    let sms_gw    = Arc::new(MockSmsGateway);

    let state = AppState {
        config,
        db_pool: pool,
        user_repo,
        otp_repo,
        sms_gateway: sms_gw,
    };

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    create_router(state)
        .layer(TraceLayer::new_for_http())
        .layer(cors)
}
