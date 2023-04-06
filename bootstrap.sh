#!/usr/bin/env bash

# exit immediately if pipeline/list/(compound command) returns non-zero status
# reference https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
set -e

# switch node version
. /etc/profile
if [ -z "$NODEJS_VERSION" ]; then
    NODEJS_VERSION="lts/erbium"
fi
nvm use $NODEJS_VERSION
echo "node version is $(node -v)"

INSTANCE_NAME="demo"
CURRENT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$CURRENT_DIR" || exit

# default port to serve http
# TCE_PRIMARY_PORT is used for bridge newtwork.
PORT=$TCE_PRIMARY_PORT
if [ -z "$PORT" ]; then
    PORT=3000
fi

PM2_INSTANCES=1

# if docker network mode is "host", then to get an available port from the envrionment variable
if [ "$IS_HOST_NETWORK" = "1" ]; then
    PORT=$PORT0
fi

# use the env varibles if defined, see: https://bytedance.feishu.cn/wiki/wikcnR7f17phbl2h7ZVnj4KgRfg
if [ "$MY_CPU_REQUEST" ]; then
    PM2_INSTANCES=$MY_CPU_REQUEST
fi
if [ "$PM2_INSTANCES" -lt 1 ]; then
    PM2_INSTANCES=1
fi

# start the server
NODE_ENV=production \
PORT=$PORT \
pm2 start "npm run start" -n $INSTANCE_NAME --no-daemon -i $PM2_INSTANCES --log-date-format "YYYY-MM-DD HH:mm:ss"
