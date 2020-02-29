#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

$SCRIPT_PATH/prepare_win_for_deploy.sh
$SCRIPT_PATH/prepare_mac_for_deploy.sh

butler push $SCRIPT_PATH/win vsga/pong:win-x64
butler push $SCRIPT_PATH/mac vsga/pong:mac-x64
