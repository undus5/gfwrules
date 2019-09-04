#!/bin/bash

if [ $EUID != 0 ]; then
    echo "Requiring root privilege.";
    exit 1
fi
if [ ! $1 ] || [ ! $2 ]; then
    echo "Usage: sudo ./global.sh [up|down] [port]";
    exit 1
fi

DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"

case $1 in
    up)
        ./rules_down.sh
        iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-port $2;
        ;;
    down)
        iptables -t nat -D OUTPUT -p tcp -j REDIRECT --to-port $2 > /dev/null 2>&1;
        ;;
    *)
        echo "Usage: sudo ./global.sh [up|down] [port]";
        ;;
esac
