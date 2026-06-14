#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Permission {
    FamilyRead,
    FamilyWrite,
    LocationShare,
    JourneyManage,
}
