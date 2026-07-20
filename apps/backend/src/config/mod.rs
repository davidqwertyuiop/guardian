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
    // ── Sendchamp ────────────────────────────────────────────────
    pub sendchamp_api_key: String,
    pub sendchamp_base_url: String,
    pub sendchamp_sender: String,
    pub sendchamp_route: String,
    // ── AWS S3 ──────────────────────────────────────────────────
    pub aws_access_key_id: String,
    pub aws_secret_access_key: String,
    pub aws_region: String,
    pub aws_s3_bucket: String,
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

        let sendchamp_api_key =
            std::env::var("SENDCHAMP_API_KEY").expect("SENDCHAMP_API_KEY must be set");

        let sendchamp_base_url = std::env::var("SENDCHAMP_BASE_URL")
            .unwrap_or_else(|_| "https://api.sendchamp.com/api/v1".to_string());

        let sendchamp_sender =
            std::env::var("SENDCHAMP_SENDER").unwrap_or_else(|_| "Guardian".to_string());

        let sendchamp_route =
            std::env::var("SENDCHAMP_ROUTE").unwrap_or_else(|_| "dnd".to_string());

        let aws_access_key_id =
            std::env::var("AWS_ACCESS_KEY_ID").expect("AWS_ACCESS_KEY_ID must be set");

        let aws_secret_access_key =
            std::env::var("AWS_SECRET_ACCESS_KEY").expect("AWS_SECRET_ACCESS_KEY must be set");

        let aws_region = std::env::var("AWS_REGION").unwrap_or_else(|_| "us-west-1".to_string());

        let aws_s3_bucket = std::env::var("AWS_S3_BUCKET").expect("AWS_S3_BUCKET must be set");

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
            sendchamp_api_key,
            sendchamp_base_url,
            sendchamp_sender,
            sendchamp_route,
            aws_access_key_id,
            aws_secret_access_key,
            aws_region,
            aws_s3_bucket,
        }
    }
}
