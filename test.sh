#!/bin/bash

set -e  # Exit on any error

echo "🔧 Setting up Node.js via NVM..."

# Load NVM if installed
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"
else
  echo "📥 Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
fi

echo "📦 Installing latest LTS Node.js..."
nvm install --lts
nvm use --lts

echo "📦 Installing Node.js dependencies..."
npm install

echo "🐳 Starting bitcoind via Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
  echo "❌ docker-compose not found. Installing..."
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "✅ docker-compose installed."
else
  echo "✅ docker-compose is already installed."
fi

docker-compose up -d
sleep 10

echo "⏳ Waiting for bitcoind to be fully initialized..."
until curl --silent --user alice:password --data-binary \
  '{"jsonrpc":"1.0","id":"ping","method":"getblockchaininfo","params":[]}' \
  -H 'content-type: text/plain;' http://127.0.0.1:18443 | grep -q '"chain"'; do
  echo "Waiting for bitcoind..."
  sleep 3
done
echo "✅ bitcoind is ready."

echo "⚙️ Giving execution permissions to scripts..."
chmod +x ./rust/run-rust.sh
chmod +x ./run.sh

echo "📦 Building Rust project..."
cd rust
cargo build
cd ..

echo "🚀 Running Rust logic and integration test..."
./run.sh
npm run test

echo "🧹 Stopping containers and cleaning up..."
docker-compose down -v

echo "✅ All done."