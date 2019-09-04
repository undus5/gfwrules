#!/bin/bash

if [ $EUID != 0 ]; then
    echo "Requiring root privilege.";
    exit 1
fi
if [ ! $1 ] || [ ! $2 ]; then
    echo "Usage: ./dns.sh [up|down] [ss-redir-localport]";
    exit 1
fi

DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"

CHAIN_NAME="SHADOWSOCKS"

rules_purge() {
    # Purge rules
    iptables -t mangle -D PREROUTING -j $CHAIN_NAME > /dev/null 2>&1;
    iptables -t mangle -F $CHAIN_NAME > /dev/null 2>&1;
    if [ $? = 0 ]; then
        iptables -t mangle -X $CHAIN_NAME > /dev/null 2>&1;
    fi
    ip rule del fwmark 0x2333/0x2333 lookup 100 > /dev/null 2>&1;
    ip route del local default dev lo table 100 > /dev/null 2>&1;
}

case $1 in
    enable)
        rules_purge;
        # Setup rules
        ip route add local default dev lo table 100 > /dev/null 2>&1;
        ip rule add fwmark 1 lookup 100 > /dev/null 2>&1;

        iptables -t mangle -N $CHAIN_NAME;

        cat lan_ip_list.txt | \
        while IFS= read line || [ -n "$line" ]; do
            if [ ! -z $line ]; then
                iptables -t mangle -A $CHAIN_NAME -d $line -j RETURN;
            fi
        done

        iptables -t mangle -A $CHAIN_NAME -p udp --dport 53 -j TPROXY --on-port $2 --tproxy-mark 0x2333/0x2333;

        iptables -t mangle -A PREROUTING -j $CHAIN_NAME;
        ;;
    disable)
        rules_purge;
        ;;
    *)
        echo "Usage: ./dns.sh [up|down] [ss-redir-localport]";
        ;;
esac
