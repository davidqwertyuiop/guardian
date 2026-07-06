/// Application configuration, loaded from environment variables (local `.env` or production env).
#[derive(Clone, Debug)]
pub struct AppConfig {
    pub jwt_secret: String,
    pub jwt_refresh_secret: String,
    pub rate_limit_window_seconds: u64,
    pub invite_base_url: String,
    pub apple_team_id: String,
    pub android_sha256_cert_fingerprint: String,
    pub app_store_link: String,
    pub play_store_link: String,
    pub maps_api_key_android: String,
    pub maps_api_key_ios: String,
}

impl AppConfig {
    /// Build config from environment variables.
    pub fn from_env() -> Self {
        let jwt_secret = std::env::var("JWT_SECRET").expect("JWT_SECRET must be set");

        let jwt_refresh_secret =
            std::env::var("JWT_REFRESH_SECRET").expect("JWT_REFRESH_SECRET must be set");

        let rate_limit_window_seconds = std::env::var("RATE_LIMIT_WINDOW_SECONDS")
            .ok()
            .and_then(|v| v.parse().ok())
            .unwrap_or(60);

        let invite_base_url =
            std::env::var("INVITE_BASE_URL").expect("INVITE_BASE_URL must be set");

        let apple_team_id = std::env::var("APPLE_TEAM_ID").expect("APPLE_TEAM_ID must be set");

        let android_sha256_cert_fingerprint = std::env::var("ANDROID_SHA256_CERT_FINGERPRINT")
            .expect("ANDROID_SHA256_CERT_FINGERPRINT must be set");

        let app_store_link = std::env::var("APP_STORE_LINK").expect("APP_STORE_LINK must be set");

        let play_store_link =
            std::env::var("PLAY_STORE_LINK").expect("PLAY_STORE_LINK must be set");

        let maps_api_key_android = std::env::var("MAPS_API_KEY_ANDROID")
            .unwrap_or_else(|_| "AIzaSyCrE5sgJcL8HmahdId4k2vbYtzrtDJCl2Q".to_string());

        let maps_api_key_ios = std::env::var("MAPS_API_KEY_IOS")
            .unwrap_or_else(|_| "AIzaSyCHPSzdW1BqZR725BOBC7EeQbYZZ4JBtQs".to_string());

        Self {
            jwt_secret,
            jwt_refresh_secret,
            rate_limit_window_seconds,
            invite_base_url,
            apple_team_id,
            android_sha256_cert_fingerprint,
            app_store_link,
            play_store_link,
            maps_api_key_android,
            maps_api_key_ios,
        }
    }
}
