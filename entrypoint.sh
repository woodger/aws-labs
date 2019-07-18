#!/bin/bash
set -o errexit
BASEDIR="$1"

~/.local/bin/sam local start-api \
  --docker-volume-basedir "${BASEDIR}" \
  --host 0.0.0.0 \
  --port 3000
