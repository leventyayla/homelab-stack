#!/usr/bin/env bash
source "$(dirname "$0")/../lib/assert.sh"
R=$(dirname "$(dirname "$(dirname "$0")")")
describe "Base"
it "traefik"; assert_container_running "traefik"
it "portainer"; assert_container_running "portainer"
it "watchtower"; assert_container_running "watchtower"
it "proxy net"; assert_true "docker network inspect proxy &>/dev/null"
it "config"; assert_file_exists "$R/config/traefik/traefik.yml"