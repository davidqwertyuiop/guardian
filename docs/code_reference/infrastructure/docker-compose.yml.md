# docker-compose.yml

* **File Path:** `infrastructure/docker-compose.yml`
* **Type:** `YAML`

---

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ../apps/backend
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - SERVER_HOST=0.0.0.0
      - SERVER_PORT=8080
      - JWT_SECRET=production-secret-key-change-me-in-production
      - JWT_REFRESH_SECRET=production-refresh-key-change-me-in-production
      - OTP_TTL_SECONDS=300
      - RATE_LIMIT_WINDOW_SECONDS=60
      - DATABASE_URL=postgres://guardian_user:secure_db_pass@postgres:5432/guardian_db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis
    networks:
      - guardian-net

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=guardian_user
      - POSTGRES_PASSWORD=secure_db_pass
      - POSTGRES_DB=guardian_db
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"
    networks:
      - guardian-net

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    networks:
      - guardian-net

volumes:
  postgres-data:
  redis-data:

networks:
  guardian-net:
    driver: bridge

```
