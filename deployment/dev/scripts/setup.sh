#!/bin/bash

export FABRIC_CFG_PATH=/etc/hyperledger/fabric/configtx.yaml

configtxgen -profile SampleDevModeSolo -channelID system-channel -outputBlock /channel-artifacts/genesis.block
cryptogen generate --config=/config/crypto-config.yaml --output=./crypto-config