mod bootstrap;
mod config;
mod domains;
mod infrastructure;
mod routes;
mod shared;
mod websocket;
mod workers;

use sqlx::postgres::PgPoolOptions;
use std::net::SocketAddr;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

/// Guardian Backend v2
/// Hosted on Render via Docker.
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Load local .env file if present
    dotenvy::dotenv().ok();

    // Initialize telemetry/tracing
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "guardian_backend=info,tower_http=info,axum=info".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("🚀 Starting Guardian Backend v2 (Docker/Render)...");

    // Load AppConfig
    let config = config::AppConfig::from_env();
    tracing::info!("✅ Configuration loaded");

    // Database connection
    let db_url = std::env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set in environment or .env file");

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await?;

    tracing::info!("✅ Connected to Postgres database");

    // Run pending migrations
    sqlx::migrate!("./migrations").run(&pool).await?;

    tracing::info!("✅ Database migrations applied successfully");

    // Build the Router
    let router = bootstrap::build_router(pool, config).await;

    // Get the binding port
    let port = std::env::var("PORT")
        .ok()
        .and_then(|p| p.parse::<u16>().ok())
        .unwrap_or(8000);

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    tracing::info!("📡 Listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, router).await?;

    Ok(())
}
