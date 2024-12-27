#!/bin/bash

if [ "$(basename $(realpath .))" != "learn-fabric" ]; then
    echo "You are outside the scope of the project"
    exit 0
fi

export NETWORK_NAME=learn-fabric_network

COMMAND=$1
SUBCOMMAND=$2

function dev_node(){
    local cmd=$1
    case $cmd in
        "setup")
            rm -rf ./deployment/dev/channel-artifacts
            rm -rf ./deployment/dev/crypto-config
            docker rm -f $(docker ps -aq)
            docker compose -f ./deployment/dev/setup.yaml up 
            ;;
        "start")
            docker compose -f ./deployment/dev/docker-compose.yaml up
            ;;
        "stop")
            docker compose -f ./deployment/dev/docker-compose.yaml down
            ;;
        *)
            echo "Usage: $0 dev [start | stop]"
            ;;
    esac
}

case $COMMAND in
    "cli")
        docker compose -f ./deployment/dev/cli.yaml run cli /bin/bash
        ;;
    "dev")
        dev_node $SUBCOMMAND
        ;;
    *)
        echo "Usage: $0 [dev]"
        ;;
esac