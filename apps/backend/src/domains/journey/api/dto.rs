use serde::Deserialize;
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

#[derive(Debug, Deserialize)]
pub struct StopJourneyRequest {
    pub circle_id: Uuid,
    pub arrived: Option<bool>,
    pub last_seen_address: Option<String>,
}
