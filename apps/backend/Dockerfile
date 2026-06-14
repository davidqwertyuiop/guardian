# Stage 1: Build the Rust binary
FROM rust:1.76-slim-bookworm AS builder

WORKDIR /usr/src/app

# Install system build dependencies
RUN apt-get update && apt-get install -y pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*

# Copy cargo manifest files
COPY Cargo.toml Cargo.lock ./

# Create dummy source folder to compile dependencies first (enabling Docker caching)
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -f target/release/deps/guardian_backend*

# Copy actual source files
COPY src ./src

# Build the release binary
RUN cargo build --release

# Stage 2: Minimal runner image
FROM debian:bookworm-slim

WORKDIR /app

# Install SSL certificates and required runtime packages
RUN apt-get update && apt-get install -y ca-certificates libssl3 && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from builder stage
COPY --from=builder /usr/src/app/target/release/guardian-backend /app/guardian-backend

# Expose backend port
EXPOSE 8080

# Run the app
CMD ["/app/guardian-backend"]
