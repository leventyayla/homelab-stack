# Observability Stack — Metrics, Logs, Traces, Alerts, Uptime

Complete monitoring stack covering all three observability pillars. Prometheus for metrics, Loki+Promtail for logs, Grafana for dashboards, Alertmanager for routing, and Uptime Kuma for SLA monitoring.

## Services

| Service | Image | URL | Purpose |
|---------|-------|-----|---------|
| Prometheus | `prom/prometheus:v2.54.1` | `https://prometheus.DOMAIN` | Metrics collection |
| Grafana | `grafana/grafana:11.2.2` | `https://grafana.DOMAIN` | Visualization dashboards |
| Loki | `grafana/loki:3.2.0` | (internal) | Log aggregation |
| Promtail | `grafana/promtail:3.2.0` | — | Log collector agent |
| Alertmanager | `prom/alertmanager:v0.27.0` | `https://alerts.DOMAIN` | Alert routing |
| cAdvisor | `gcr.io/cadvisor/cadvisor:v0.50.0` | — | Container metrics |
| Node Exporter | `prom/node-exporter:v1.8.2` | — | Host metrics |
| Uptime Kuma | `louislam/uptime-kuma:1.23.15` | `https://uptime.DOMAIN` | Service uptime monitoring |

## Quick Start

```bash
cd stacks/monitoring && docker compose up -d
docker compose ps  # Wait for all healthy

# Grafana login:
# URL: https://grafana.DOMAIN
# User: admin / ${GRAFANA_ADMIN_PASSWORD}
# OIDC: Also supports Authentik SSO
```

## Prometheus Targets

Configured in `config/prometheus/prometheus.yml`:

| Target | Port | Job | Metrics |
|--------|------|-----|---------|
| Prometheus | 9090 | prometheus | Self-monitoring |
| cAdvisor | 8080 | cadvisor | Container CPU/Mem/Disk |
| Node Exporter | 9100 | node | Host CPU/Mem/Disk/Net |
| Traefik | 8080 | traefik | Request counts, latencies |
| Grafana | 3000 | grafana | Dashboard usage |
| Alertmanager | 9093 | alertmanager | Alert state |

## Grafana Dashboards

Provisioned automatically from `config/grafana/provisioning/dashboards/`:

| Dashboard | Source | Shows |
|-----------|--------|-------|
| Docker Containers | Grafana #179 | All container metrics |
| Node Exporter Full | Grafana #1860 | Host system metrics |
| Traefik | Grafana #17357 | Reverse proxy stats |
| PostgreSQL | Grafana #9628 | Database performance |
| Redis | Grafana #12776 | Cache metrics |

## Alertmanager → ntfy

Alerts route to ntfy for push notifications. Configured in `config/alertmanager/alertmanager.yml`:

```yaml
receivers:
  - name: ntfy
    webhook_configs:
      - url: "http://ntfy:80/homelab-alerts"
        send_resolved: true
```

## Uptime Kuma

1. Open `https://uptime.${DOMAIN}`
2. Create admin account
3. Add monitors for each service:

| Service | URL | Interval |
|---------|-----|----------|
| Traefik | `https://traefik.DOMAIN/api/version` | 60s |
| Grafana | `https://grafana.DOMAIN/api/health` | 60s |
| Authentik | `https://auth.DOMAIN/-/health/ready/` | 60s |
| Nextcloud | `https://nextcloud.DOMAIN/status.php` | 60s |
| Gitea | `https://git.DOMAIN` | 60s |

4. Setup ntfy notification in Settings → Notifications

## Logs (Loki + Promtail)

Promtail collects logs from all Docker containers and ships to Loki. Query in Grafana → Explore → Loki datasource:

```logql
{container="traefik"} |= "error"
{container=~"nextcloud.*"} | json
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Prometheus targets down | Check `docker network connect databases prometheus` |
| Grafana OIDC fails | Verify `GRAFANA_OAUTH_CLIENT_ID` set in .env |
| No container metrics | cAdvisor needs `--privileged` or proper cgroup mounts |
| Logs missing | Check Promtail has access to `/var/lib/docker/containers` |