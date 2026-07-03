/// Application configuration, loaded from environment variables (local `.env` or production env).
#[derive(Clone, Debug)]
pub struct AppConfig {
    pub jwt_secret: String,
    pub jwt_refresh_secret: String,
    pub rate_limit_window_seconds: u64,
    pub invite_base_url: String,
    pub apple_team_id: String,
    pub android_sha256_cert_fingerprint: String,
}

impl AppConfig {
    /// Build config from environment variables.
    pub fn from_env() -> Self {
        let jwt_secret = std::env::var("JWT_SECRET")
            .expect("JWT_SECRET must be set");

        let jwt_refresh_secret = std::env::var("JWT_REFRESH_SECRET")
            .expect("JWT_REFRESH_SECRET must be set");

        let rate_limit_window_seconds = std::env::var("RATE_LIMIT_WINDOW_SECONDS")
            .ok()
            .and_then(|v| v.parse().ok())
            .unwrap_or(60);
            
        let invite_base_url = std::env::var("INVITE_BASE_URL")
            .unwrap_or_else(|_| "https://guardian.shadowchat.xyz/invite".to_string());

        let apple_team_id = std::env::var("APPLE_TEAM_ID")
            .unwrap_or_else(|_| "5NWP5R6G3P".to_string());

        let android_sha256_cert_fingerprint = std::env::var("ANDROID_SHA256_CERT_FINGERPRINT")
            .unwrap_or_else(|_| "8c:38:8b:fa:70:43:87:5d:7b:7a:f6:85:8d:49:d8:41:09:7b:23:0b:b0:0f:94:26:fb:07:cb:5d:09:5f:d0:98".to_string());

        Self {
            jwt_secret,
            jwt_refresh_secret,
            rate_limit_window_seconds,
            invite_base_url,
            apple_team_id,
            android_sha256_cert_fingerprint,
        }
    }
}
