#!/usr/bin/env bash
set -o errexit -o errtrace -o noclobber -o nounset -o pipefail
IFS=$'\n\t'

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "$script_dir"

# https://github.com/itk-dev/OS2iot-docker/tree/feature/docker-setup-cleanup
repo=https://github.com/itk-dev/OS2iot-docker
branch=feature/docker-setup-cleanup
dir=OS2iot-docker

git clone "$repo" --branch "$branch" "$dir" || true
git -C "$dir" fetch
git -C "$dir" checkout "$branch"
git -C "$dir" clean -fd .
git -C "$dir" reset --hard origin/"$branch"

# https://github.com/itk-dev/OS2iot-backend/tree/$branch
repo=https://github.com/itk-dev/OS2iot-backend
branch=feature/docker-setup-cleanup
dir=OS2iot-backend

git clone "$repo" --branch "$branch" "$dir" || true
git -C "$dir" fetch
git -C "$dir" checkout "$branch"
git -C "$dir" clean -fd .
git -C "$dir" reset --hard origin/"$branch"

# https://github.com/OS2iot/OS2iot-backend/pull/296
curl --location https://github.com/OS2iot/OS2iot-backend/pull/296.diff | git -C "$dir" apply

# https://github.com/OS2iot/OS2iot-backend/pull/295
# curl --location https://github.com/OS2iot/OS2iot-backend/pull/295.diff | git -C "$dir" apply

# https://github.com/itk-dev/OS2iot-frontend/tree/$branch
repo=https://github.com/itk-dev/OS2iot-frontend
branch=feature/docker-setup-cleanup
dir=OS2iot-frontend

git clone "$repo" --branch "$branch" "$dir" || true
git -C "$dir" fetch
git -C "$dir" checkout "$branch"
git -C "$dir" clean -fd .
git -C "$dir" reset --hard origin/"$branch"

# https://github.com/OS2iot/OS2iot-frontend/pull/220
curl --location https://github.com/OS2iot/OS2iot-frontend/pull/220.diff | git -C "$dir" apply

# https://github.com/OS2iot/OS2iot-frontend/pull/219
# curl --location https://github.com/OS2iot/OS2iot-frontend/pull/219.diff | git -C "$dir" apply

# ------------------------------------------------------------------------------

cat >| OS2iot-docker/.env <<'EOF'
COMPOSE_PROJECT_NAME=os2iot-test
EOF

cd OS2iot-docker

task setup:certs

docker compose --file docker-compose.yml --file ../docker-compose.local.yml  up --build --detach --wait

task setup:org
task setup:chirpstack

task open
