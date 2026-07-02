/// An OTP session held in memory while waiting for verification.
/// For Infobip 2FA: `session_token` is the `pinId` returned by /2fa/2/pin.
/// For MockSmsGateway: `session_token` is the code itself.
#[derive(Debug, Clone)]
pub struct OtpEntry {
    pub phone:            String,
    pub session_token:    String,   // Infobip pinId, or the code itself for mock
    pub created_at_secs:  u64,
    pub attempts:         u8,
}
