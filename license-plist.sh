#!/bin/sh

cd `dirname $0`

token=""

if [ 1 -le $# ]; then
token="--github-token $1"
fi

license-plist --output-path ./TwitterCircle/Settings.bundle $token --force --suppress-opening-directory
