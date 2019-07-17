#!/bin/bash

if [ ! "$BASH_VERSION" ]; then
    exec /bin/bash "$0" "$@"
else
    DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"
    URL="https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
    curl $URL --output $DIR/china_ip_list.txt;
fi