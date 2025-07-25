# #!/bin/bash

# set -e

# echo "🔄 Stopping and removing existing Docker containers (if any)..."
# docker-compose down || true

# echo "🚀 Starting regtest Bitcoin node using docker-compose..."
# docker-compose up -d

# echo "⏳ Waiting for the Bitcoin node to be ready..."
# sleep 5

# echo "📦 Building Rust project..."
# cd rust  # <-- Move into the rust project directory
# cargo build

# echo "⚙️ Running Rust logic..."
# ./run-rust.sh

# echo "✅ Done."

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"


#!/bin/bash

set -e  # Exit on error

echo "🔧 Setting up Node.js via NVM..."

# Load nvm if already installed
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"
else
  # Install NVM
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  source "$NVM_DIR/nvm.sh"
fi

# Install latest LTS Node
nvm install --lts
nvm use --lts

echo "📦 Installing Node.js dependencies..."
npm install

echo "🐳 Starting bitcoind via Docker Compose..."
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

echo "🚀 Running Rust logic and integration test..."
/bin/bash run.sh
npm run test

echo "🧹 Stopping containers and cleaning up..."
docker-compose down -v

echo "✅ All done."