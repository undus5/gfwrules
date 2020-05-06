#!/bin/bash

cd "$(dirname $0)"

gfwlist=$(mktemp)
direct=$(mktemp)

base64 -d gfwlist.txt > ${gfwlist}

sed -i \
    -e "/^\[AutoProxy/d" \
    -e "/^$/d" \
    -e "/^!/d" \
    -e "/\*/d" \
    -e "s/http[s]*:\/\///g" \
    -e "s/||/|/g" \
    -e "s/\/.*$//g" \
    -e "s/^\.//g" \
    -e "s/:.*$//g" \
    ${gfwlist}

grep "@@" ${gfwlist} | sed "s/@@//g" > ${direct}
sed -i -e "/@@/d" ${gfwlist}

f() {
    list="$1"
    policy="$2"
    rules=""
    ip_regex="([0-9]{1,3}[\.]){3}[0-9]{1,3}"
    ip_list=$(grep -E -o "${ip_regex}" ${list})
    sed -i -E "/${ip_regex}/d" ${list}

    domains_full=$(grep "|" ${list})
    domains_full=$(sed "s/|//g" <<< "${domains_full}")
    sed -i -e "/|/d" ${list}

    domains_suffix=$(grep "\." ${list})
    sed -i -e "/\./d" ${list}

    domains_keyword=$(sed -e "/^$/d" -e "/[^A-Za-z0-9\-]/d" ${list})

    if [[ ! -z ${ip_list} ]]; then
        rules+=$(sed -e 's/^/IP-CIDR,/g' -e "s/$/\/24,${policy}/g" <<< "${ip_list}")
        rules+="\n"
    fi
    if [[ ! -z ${domains_full} ]]; then
        rules+=$(sed -e 's/^/DOMAIN,/g' -e "s/$/,${policy}/g" <<< "${domains_full}")
        rules+="\n"
    fi
    if [[ ! -z ${domains_suffix} ]]; then
        rules+=$(sed -e 's/^/DOMAIN-SUFFIX,/g' -e "s/$/,${policy}/g" <<< "${domains_suffix}")
        rules+="\n"
    fi
    if [[ ! -z ${domains_keyword} ]]; then
        rules+=$(sed -e 's/^/DOMAIN-KEYWORD,/g' -e "s/$/,${policy}/g" <<< "${domains_keyword}")
        rules+="\n"
    fi

    echo -e "${rules}"
}

rules="$(f ${direct} "DIRECT")\n"
rules+="$(f ${gfwlist} "PROXY")"

cat lan_ip_list.txt > ${gfwlist}
sed -i -e '/^$/d' ${gfwlist}
sed -i -e 's/^/IP-CIDR,/g' -e 's/$/,DIRECT/g' ${gfwlist}

echo -e "${rules}" >> ${gfwlist}
sed -i -e '/^$/d' ${gfwlist}

# Surge
echo -e "FINAL,DIRECT" >> ${gfwlist}
file="surge_gfwlist.conf"
sed "/\[Rule\]/r ${gfwlist}" surge.conf > ${file}
echo "$(realpath ${file})"

# Clash
sed -i -e 's/FINAL/MATCH/g' ${gfwlist}
sed -i -e 's/^/- /g' ${gfwlist}
file="clash_gfwlist.yml"
sed "/Rule:/r ${gfwlist}" clash.yml > ${file}
echo "$(realpath ${file})"

rm ${gfwlist}
rm ${direct}
