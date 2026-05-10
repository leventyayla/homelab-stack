#!/usr/bin/env bash
source "$(dirname "$0")/../lib/assert.sh"
R=$(dirname "$(dirname "$(dirname "$0")")")
describe "Notify"
it "ntfy"; assert_container_running "ntfy"
it "gotify"; assert_container_running "gotify"
it "apprise"; assert_container_running "apprise"
it "notify.sh"; assert_file_exists "$R/scripts/notify.sh"