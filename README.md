# LocalAI — Private, Uncensored ChatGPT Clone

Self-hosted AI chat for 2 users. No filters, no limits, your data, your rules. Runs on **$6/mo Vultr Cloud Compute (CPU only)**.

---

## 🎯 Features

- **Uncensored models**: Dolphin-Mistral, OpenChat, WizardLM-Uncensored
- **No content filters** — models won't refuse requests
- **Rate limiting** — 50 req/hr per user (admin unlimited)
- **Usage tracking** — logs all requests with timestamps
- **Model permissions** — control which user accesses which model
- **File upload / RAG** — drag PDF, TXT, MD to chat with documents
- **2 users max** — signup disabled after account creation

---

## 💰 Cost

| Component | Cost |
|-----------|------|
| Vultr Cloud Compute (2 vCPU, 4GB RAM) | **$6/mo** |
| Storage (25GB SSD included) | Included |
| Bandwidth | Included |
| **Total** | **$6/mo** |

*No GPU needed — 7B quantized models run fine on CPU.*

---

## 🚀 Quick Deploy (3 Commands)

```bash
# 1. Create Vultr server: Cloud Compute → Regular → 2 vCPU / 4GB / Ubuntu 24.04 ($6/mo)

# 2. SSH in and run:
ssh root@YOUR_VULTR_IP
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/LocalAI/main/scripts/deploy-vultr.sh | bash

# 3. Open http://YOUR_IP:3000 → create 2 accounts → done
```

---

## 🖥 Local Development

```bash
# Requirements: Docker Desktop

git clone https://github.com/YOUR_USERNAME/LocalAI.git
cd LocalAI

# Start (uses local ./data and ./models folders)
docker compose up -d

# Pull models (in another terminal)
docker exec -it localai-ollama ollama pull dolphin-mistral:7b
docker exec -it localai-ollama ollama pull openchat:7b

# Access
open http://localhost:3000
```

---

## 🔧 Management

```bash
# View logs (usage monitoring)
docker logs -f localai

# Check resource usage
docker stats localai localai-ollama

# Pull more models
docker exec -it localai-ollama ollama pull wizardlm-uncensored:13b
docker exec -it localai-ollama ollama pull zephyr:7b

# Backup data
tar -czf backup-$(date +%F).tar.gz data/ models/

# Update
docker compose pull && docker compose up -d

# Restart
docker compose restart
```

---

## 📊 Rate Limits & Monitoring

| Setting | Value | Config |
|---------|-------|--------|
| Requests per hour | 50 | `RATE_LIMIT_REQUESTS` |
| Window | 1 hour | `RATE_LIMIT_WINDOW` |
| Admin bypass | Yes | `RATE_LIMIT_BYPASS_ADMIN` |
| Usage logging | Enabled | `ENABLE_USAGE_TRACKING` |

**Admin Panel**: Settings → Admin Panel → Users / Models / Rate Limits / Logs

---

## 🦙 Recommended Models (Uncensored)

| Model | Size | Strengths |
|-------|------|-----------|
| `dolphin-mistral:7b` | 4.1 GB | Best general uncensored, great reasoning |
| `openchat:7b` | 4.1 GB | Fast, good instruct following |
| `wizardlm-uncensored:13b` | 7.3 GB | Strongest, best for complex tasks |
| `zephyr:7b` | 4.1 GB | Good chat, uncensored |
| `neural-chat:7b` | 4.1 GB | Optimized for dialogue |

Pull any: `docker exec -it localai-ollama ollama pull MODEL_NAME`

---

## 📁 Project Structure

```
LocalAI/
├── docker-compose.yml      # Main stack
├── .env                    # Secrets (WEBUI_SECRET_KEY)
├── .env.example            # Template
├── scripts/
│   └── deploy-vultr.sh     # One-command Vultr deploy
├── data/                   # SQLite DB, chats, users, logs
│   └── webui.db
└── models/                 # GGUF model files
    └── manifests/
```

---

## 🔐 Security Notes

- **Change default secret** in `.env` before deploy
- **Firewall**: Only open port 3000 (or use SSH tunnel)
- **HTTPS**: Add Cloudflare Tunnel or Nginx + Let's Encrypt for production
- **Backups**: Regular `tar` of `data/` and `models/`

---

## 🛠 Customization

**Add more models** to `docker-compose.yml`:
```yaml
DEFAULT_MODELS=dolphin-mistral:7b,openchat:7b,wizardlm-uncensored:13b,zephyr:7b
```

**Adjust rate limits**:
```yaml
RATE_LIMIT_REQUESTS=100    # More generous
RATE_LIMIT_WINDOW=1800     # 30 min window
```

**Enable PostgreSQL** (for better analytics):
```yaml
# Uncomment postgres service in docker-compose.yml
# Add DATABASE_URL to open-webui environment
```

---

## 🆘 Troubleshooting

| Issue | Fix |
|-------|-----|
| Out of memory | Reduce `memory` limit in ollama deploy, or use smaller models |
| Slow responses | Normal for CPU inference; 7B ~2-5 sec/response |
| Can't connect | Check firewall: `ufw allow 3000` |
| Model not found | `docker exec -it localai-ollama ollama pull MODEL` |
| Signup not working | `ENABLE_SIGNUP=false` in compose — create accounts manually first |

---

## 📜 License

MIT — Use freely, modify, distribute.