#!/usr/bin/env bash
source "$(dirname "$0")/../lib/assert.sh"
describe "DB"
it "pg running"; assert_container_running "homelab-postgres"
it "pg healthy"; assert_container_healthy "homelab-postgres"
it "redis running"; assert_container_running "homelab-redis"
it "mariadb running"; assert_container_running "homelab-mariadb"