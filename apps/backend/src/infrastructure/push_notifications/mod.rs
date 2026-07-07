use chrono::Utc;
use jsonwebtoken::{EncodingKey, Header};
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct ServiceAccount {
    project_id: String,
    private_key: String,
    client_email: String,
}

#[derive(Serialize)]
struct GoogleClaims {
    iss: String,
    sub: String,
    scope: String,
    aud: String,
    iat: i64,
    exp: i64,
}

#[derive(Deserialize)]
struct TokenResponse {
    access_token: String,
}

/// Helper to request an OAuth2 access token for Google API calls.
async fn get_google_access_token(
    sa: &ServiceAccount,
) -> Result<String, Box<dyn std::error::Error>> {
    let now = Utc::now().timestamp();
    let claims = GoogleClaims {
        iss: sa.client_email.clone(),
        sub: sa.client_email.clone(),
        scope: "https://www.googleapis.com/auth/firebase.messaging".to_string(),
        aud: "https://oauth2.googleapis.com/token".to_string(),
        iat: now,
        exp: now + 3600,
    };

    let encoding_key = EncodingKey::from_rsa_pem(sa.private_key.as_bytes())?;
    let mut header = Header::new(jsonwebtoken::Algorithm::RS256);
    header.kid = None; // Google OAuth doesn't strictly need kid here

    let assertion = jsonwebtoken::encode(&header, &claims, &encoding_key)?;

    let client = reqwest::Client::new();
    let body = format!(
        "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion={}",
        assertion
    );
    let res = client
        .post("https://oauth2.googleapis.com/token")
        .header("content-type", "application/x-www-form-urlencoded")
        .body(body)
        .send()
        .await?
        .json::<TokenResponse>()
        .await?;

    Ok(res.access_token)
}

/// Send a push notification via Firebase Cloud Messaging (FCM) HTTP v1 API.
/// In production, the service account JSON must be injected through
/// `FIREBASE_SERVICE_ACCOUNT_JSON` or `FCM_SERVICE_ACCOUNT_JSON`.
pub async fn send_push_notification(token: &str, title: &str, body: &str) {
    let sa = match load_service_account() {
        Some(s) => s,
        None => {
            tracing::warn!(
                "[FCM MOCK] (No service account found) Dispatching notification to: \"{}\". Title: \"{}\", Body: \"{}\"",
                token,
                title,
                body
            );
            return;
        }
    };

    // 2. Fetch Google OAuth2 Access Token
    let access_token = match get_google_access_token(&sa).await {
        Ok(t) => t,
        Err(e) => {
            tracing::error!("[FCM ERROR] Failed to fetch Google Access Token: {:?}", e);
            return;
        }
    };

    // 3. Construct and dispatch FCM v1 request
    let url = format!(
        "https://fcm.googleapis.com/v1/projects/{}/messages:send",
        sa.project_id
    );

    let payload = serde_json::json!({
        "message": {
            "token": token,
            "notification": {
                "title": title,
                "body": body
            },
            "data": {
                "title": title,
                "body": body,
                "click_action": "FLUTTER_NOTIFICATION_CLICK"
            },
            "android": {
                "priority": "high",
                "notification": {
                    "sound": "default",
                    "channel_id": "guardian_sos"
                }
            },
            "apns": {
                "headers": {
                    "apns-priority": "10"
                },
                "payload": {
                    "aps": {
                        "alert": {
                            "title": title,
                            "body": body
                        },
                        "sound": "default",
                        "badge": 1
                    }
                }
            }
        }
    });

    let client = reqwest::Client::new();
    match client
        .post(&url)
        .bearer_auth(access_token)
        .json(&payload)
        .send()
        .await
    {
        Ok(res) => {
            if res.status().is_success() {
                tracing::info!("[FCM SUCCESS] Sent push notification to token {}", token);
            } else {
                let err_text = res.text().await.unwrap_or_default();
                tracing::error!(
                    "[FCM ERROR] Google returned failure ({}): {}",
                    url,
                    err_text
                );
            }
        }
        Err(e) => {
            tracing::error!(
                "[FCM ERROR] Network error while sending push notification: {:?}",
                e
            );
        }
    }
}

fn load_service_account() -> Option<ServiceAccount> {
    std::env::var("FIREBASE_SERVICE_ACCOUNT_JSON")
        .or_else(|_| std::env::var("FCM_SERVICE_ACCOUNT_JSON"))
        .ok()
        .and_then(|content| parse_service_account(&content))
        .or_else(load_local_service_account)
}

fn parse_service_account(content: &str) -> Option<ServiceAccount> {
    serde_json::from_str::<ServiceAccount>(content).ok()
}

#[cfg(debug_assertions)]
fn load_local_service_account() -> Option<ServiceAccount> {
    let paths_to_try = [
        "firebase-service-account.json",
        "apps/backend/firebase-service-account.json",
    ];

    paths_to_try.iter().find_map(|path| {
        std::fs::read_to_string(path)
            .ok()
            .and_then(|content| parse_service_account(&content))
    })
}

#[cfg(not(debug_assertions))]
fn load_local_service_account() -> Option<ServiceAccount> {
    None
}

#[cfg(test)]
mod tests {
    use super::parse_service_account;

    #[test]
    fn parses_service_account_json() {
        let content = r#"{
            "project_id": "guardian-test",
            "private_key": "-----BEGIN PRIVATE KEY-----\nabc\n-----END PRIVATE KEY-----\n",
            "client_email": "firebase@guardian-test.iam.gserviceaccount.com"
        }"#;

        let account = parse_service_account(content).expect("valid service account");

        assert_eq!(account.project_id, "guardian-test");
        assert_eq!(
            account.client_email,
            "firebase@guardian-test.iam.gserviceaccount.com"
        );
        assert!(account.private_key.contains("BEGIN PRIVATE KEY"));
    }

    #[test]
    fn rejects_invalid_service_account_json() {
        assert!(parse_service_account("{\"project_id\":\"missing fields\"}").is_none());
    }
}
