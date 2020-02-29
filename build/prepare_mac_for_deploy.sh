#!/usr/bin/env bash

set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd $SCRIPT_PATH/mac
unzip pong-mac-x64.zip
chmod u+x Pong.app/Contents/MacOS/Pong
codesign -fs "Apple Development: vsevolod.ganin@gmail.com (C3P48GVCLX)" Pong.app
zip -r pong-mac-x64.zip Pong.app
codesign -fs "Apple Development: vsevolod.ganin@gmail.com (C3P48GVCLX)" pong-mac-x64.zip
rm -rf Pong.app
