use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Deserialize)]
pub struct StartJourneyRequest {
    pub circle_id: Uuid,
    pub destination: String,
    pub duration: String,
}

#[derive(Debug, Deserialize)]
pub struct StayJourneyRequest {
    pub circle_id: Uuid,
}
