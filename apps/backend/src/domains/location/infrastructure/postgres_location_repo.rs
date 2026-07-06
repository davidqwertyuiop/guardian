use crate::domains::location::domain::{
    entities::member_location::{MemberLocation, MemberLocationWithProfile},
    repositories::location_repository::LocationRepository,
};
use crate::shared::errors::AppError;
use async_trait::async_trait;
use sqlx::PgPool;
use uuid::Uuid;

pub struct PostgresLocationRepository {
    pub pool: PgPool,
}

#[async_trait]
impl LocationRepository for PostgresLocationRepository {
    /// Upsert the user's live GPS fix into member_locations for the given circle.
    /// Uses ON CONFLICT to update in-place so there is always at most one row
    /// per (user_id, circle_id) pair, keeping the table lean.
    async fn upsert(
        &self,
        user_id: Uuid,
        circle_id: Uuid,
        latitude: f64,
        longitude: f64,
        accuracy: Option<f32>,
        heading: Option<f32>,
        speed: Option<f32>,
    ) -> Result<MemberLocation, AppError> {
        sqlx::query_as::<_, MemberLocation>(
            r#"
            INSERT INTO member_locations
                (user_id, circle_id, latitude, longitude, accuracy, heading, speed, recorded_at, updated_at)
            VALUES
                ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
            ON CONFLICT (user_id, circle_id) DO UPDATE
                SET latitude    = EXCLUDED.latitude,
                    longitude   = EXCLUDED.longitude,
                    accuracy    = EXCLUDED.accuracy,
                    heading     = EXCLUDED.heading,
                    speed       = EXCLUDED.speed,
                    recorded_at = EXCLUDED.recorded_at,
                    updated_at  = NOW()
            RETURNING id, user_id, circle_id, latitude, longitude,
                      accuracy, heading, speed, recorded_at, updated_at
            "#,
        )
        .bind(user_id)
        .bind(circle_id)
        .bind(latitude)
        .bind(longitude)
        .bind(accuracy)
        .bind(heading)
        .bind(speed)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB upsert location: {e}")))
    }

    /// Fetch every member's latest location for a given circle, joined with
    /// their public profile for the map marker overlay.
    async fn get_circle_member_locations(
        &self,
        circle_id: Uuid,
    ) -> Result<Vec<MemberLocationWithProfile>, AppError> {
        sqlx::query_as::<_, MemberLocationWithProfile>(
            r#"
            SELECT ml.user_id,
                   u.name,
                   u.avatar_url,
                   ml.latitude,
                   ml.longitude,
                   ml.accuracy,
                   ml.updated_at
            FROM member_locations ml
            JOIN users u ON u.id = ml.user_id
            WHERE ml.circle_id = $1
            ORDER BY ml.updated_at DESC
            "#,
        )
        .bind(circle_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB get_circle_member_locations: {e}")))
    }

    /// Fetch the most-recent location row for a single user within a circle.
    async fn get_user_location(
        &self,
        user_id: Uuid,
        circle_id: Uuid,
    ) -> Result<Option<MemberLocation>, AppError> {
        sqlx::query_as::<_, MemberLocation>(
            r#"
            SELECT id, user_id, circle_id, latitude, longitude,
                   accuracy, heading, speed, recorded_at, updated_at
            FROM member_locations
            WHERE user_id = $1 AND circle_id = $2
            "#,
        )
        .bind(user_id)
        .bind(circle_id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB get_user_location: {e}")))
    }
}
