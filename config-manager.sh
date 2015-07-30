#!/bin/sh

usage() {
    PROG="$(basename $0)"
    echo "usage: ${PROG} <config directory>"
}

SCRIPT_DIR="$( cd -P "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
source "${SCRIPT_DIR}/config.sh"

if [ -z "$1" ];
then
    usage
    exit 1
fi

if [ -z "${DISPLAY}" ];
then
    echo "DISPLAY variable not set.  Please make sure X11 forwarding is on"
    exit 1
fi

if [ ! -f "${XAUTHORITY}" ];
then
    echo "The Xauthority file `${XAUTHORITY}`  does not exist"
    echo "Try connecting correctly using SSH with X11 Forwarding"
    exit 2
fi

PREFS_DIR="${SCRIPT_DIR}/.java"

CONFIG_DIR="$( cd -P "$1" && pwd )"

if [ ! -d "${PREFS_DIR}" ];
then
    echo "Java preferences directory ${PREFS_DIR} not found...exiting"
    exit 3
fi

if [ ! -d "${CONFIG_DIR}" ];
then
    echo "Config directory ${CONFIG_DIR} not found...exiting"
    exit 4
fi

if [ "$TERM" != "dumb" ];
then
    TTY='-it'
fi

if [ ! -w "${DOCKER_SOCKET}" ];
then
    SUDO='sudo'
fi

$SUDO docker run $TTY --rm \
       -e DISPLAY=$DISPLAY \
       -v $XAUTHORITY:/root/.Xauthority \
       -v $CONFIG_DIR:/gads/configs \
       -v $PREFS_DIR:/root/.java \
       --net=host \
       $GADS_IMAGE \
       /gads/config-manager