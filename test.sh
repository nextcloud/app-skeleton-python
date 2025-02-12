#!/bin/bash
set -e

docker container remove --force nc_app_app-skeleton-python || true

docker build -t nc_app_app-skeleton-python .

docker run --rm \
  -e HP_SHARED_KEY="mysecret" \
  -e HP_FRP_ADDRESS="nextcloud-appapi-harp" \
  -e HP_FRP_PORT="8782" \
  -e APP_HOST="127.0.0.1" \
  -e APP_PORT="23090" \
  -e APP_ID="app-skeleton-python" \
  -e APP_SECRET="12345" \
  -e APP_VERSION="1.0.0" \
  -e NEXTCLOUD_URL="http://nextcloud.local" \
  --name nc_app_app-skeleton-python \
  --network=master_default \
  nc_app_app-skeleton-python
