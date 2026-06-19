/// Permission roles for Guardian.
/// Expanded as features are added.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Role {
    User,
    CircleAdmin,
    SupportAgent,
    PlatformAdmin,
}
