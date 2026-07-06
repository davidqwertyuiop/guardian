# mod.rs

* **File Path:** `apps/backend/src/shared/traits/mod.rs`
* **Type:** `RUST`

---

```rust
// Place shared traits here
pub trait Repository<T> {
    fn find_by_id(&self, id: &str) -> Option<T>;
}

```
