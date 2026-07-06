use crate::domains::sos::domain::{
    entities::sos_broadcast::{SosBroadcast, SosBroadcastWithProfile},
    repositories::sos_repository::SosRepository,
};
use crate::shared::errors::AppError;
use async_trait::async_trait;
use sqlx::PgPool;
use uuid::Uuid;

pub struct PostgresSosRepository {
    pub pool: PgPool,
}

#[async_trait]
impl SosRepository for PostgresSosRepository {
    async fn create(
        &self,
        user_id: Uuid,
        circle_id: Uuid,
        latitude: Option<f64>,
        longitude: Option<f64>,
        address: Option<String>,
    ) -> Result<SosBroadcast, AppError> {
        if let Some(existing) = sqlx::query_as::<_, SosBroadcast>(
            r#"
            UPDATE sos_broadcasts
            SET latitude = COALESCE($3, latitude),
                longitude = COALESCE($4, longitude),
                address = COALESCE($5, address)
            WHERE user_id = $1
              AND circle_id = $2
              AND status = 'active'
            RETURNING id, user_id, circle_id, latitude, longitude, address,
                      status, resolved_at, created_at
            "#,
        )
        .bind(user_id)
        .bind(circle_id)
        .bind(latitude)
        .bind(longitude)
        .bind(address.clone())
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB update active SOS: {e}")))?
        {
            return Ok(existing);
        }

        sqlx::query_as::<_, SosBroadcast>(
            r#"
            INSERT INTO sos_broadcasts (user_id, circle_id, latitude, longitude, address, status)
            VALUES ($1, $2, $3, $4, $5, 'active')
            RETURNING id, user_id, circle_id, latitude, longitude, address,
                      status, resolved_at, created_at
            "#,
        )
        .bind(user_id)
        .bind(circle_id)
        .bind(latitude)
        .bind(longitude)
        .bind(address)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB create SOS: {e}")))
    }

    async fn list_for_circle(
        &self,
        circle_id: Uuid,
        limit: i64,
        offset: i64,
    ) -> Result<Vec<SosBroadcastWithProfile>, AppError> {
        sqlx::query_as::<_, SosBroadcastWithProfile>(
            r#"
            SELECT sb.id,
                   sb.user_id,
                   u.name,
                   u.avatar_url,
                   sb.latitude,
                   sb.longitude,
                   sb.address,
                   sb.status,
                   sb.created_at
            FROM sos_broadcasts sb
            JOIN users u ON u.id = sb.user_id
            WHERE sb.circle_id = $1
            ORDER BY sb.created_at DESC
            LIMIT $2
            OFFSET $3
            "#,
        )
        .bind(circle_id)
        .bind(limit)
        .bind(offset)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| AppError::Internal(format!("DB list SOS broadcasts: {e}")))
    }

    async fn resolve(&self, id: Uuid, resolver_user_id: Uuid) -> Result<SosBroadcast, AppError> {
        // Any circle member may resolve — resolver identity is logged via audit trail
        // in a future sprint. For now we mark the row and capture resolved_at.
        let _ = resolver_user_id; // suppress unused warning; retained for future audit

        sqlx::query_as::<_, SosBroadcast>(
            r#"
            UPDATE sos_broadcasts
            SET status      = 'resolved',
                resolved_at = NOW()
            WHERE id = $1 AND status = 'active'
            RETURNING id, user_id, circle_id, latitude, longitude, address,
                      status, resolved_at, created_at
            "#,
        )
        .bind(id)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| {
            AppError::NotFound(format!("SOS broadcast not found or already resolved: {e}"))
        })
    }

    async fn dismiss(&self, id: Uuid, user_id: Uuid) -> Result<SosBroadcast, AppError> {
        // Only the originating user may dismiss their own broadcast. If older
        // duplicate active rows exist for the same circle, dismiss them too.
        sqlx::query_as::<_, SosBroadcast>(
            r#"
            WITH target AS (
                SELECT circle_id
                FROM sos_broadcasts
                WHERE id = $1 AND user_id = $2
                LIMIT 1
            ),
            updated AS (
                UPDATE sos_broadcasts
                SET status = 'dismissed'
                WHERE user_id = $2
                  AND status = 'active'
                  AND circle_id = (SELECT circle_id FROM target)
                RETURNING id, user_id, circle_id, latitude, longitude, address,
                          status, resolved_at, created_at
            )
            SELECT id, user_id, circle_id, latitude, longitude, address,
                   status, resolved_at, created_at
            FROM updated
            ORDER BY created_at DESC
            LIMIT 1
            "#,
        )
        .bind(id)
        .bind(user_id)
        .fetch_one(&self.pool)
        .await
        .map_err(|_| {
            AppError::NotFound(
                "SOS broadcast not found, already resolved, or you are not the owner.".into(),
            )
        })
    }
}
