#!/usr/bin/env bash
# Authentik SSO Setup — OIDC providers, user groups, applications
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")
if [ -f "$ROOT_DIR/.env" ]; then set -a; source "$ROOT_DIR/.env"; set +a; fi

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${RESET} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
log_step()  { echo; echo -e "${BOLD}${CYAN}==> $*${RESET}"; }
log_dry()   { echo -e "${YELLOW}[DRY-RUN]${RESET} $*"; }

DRY_RUN=false; [[ "${1:-}" == "--dry-run" ]] && { DRY_RUN=true; log_info "DRY-RUN mode"; }

AUTHENTIK_URL="https://${AUTHENTIK_DOMAIN:-auth.${DOMAIN}}"
API_URL="$AUTHENTIK_URL/api/v3"
TOKEN="${AUTHENTIK_BOOTSTRAP_TOKEN:-}"

if [ -z "$TOKEN" ] && [ "$DRY_RUN" = false ]; then
  log_error "AUTHENTIK_BOOTSTRAP_TOKEN not set"
  exit 1
fi
AUTH_HEADER="Authorization: Bearer $TOKEN"

api_call() {
  local method="$1" url="$2" data="$3"
  if [ "$DRY_RUN" = true ]; then echo '{"pk":0,"client_id":"DRY_RUN","client_secret":"DRY_RUN"}'; return; fi
  curl -sf -X "$method" "$url" -H "$AUTH_HEADER" -H "Content-Type: application/json" -d "$data"
}

create_group() {
  local name="$1"
  log_info "  Group: $name"
  if [ "$DRY_RUN" = true ]; then return; fi
  local exists=$(curl -sf "$API_URL/core/groups/?name=${name}" -H "$AUTH_HEADER" | jq -r '.results | length')
  [ "$exists" -gt 0 ] && { log_warn "  Already exists"; return; }
  api_call POST "$API_URL/core/groups/" "$(jq -n --arg name "$name" '{name: $name}')" > /dev/null
}

create_oidc_provider() {
  local name="$1" redirect_uri="$2" client_id_var="$3" client_secret_var="$4"
  log_step "Provider: $name"
  if [ "$DRY_RUN" = true ]; then log_dry "Would create $name → ${redirect_uri}"; return; fi
  local slug=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  local existing=$(curl -sf "$API_URL/providers/oauth2/?search=${name}" -H "$AUTH_HEADER" | jq -r '.results | length')
  [ "$existing" -gt 0 ] && { log_warn "Already exists"; return; }
  local flow_pk=$(curl -sf "$API_URL/flows/instances/?designation=authorize&ordering=slug" -H "$AUTH_HEADER" | jq -r '.results[0].pk')
  local signing_key=$(curl -sf "$API_URL/crypto/certificatekeypairs/?has_key=true&ordering=name" -H "$AUTH_HEADER" | jq -r '.results[0].pk')
  local payload=$(jq -n --arg name "${name} Provider" --arg flow "$flow_pk" --arg uri "$redirect_uri" --arg key "$signing_key" '{name: $name, authorization_flow: $flow, client_type: "confidential", redirect_uris: $uri, sub_mode: "hashed_user_id", include_claims_in_id_token: true, signing_key: $key}')
  local response=$(api_call POST "$API_URL/providers/oauth2/" "$payload")
  local provider_pk=$(echo "$response" | jq -r '.pk')
  local client_id=$(echo "$response" | jq -r '.client_id')
  local client_secret=$(echo "$response" | jq -r '.client_secret')
  log_info "  Client ID: $client_id"
  sed -i "s|^${client_id_var}=.*|${client_id_var}=${client_id}|" "$ROOT_DIR/.env"
  sed -i "s|^${client_secret_var}=.*|${client_secret_var}=${client_secret}|" "$ROOT_DIR/.env"
  local app_payload=$(jq -n --arg name "$name" --arg slug "$slug" --argjson pk "$provider_pk" '{name: $name, slug: $slug, provider: $pk}')
  api_call POST "$API_URL/core/applications/" "$app_payload" > /dev/null
  log_info "  Done: $AUTHENTIK_URL/application/o/${slug}/"
}

if [ "$DRY_RUN" = false ]; then
  log_step "Waiting for Authentik..."
  for i in $(seq 1 30); do
    curl -sf "$AUTHENTIK_URL/-/health/ready/" -o /dev/null 2>/dev/null && { log_info "Ready"; break; }
    [ "$i" -eq 30 ] && { log_error "Timeout"; exit 1; }
    sleep 5
  done
fi

log_step "User Groups"
create_group "homelab-admins"
create_group "homelab-users"
create_group "media-users"

log_step "OIDC Providers"
create_oidc_provider "Grafana" "https://grafana.${DOMAIN}/login/generic_oauth" "GRAFANA_OAUTH_CLIENT_ID" "GRAFANA_OAUTH_CLIENT_SECRET"
create_oidc_provider "Gitea" "https://git.${DOMAIN}/user/oauth2/Authentik/callback" "GITEA_OAUTH_CLIENT_ID" "GITEA_OAUTH_CLIENT_SECRET"
create_oidc_provider "Outline" "https://outline.${DOMAIN}/auth/oidc.callback" "OUTLINE_OAUTH_CLIENT_ID" "OUTLINE_OAUTH_CLIENT_SECRET"
create_oidc_provider "Nextcloud" "https://nextcloud.${DOMAIN}/apps/sociallogin/custom_oidc/Authentik" "NEXTCLOUD_OAUTH_CLIENT_ID" "NEXTCLOUD_OAUTH_CLIENT_SECRET"
create_oidc_provider "Portainer" "https://portainer.${DOMAIN}/" "PORTAINER_OAUTH_CLIENT_ID" "PORTAINER_OAUTH_CLIENT_SECRET"
create_oidc_provider "Open WebUI" "https://openwebui.${DOMAIN}/oauth/oidc/callback" "OPENWEBUI_OAUTH_CLIENT_ID" "OPENWEBUI_OAUTH_CLIENT_SECRET"

log_step "Complete!"
echo "  Admin UI: $AUTHENTIK_URL/if/admin/"
echo "  User Portal: $AUTHENTIK_URL/if/user/"
[ "$DRY_RUN" = true ] && echo "  Run without --dry-run to apply."
