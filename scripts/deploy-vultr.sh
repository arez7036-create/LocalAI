#!/usr/bin/env bash
# LocalAI - Deploy to Vultr Cloud Compute (CPU, $6/mo)
# Run on fresh Ubuntu 24.04 server as root

set -euo pipefail

echo "🚀 Deploying LocalAI..."

# Install Docker
apt-get update && apt-get install -y docker.io docker-compose-plugin git curl
systemctl enable --now docker

# Clone repo (replace with your fork)
REPO_URL="https://github.com/arez7036-create/LocalAI.git"
INSTALL_DIR="/opt/LocalAI"

git clone "$REPO_URL" "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Ensure .env exists
if [ ! -f .env ]; then
    cp .env.example .env
    # Generate secret if not set
    if grep -q "your-secret-key-here" .env; then
        SECRET=$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)
        sed -i "s/your-secret-key-here/$SECRET/" .env
    fi
fi

# Start stack
docker compose up -d

# Pull models
echo "📥 Pulling models (this takes 5-10 minutes)..."
docker exec -it localai-ollama ollama pull dolphin-mistral:7b
docker exec -it localai-ollama ollama pull openchat:7b

IP=$(curl -s ifconfig.me || curl -s icanhazip.com)
echo ""
echo "✅ LocalAI deployed!"
echo "🌐 Access: http://$IP:3000"
echo "👤 Create 2 accounts, then disable signup in Admin Panel"
echo ""
echo "📊 Monitor: docker logs -f localai"
echo "🔧 Admin: Settings → Admin Panel"