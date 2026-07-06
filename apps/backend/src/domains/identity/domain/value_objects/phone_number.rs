use crate::shared::errors::AppError;

/// A validated E.164 phone number value object.
/// Ensures phone is non-empty and starts with '+'.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PhoneNumber(String);

impl PhoneNumber {
    pub fn parse(raw: &str) -> Result<Self, AppError> {
        let trimmed = raw.trim();
        if trimmed.is_empty() {
            return Err(AppError::InvalidInput(
                "Phone number cannot be empty".to_string(),
            ));
        }
        if !trimmed.starts_with('+') {
            return Err(AppError::InvalidInput(
                "Phone number must be in E.164 format (e.g. +2348012345678)".to_string(),
            ));
        }
        if trimmed.len() < 8 || trimmed.len() > 16 {
            return Err(AppError::InvalidInput(
                "Phone number must be between 7 and 15 digits".to_string(),
            ));
        }
        Ok(Self(trimmed.to_string()))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl std::fmt::Display for PhoneNumber {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}
