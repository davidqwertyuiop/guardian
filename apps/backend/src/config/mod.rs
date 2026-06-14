use std::env;

#[derive(Clone, Debug)]
pub struct AppConfig {
    pub server_host: String,
    pub server_port: u16,
    pub jwt_secret: String,
    pub otp_ttl_seconds: u64,
    pub rate_limit_window_seconds: u64,
}

impl AppConfig {
    pub fn from_env() -> Self {
        let _ = dotenvy::dotenv();

        let server_host = env::var("SERVER_HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
        let server_port = env::var("SERVER_PORT")
            .ok()
            .and_then(|p| p.parse().ok())
            .unwrap_or(8080);
        let jwt_secret = env::var("JWT_SECRET").unwrap_or_else(|_| "your-super-secret-key-change-me-in-production".to_string());
        let otp_ttl_seconds = env::var("OTP_TTL_SECONDS")
            .ok()
            .and_then(|t| t.parse().ok())
            .unwrap_or(300);
        let rate_limit_window_seconds = env::var("RATE_LIMIT_WINDOW_SECONDS")
            .ok()
            .and_then(|w| w.parse().ok())
            .unwrap_or(60);

        Self {
            server_host,
            server_port,
            jwt_secret,
            otp_ttl_seconds,
            rate_limit_window_seconds,
        }
    }
}
