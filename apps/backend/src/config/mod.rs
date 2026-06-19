/// Application configuration, loaded from environment variables (local `.env` or production env).
#[derive(Clone, Debug)]
pub struct AppConfig {
    pub jwt_secret: String,
    pub jwt_refresh_secret: String,
    pub otp_ttl_seconds: u64,
    pub rate_limit_window_seconds: u64,
}

impl AppConfig {
    /// Build config from environment variables.
    pub fn from_env() -> Self {
        let jwt_secret = std::env::var("JWT_SECRET")
            .expect("JWT_SECRET must be set");

        let jwt_refresh_secret = std::env::var("JWT_REFRESH_SECRET")
            .expect("JWT_REFRESH_SECRET must be set");

        let otp_ttl_seconds = std::env::var("OTP_TTL_SECONDS")
            .ok()
            .and_then(|v| v.parse().ok())
            .unwrap_or(300);

        let rate_limit_window_seconds = std::env::var("RATE_LIMIT_WINDOW_SECONDS")
            .ok()
            .and_then(|v| v.parse().ok())
            .unwrap_or(60);

        Self {
            jwt_secret,
            jwt_refresh_secret,
            otp_ttl_seconds,
            rate_limit_window_seconds,
        }
    }
}
