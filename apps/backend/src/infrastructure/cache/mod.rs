use redis::Client;

pub fn establish_redis_connection(redis_url: &str) -> Result<Client, redis::RedisError> {
    Client::open(redis_url)
}
