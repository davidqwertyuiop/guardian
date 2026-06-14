use axum::{
    body::Body,
    http::Request,
    middleware::Next,
    response::Response,
};
use std::sync::Arc;
use dashmap::DashMap;
use std::time::{SystemTime, UNIX_EPOCH};
use crate::shared::errors::AppError;

pub struct RateLimiter {
    // Maps IP/Identifier to list of request timestamps
    requests: DashMap<String, Vec<u64>>,
}

impl RateLimiter {
    pub fn new() -> Self {
        Self {
            requests: DashMap::new(),
        }
    }

    pub fn check_rate_limit(&self, key: &str, limit: usize, window_secs: u64) -> Result<(), AppError> {
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs();

        let mut timestamps = self.requests.entry(key.to_string()).or_insert_with(Vec::new);
        
        // Remove timestamps outside window
        timestamps.retain(|&t| now - t < window_secs);

        if timestamps.len() >= limit {
            let oldest = timestamps.first().cloned().unwrap_or(now);
            let wait_secs = window_secs - (now - oldest);
            return Err(AppError::RateLimit(wait_secs));
        }

        timestamps.push(now);
        Ok(())
    }
}
