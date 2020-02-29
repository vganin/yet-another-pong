#!/usr/bin/env bash

set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd $SCRIPT_PATH/win
zip -r pong-win-x64.zip Pong.exe
rm Pong.exe
