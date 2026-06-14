mod config;
mod routes;
mod shared;
mod infrastructure;
mod modules;

use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

use crate::config::AppConfig;
use crate::routes::AppState;
use crate::modules::auth::services::otp::OtpStore;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "guardian_backend=info,tower_http=debug".into()),
        )
        .init();

    let config = AppConfig::from_env();
    tracing::info!("🔧 Loaded configuration: {:?}", config);

    let otp_store = Arc::new(OtpStore::new());

    let state = AppState {
        config: config.clone(),
        otp_store,
    };

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let app = routes::create_router(state)
        .layer(TraceLayer::new_for_http())
        .layer(cors);

    let addr = format!("{}:{}", config.server_host, config.server_port);
    let listener = match tokio::net::TcpListener::bind(&addr).await {
        Ok(l) => l,
        Err(e) => {
            tracing::error!("❌ Failed to bind to {}: {}", addr, e);
            std::process::exit(1);
        }
    };

    tracing::info!("🚀 Guardian Backend running on http://{}", addr);

    if let Err(e) = axum::serve(listener, app).await {
        tracing::error!("❌ Server error: {}", e);
    }
}
