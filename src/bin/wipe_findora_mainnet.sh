#!/usr/bin/env bash
set -ex
USERNAME=$USER
ENV=prod
NAMESPACE=mainnet
LIVE_VERSION=$(curl -s https://${ENV}-${NAMESPACE}.${ENV}.findora.org:8668/version | awk -F\  '{print $2}')
FRACTAL_IMG=fractalfoundation/fractal:${LIVE_VERSION}
export ROOT_DIR=/data/findora/${NAMESPACE}
CONTAINER_NAME=fractal

# Fix permissions from possible docker changes
if [ -d ${ROOT_DIR} ]; then
  sudo chown -R ${USERNAME}:${USERNAME} ${ROOT_DIR}
fi

##########################################
# Check if container is running and stop #
##########################################
if docker ps -a --format '{{.Names}}' | grep -Eq findorad; then
    echo -e "Findorad Container found, stopping container to restart."
    docker stop findorad
    docker rm findorad
    rm -rf /data/findora/mainnet/tendermint/config/addrbook.json
fi

if docker ps -a --format '{{.Names}}' | grep -Eq ${CONTAINER_NAME}; then
  echo -e "Fractal Container found, stopping container to restart."
  docker stop fractal
  docker rm fractal
  rm -rf /data/findora/mainnet/tendermint/config/addrbook.json
else
  echo 'Fractal container stopped or does not exist, continuing.'
fi

####################
# Wipe Local Files #
####################
if [ -d /data/findora/${NAMESPACE} ]; then
  sudo rm -r /data/findora/${NAMESPACE}
fi
sudo rm /usr/local/bin/fn
rm ~/.fractal.env
