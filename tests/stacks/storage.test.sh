#!/usr/bin/env bash
source "$(dirname "$0")/../lib/assert.sh"
R=$(dirname "$(dirname "$(dirname "$0")")")
describe "Storage"
it "nextcloud"; assert_container_running "nextcloud"
it "nextcloud-nginx"; assert_container_running "nextcloud-nginx"
it "minio"; assert_container_running "minio"
it "minio healthy"; assert_container_healthy "minio"
it "filebrowser"; assert_container_running "filebrowser"
it "syncthing"; assert_container_running "syncthing"
it "nginx config"; assert_file_exists "$R/config/nextcloud/nginx.conf"