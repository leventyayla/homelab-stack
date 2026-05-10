#!/usr/bin/env bash
source "$(dirname "$0")/../lib/assert.sh"
R=$(dirname "$(dirname "$(dirname "$0")")")
describe "SSO"
it "auth-server"; assert_container_running "authentik-server"
it "auth-worker"; assert_container_running "authentik-worker"
it "auth-pg"; assert_container_running "authentik-postgres"
it "auth-redis"; assert_container_running "authentik-redis"
it "health"; assert_http_200 "http://authentik-server:9000/-/health/ready/"
it "setup script"; assert_file_exists "$R/scripts/setup-authentik.sh"