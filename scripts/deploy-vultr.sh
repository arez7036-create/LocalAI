#!/usr/bin/env bash
# LocalAI - Deploy to Vultr Cloud Compute (CPU, $20/mo - 2 vCPU / 4 GB RAM)
# Run on fresh Ubuntu 24.04 server as root

set -euo pipefail

echo "🚀 Deploying LocalAI..."

# Install Docker from official repo (includes docker compose)
apt-get update && apt-get install -y ca-certificates curl gnupg git
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

# Clone repo
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