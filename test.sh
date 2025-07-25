#!/bin/bash

set -e

# Check for docker-compose
if ! command -v docker-compose &> /dev/null; then
  echo "❌ docker-compose could not be found. Please install it first."
  exit 1
fi

echo "🔄 Stopping and removing existing Docker containers (if any)..."
docker-compose down || true

echo "🚀 Starting regtest Bitcoin node using docker-compose..."
docker-compose up -d

echo "⏳ Waiting for the Bitcoin node to be ready..."
sleep 5

echo "📦 Building Rust project..."
cargo build

echo "⚙️ Running Rust logic..."
./run-rust.sh

echo "✅ Done."