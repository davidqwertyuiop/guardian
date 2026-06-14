use crate::shared::errors::AppError;

pub fn validate_phone(phone: &str) -> Result<(), AppError> {
    let cleaned = phone.trim();
    if cleaned.is_empty() {
        return Err(AppError::InvalidInput("Phone number cannot be empty".to_string()));
    }
    if !cleaned.starts_with('+') {
        return Err(AppError::InvalidInput("Phone number must include country dial code (e.g. +234)".to_string()));
    }
    Ok(())
}
