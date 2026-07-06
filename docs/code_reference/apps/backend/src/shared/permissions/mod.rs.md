# mod.rs

* **File Path:** `apps/backend/src/shared/permissions/mod.rs`
* **Type:** `RUST`

---

```rust
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Permission {
    FamilyRead,
    FamilyWrite,
    LocationShare,
    JourneyManage,
}

```
