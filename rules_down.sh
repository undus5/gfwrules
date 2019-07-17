#!/bin/bash

CHAIN_NAME="SHADOWSOCKS"
IPSET_NAME="CHINAIP"

iptables -t nat -D OUTPUT -p tcp -j $CHAIN_NAME > /dev/null 2>&1;
iptables -t nat -F $CHAIN_NAME > /dev/null 2>&1;
if [ $? = 0 ]; then
    iptables -t nat -X $CHAIN_NAME > /dev/null 2>&1;
fi
ipset destroy $IPSET_NAME > /dev/null 2>&1
if [ $? = 127 ]; then
    exit 1
fi