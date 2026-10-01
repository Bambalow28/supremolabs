#!/bin/sh
# Predeploy: build, then stamp. BUILD (the footer's version suffix) is CI's run
# number; 0 on a local deploy. Lives here because firebase.json predeploy
# mangles `=` and `${}`.
set -e
flutter build web --release --no-tree-shake-icons --dart-define=BUILD="${GITHUB_RUN_NUMBER:-0}"
sh tool/stamp_build.sh
