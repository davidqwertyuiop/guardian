// Place shared traits here
pub trait Repository<T> {
    fn find_by_id(&self, id: &str) -> Option<T>;
}
