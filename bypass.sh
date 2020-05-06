#!/bin/bash

cd "$(dirname $0)"

tempfile=$(mktemp)
cat lan_ip_list.txt china_ip_list.txt > ${tempfile}
sed -i -e '/^$/d' ${tempfile}
sed -i -e 's/^/IP-CIDR,/g' -e 's/$/,DIRECT/g' ${tempfile}

# Surge
echo -e "\nFINAL,PROXY" >> ${tempfile}
file="surge_bypass.conf"
sed "/\[Rule\]/r ${tempfile}" surge.conf > ${file}
echo "$(realpath ${file})"

# Clash
sed -i -e 's/FINAL/MATCH/g' ${tempfile}
sed -i -e 's/^/- /g' ${tempfile}
file="clash_bypass.yml"
sed "/Rule:/r ${tempfile}" clash.yml > ${file}
echo "$(realpath ${file})"

rm ${tempfile}
