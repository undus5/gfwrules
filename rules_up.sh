#!/bin/bash

if [ $EUID != 0 ]; then
    echo "Requiring root privilege.";
    exit 1
fi
if [ ! $1 ] || [ ! -f $1 ]; then
    echo "Missing SS config file.";
    exit 1
fi

DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"

CHAIN_NAME="SHADOWSOCKS"
IPSET_NAME="CHINAIP"

# Purge rules
iptables -t nat -D OUTPUT -p tcp -j $CHAIN_NAME > /dev/null 2>&1;
iptables -t nat -F $CHAIN_NAME > /dev/null 2>&1;
if [ $? = 0 ]; then
    iptables -t nat -X $CHAIN_NAME > /dev/null 2>&1;
fi
ipset destroy $IPSET_NAME > /dev/null 2>&1
if [ $? = 127 ]; then
    exit 1
fi

# Setup rules
ipset create $IPSET_NAME hash:net;

cat $DIR/lan_ip_list.txt $DIR/china_ip_list.txt | \
while IFS= read line || [ -n "$line" ]; do
    if [ ! -z $line ]; then
        ipset add $IPSET_NAME $line;
    fi
done

SERVER=$(python3 -c "import json;ss=json.loads(open('$1','r').read());print(ss['server'])" | tr -d '\n')
PORT=$(python3 -c "import json;ss=json.loads(open('$1','r').read());print(ss['local_port'])" | tr -d '\n')

iptables -t nat -N $CHAIN_NAME;
iptables -t nat -A $CHAIN_NAME -d $SERVER -j RETURN;
iptables -t nat -A $CHAIN_NAME -p tcp -m set --match-set $IPSET_NAME dst -j RETURN;
iptables -t nat -A $CHAIN_NAME -p tcp -j REDIRECT --to-port $PORT;

iptables -t nat -A OUTPUT -p tcp -j $CHAIN_NAME;
