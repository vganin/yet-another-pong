#!/usr/bin/env bash

set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

mkdir -p $SCRIPT_PATH/out

cd $SCRIPT_PATH/../..
godot --no-window --export "Linux/X11" "build/linux/out/Pong"

cd $SCRIPT_PATH
butler push --if-changed out vsga/pong:linux-x64
