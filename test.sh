#!/bin/bash

set -e

echo "🔄 Stopping and removing existing Docker containers (if any)..."
docker-compose down || true

echo "🚀 Starting regtest Bitcoin node using docker-compose..."
docker-compose up -d

echo "⏳ Waiting for the Bitcoin node to be ready..."
sleep 5

echo "📦 Building Rust project..."
cd rust  # <-- Move into the rust project directory
cargo build

echo "⚙️ Running Rust logic..."
./run-rust.sh

echo "✅ Done."