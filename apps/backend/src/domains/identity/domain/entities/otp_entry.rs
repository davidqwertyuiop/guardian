/// An OTP entry held in memory while waiting for verification.
#[derive(Debug, Clone)]
pub struct OtpEntry {
    pub phone: String,
    pub code: String,
    pub created_at_secs: u64,
    pub attempts: u8,
}
