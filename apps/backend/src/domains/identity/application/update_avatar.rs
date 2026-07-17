use crate::domains::identity::domain::{
    entities::user::User, repositories::user_repository::UserRepository,
};
use crate::shared::errors::AppError;
use chrono::Utc;
use hmac::{Hmac, Mac};
use reqwest::Client;
use sha2::{Digest, Sha256};
use std::sync::Arc;
use uuid::Uuid;

type HmacSha256 = Hmac<Sha256>;

pub struct UpdateAvatarUseCase {
    pub user_repo: Arc<dyn UserRepository>,
    pub http_client: Arc<Client>,
    /// AWS access key id
    pub aws_access_key_id: String,
    /// AWS secret access key
    pub aws_secret_access_key: String,
    /// e.g. "us-west-1"
    pub s3_region: String,
    /// e.g. "guardian-123"
    pub s3_bucket: String,
    /// e.g. "https://guardian.shadowchat.xyz" — used to build the proxy URL
    pub public_base_url: String,
}

impl UpdateAvatarUseCase {
    pub async fn execute(
        &self,
        user_id_str: &str,
        filename: &str,
        bytes: Vec<u8>,
    ) -> Result<User, AppError> {
        if bytes.is_empty() {
            return Err(AppError::InvalidInput("Avatar file is empty".into()));
        }
        if bytes.len() > 10 * 1024 * 1024 {
            return Err(AppError::InvalidInput(
                "Avatar must be smaller than 5 MB".into(),
            ));
        }

        let ext = Self::safe_ext(filename)?;
        let id: Uuid = user_id_str
            .parse()
            .map_err(|_| AppError::InvalidInput("Invalid user id".into()))?;

        let content_type = match ext {
            "jpg" => "image/jpeg",
            "png" => "image/png",
            "webp" => "image/webp",
            _ => "application/octet-stream",
        };

        // We MUST save the file as .jpg (or just a fixed key) regardless of the actual format
        // because the `serve_avatar` proxy route unconditionally looks up `avatar_{id}.jpg`.
        // The actual image format is determined by the Content-Type header which we set correctly below.
        let s3_key = format!("avatars/avatar_{id}.jpg");
        let host = format!("{}.s3.{}.amazonaws.com", self.s3_bucket, self.s3_region);
        let url = format!("https://{}/{}", host, s3_key);

        // ── AWS Signature V4 ──────────────────────────────────────────────────
        let now = Utc::now();
        let amzdate = now.format("%Y%m%dT%H%M%SZ").to_string();
        let datestamp = now.format("%Y%m%d").to_string();
        let service = "s3";

        // Payload hash
        let payload_hash = hex::encode(Sha256::digest(&bytes));

        // Canonical headers (must be sorted alphabetically by header name)
        let canonical_headers = format!(
            "content-type:{}\nhost:{}\nx-amz-content-sha256:{}\nx-amz-date:{}\n",
            content_type, host, payload_hash, amzdate
        );
        let signed_headers = "content-type;host;x-amz-content-sha256;x-amz-date";

        let canonical_request = format!(
            "PUT\n/{}\n\n{}\n{}\n{}",
            s3_key, canonical_headers, signed_headers, payload_hash
        );

        // String to sign
        let credential_scope = format!("{}/{}/{}/aws4_request", datestamp, self.s3_region, service);
        let string_to_sign = format!(
            "AWS4-HMAC-SHA256\n{}\n{}\n{}",
            amzdate,
            credential_scope,
            hex::encode(Sha256::digest(canonical_request.as_bytes()))
        );

        // Signing key
        let signing_key = Self::derive_signing_key(
            &self.aws_secret_access_key,
            &datestamp,
            &self.s3_region,
            service,
        )?;

        let mut mac = HmacSha256::new_from_slice(&signing_key)
            .map_err(|e| AppError::Internal(format!("HMAC error: {e}")))?;
        mac.update(string_to_sign.as_bytes());
        let signature = hex::encode(mac.finalize().into_bytes());

        let authorization = format!(
            "AWS4-HMAC-SHA256 Credential={}/{}, SignedHeaders={}, Signature={}",
            self.aws_access_key_id, credential_scope, signed_headers, signature
        );

        // ── Upload via reqwest ────────────────────────────────────────────────
        let resp = self
            .http_client
            .put(&url)
            .header("Content-Type", content_type)
            .header("x-amz-content-sha256", &payload_hash)
            .header("x-amz-date", &amzdate)
            .header("Authorization", &authorization)
            .body(bytes)
            .send()
            .await
            .map_err(|e| AppError::Internal(format!("S3 PUT request failed: {e}")))?;

        if !resp.status().is_success() {
            let status = resp.status();
            let body = resp.text().await.unwrap_or_default();
            return Err(AppError::Internal(format!(
                "S3 upload failed ({status}): {body}"
            )));
        }

        // Store the proxy URL so the mobile app fetches through our backend
        // (the S3 bucket is private — no public-read needed).
        // Strip any path suffix from public_base_url to get just the origin
        // e.g. "https://guardian.shadowchat.xyz/invite" → "https://guardian.shadowchat.xyz"
        let origin = {
            let url = &self.public_base_url;
            if let Some(parsed) = url.split("://").nth(1) {
                let host = parsed.split('/').next().unwrap_or(parsed);
                let scheme = url.split("://").next().unwrap_or("https");
                format!("{}://{}", scheme, host)
            } else {
                url.clone()
            }
        };
        let timestamp = Utc::now().timestamp();
        let proxy_url = format!("{}/api/v1/auth/avatar/{}?v={}", origin, id, timestamp);
        let user = self.user_repo.update_avatar_url(id, &proxy_url).await?;
        Ok(user)
    }

    fn derive_signing_key(
        secret: &str,
        datestamp: &str,
        region: &str,
        service: &str,
    ) -> Result<Vec<u8>, AppError> {
        let key_date = Self::hmac_sign(format!("AWS4{}", secret).as_bytes(), datestamp.as_bytes())?;
        let key_region = Self::hmac_sign(&key_date, region.as_bytes())?;
        let key_service = Self::hmac_sign(&key_region, service.as_bytes())?;
        let key_signing = Self::hmac_sign(&key_service, b"aws4_request")?;
        Ok(key_signing)
    }

    fn hmac_sign(key: &[u8], data: &[u8]) -> Result<Vec<u8>, AppError> {
        let mut mac = HmacSha256::new_from_slice(key)
            .map_err(|e| AppError::Internal(format!("HMAC key error: {e}")))?;
        mac.update(data);
        Ok(mac.finalize().into_bytes().to_vec())
    }

    fn safe_ext(filename: &str) -> Result<&'static str, AppError> {
        let lower = filename.to_lowercase();
        if lower.ends_with(".jpg") || lower.ends_with(".jpeg") {
            Ok("jpg")
        } else if lower.ends_with(".png") {
            Ok("png")
        } else if lower.ends_with(".webp") {
            Ok("webp")
        } else {
            Err(AppError::InvalidInput(
                "Only jpg, png, or webp avatars are accepted".into(),
            ))
        }
    }
}
