# AI Stack — LLM Hosting, Chat UI, Workflow Automation

Self-hosted AI services: Ollama for LLM inference, Open WebUI for chat, and n8n for automation workflows.

## Services

| Service | Image | URL | Purpose |
|---------|-------|-----|---------|
| Ollama | `ollama/ollama:0.3.14` | `https://ollama.DOMAIN` | LLM inference server |
| Open WebUI | `ghcr.io/open-webui/open-webui:0.4.2` | `https://openwebui.DOMAIN` | ChatGPT-like chat UI |
| n8n | `n8nio/n8n:1.68.0` | `https://n8n.DOMAIN` | Workflow automation |

## Quick Start

```bash
cd stacks/ai && docker compose up -d

# Pull a model
docker exec ollama ollama pull llama3.2:3b

# Open WebUI
# URL: https://openwebui.DOMAIN
# Create admin account on first visit
# Connect to Ollama: http://ollama:11434

# n8n
# URL: https://n8n.DOMAIN
```

## Recommended Models

| Model | Size | Command | Use Case |
|-------|------|---------|----------|
| llama3.2:3b | 2GB | `ollama pull llama3.2:3b` | General chat, fast |
| mistral:7b | 4GB | `ollama pull mistral:7b` | Better reasoning |
| nomic-embed-text | 274MB | `ollama pull nomic-embed-text` | Embeddings/RAG |
| codellama:7b | 4GB | `ollama pull codellama:7b` | Code generation |

## Open WebUI OIDC (Authentik)

After running `scripts/setup-authentik.sh`, set in `.env`:

```bash
OPENWEBUI_OAUTH_CLIENT_ID=xxx
OPENWEBUI_OAUTH_CLIENT_SECRET=xxx
```

Then in Open WebUI Admin → Settings → General:
- Enable OAuth
- Provider: OpenID Connect
- OIDC Client ID: ${OPENWEBUI_OAUTH_CLIENT_ID}
- OIDC Client Secret: ${OPENWEBUI_OAUTH_CLIENT_SECRET}
- OpenID Provider URL: https://auth.DOMAIN/application/o/open-webui/.well-known/openid-configuration

## GPU Support

To enable NVIDIA GPU acceleration, add to the Ollama service:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

Set `OLLAMA_GPU_ENABLED=true` in `.env`.

## n8n Workflows

Example: AI-powered notification workflow:
1. Trigger: Webhook from HomeLab alert
2. LLM: Summarize alert with Ollama
3. Notify: Send via ntfy

Import from `config/n8n/workflows/` directory.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OLLAMA_GPU_ENABLED` | No | Enable NVIDIA GPU (default: false) |
| `OPENWEBUI_OAUTH_CLIENT_ID` | No | OIDC client from Authentik |
| `OPENWEBUI_OAUTH_CLIENT_SECRET` | No | OIDC secret from Authentik |
| `N8N_ENCRYPTION_KEY` | Yes | Encryption key for n8n credentials |

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Ollama slow | Use smaller model (3B vs 7B) or enable GPU |
| Open WebUI can't connect | Check `OLLAMA_BASE_URL=http://ollama:11434` |
| n8n can't access Ollama | Add n8n to same Docker network as Ollama |
| GPU not detected | Verify `nvidia-smi` works on host, `--gpus all` in compose |