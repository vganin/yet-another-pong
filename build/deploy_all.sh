#!/usr/bin/env bash

set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

$SCRIPT_PATH/win/deploy.sh
$SCRIPT_PATH/mac/deploy.sh
$SCRIPT_PATH/linux/deploy.sh
