use rand::Rng;
use std::collections::HashMap;
use std::time::{Duration, Instant};
use tokio::sync::Mutex;

const OTP_TTL: Duration = Duration::from_secs(300); // 5 minutes

struct Entry {
    code: String,
    expires_at: Instant,
}

/// Thread-safe in-memory OTP store with a 5-minute TTL per entry.
pub struct OtpStore {
    map: Mutex<HashMap<String, Entry>>,
}

impl OtpStore {
    pub fn new() -> Self {
        Self {
            map: Mutex::new(HashMap::new()),
        }
    }

    /// Generate and store a 6-digit OTP for the given phone number.
    /// Any previous code for this phone is overwritten.
    pub async fn generate(&self, phone: &str) -> String {
        let code = format!("{:06}", rand::thread_rng().gen_range(0..=999999u32));
        let mut map = self.map.lock().await;
        map.insert(
            phone.to_string(),
            Entry {
                code: code.clone(),
                expires_at: Instant::now() + OTP_TTL,
            },
        );
        code
    }

    /// Verify the OTP for the given phone.
    /// Returns `true` (and removes the entry) on success, `false` otherwise.
    pub async fn verify(&self, phone: &str, code: &str) -> bool {
        let mut map = self.map.lock().await;
        if let Some(entry) = map.get(phone) {
            if entry.code == code && Instant::now() < entry.expires_at {
                map.remove(phone);
                return true;
            }
        }
        false
    }
}

impl Default for OtpStore {
    fn default() -> Self {
        Self::new()
    }
}
