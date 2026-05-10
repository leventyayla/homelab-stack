#!/usr/bin/env bash
# Nextcloud OIDC setup via Authentik + sociallogin app
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")
[ -f "$ROOT_DIR/.env" ] && { set -a; source "$ROOT_DIR/.env"; set +a; }
GREEN='\033[0;32m'; RED='\033[0;31m'; RESET='\033[0m'

NEXTCLOUD_CONTAINER="nextcloud"
AUTHENTIK_URL="https://auth.${DOMAIN}"

[ -z "${NEXTCLOUD_OAUTH_CLIENT_ID:-}" ] && { echo -e "${RED}NEXTCLOUD_OAUTH_CLIENT_ID not set${RESET}"; exit 1; }

docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ app:enable sociallogin 2>/dev/null ||   docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ app:install sociallogin

docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ config:app:set sociallogin custom_providers --value="{
  \"Authentik\": {
    \"name\": \"Authentik\",
    \"title\": \"Login with Authentik\",
    \"authorizeUrl\": \"$AUTHENTIK_URL/application/o/authorize/\",
    \"tokenUrl\": \"$AUTHENTIK_URL/application/o/token/\",
    \"userInfoUrl\": \"$AUTHENTIK_URL/application/o/userinfo/\",
    \"logoutUrl\": \"$AUTHENTIK_URL/application/o/nextcloud/end-session/\",
    \"clientId\": \"$NEXTCLOUD_OAUTH_CLIENT_ID\",
    \"clientSecret\": \"$NEXTCLOUD_OAUTH_CLIENT_SECRET\",
    \"scope\": \"openid profile email\",
    \"defaultGroup\": \"homelab-users\"
  }
}"

echo -e "${GREEN}Nextcloud OIDC configured${RESET}