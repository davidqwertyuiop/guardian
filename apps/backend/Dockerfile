# ── Builder Stage ─────────────────────────────────────────────────────────────
FROM rust:1-slim-bookworm AS builder

WORKDIR /usr/src/app

# Install system dependencies needed for compiling OpenSSL / build process
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy workspace / source files
COPY . .

# Build dependencies first to leverage caching if applicable, then build final release
RUN cargo build --release

# ── Runtime Stage ─────────────────────────────────────────────────────────────
FROM debian:bookworm-slim

WORKDIR /app

# Install SSL certificates and runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Copy compiling release binary from builder
COPY --from=builder /usr/src/app/target/release/guardian-backend /app/guardian-backend
COPY --from=builder /usr/src/app/migrations /app/migrations

# Render injects PORT at runtime — expose 8080 to match render.yaml default.
EXPOSE 8080

# Do NOT hardcode PORT here — Render overrides it with its own value.
ENV RUST_LOG=info

# Run the app
CMD ["/app/guardian-backend"]
