#!/bin/bash

WORKING_DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"
cd $WORKING_DIR;
URL="https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
# curl $URL --output $WORKING_DIR/utils/ip_lists/china_ip_list.txt;
wget -O $WORKING_DIR/utils/ip_lists/china_ip_list.txt $URL;
