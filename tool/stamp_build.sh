#!/bin/sh
# Predeploy: stamps this build into index.html and mirrors assets/ under a
# per-deploy path (see web/flutter_bootstrap.js for why).
set -e
STAMP=$(date +%s)
perl -pi -e "s/__BUILD__/$STAMP/g" build/web/index.html
mkdir -p "build/web/b/$STAMP"
cp -R build/web/assets "build/web/b/$STAMP/assets"
