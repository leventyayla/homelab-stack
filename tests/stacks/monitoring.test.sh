#!/usr/bin/env bash
source "$(dirname "$0")/../lib/assert.sh"
R=$(dirname "$(dirname "$(dirname "$0")")")
describe "Monitoring"
it "prometheus"; assert_container_running "prometheus"
it "grafana"; assert_container_running "grafana"
it "loki"; assert_container_running "loki"
it "alertmanager"; assert_container_running "alertmanager"
it "grafana OIDC"; assert_file_contains "$R/config/grafana/grafana.ini" "generic_oauth"