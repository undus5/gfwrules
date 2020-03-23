#!/bin/bash

print_help() {
    printf "Usage: gfwrules.sh [OPTIONS] [FILE]\n"
    printf "\nBuilding config files for Surge and Clash with specific rules and servers.\n"
    printf "There are two versions of the configs:\n"
    printf "  1. Bypass China IP\n"
    printf "  2. GFWList\n"
    printf "\nOPTIONS:\n"
    printf "  -b [FILE]\tbuild config files with your specific servers\n"
    printf "           \tomitting [FILE] will build with example servers\n"
    printf "  -h, --help\tdisplay this help and exit\n"
    printf "\n[FILE] content example:\n"
    printf "server1 = https, server1.example.com, 443, username1, password1\n"
    printf "server2 = https, server2.example.com, 443, username2, password2\n"
}

read -r -d '' surge_proxies <<'EOF'
server1 = https, server1.example.com, 443, username1, password1
server2 = https, server2.example.com, 443, username2, password2
EOF

case "$1" in
    -b)
        if [[ -z "$2" ]]; then
            echo "Building with example servers..."
        elif [[ -f "$2" ]]; then
            surge_proxies=$(sed '/^$/d' $2)
        else
            echo "File not exists: $2"
            exit 1
        fi
        ;;
    *)
        print_help
        exit 0
        ;;
esac

surge_grouped_proxies=''

column_names=(name type server port username password)
clash_proxies=''
clash_grouped_proxies=''

while IFS= read -r line || [[ -n "$line" ]]; do
    line=$(tr -d '[:space:]' <<< "$line")
    line=${line/=/,}

    IFS=',' read -ra attr <<< "$line"

    surge_grouped_proxies+=", ${attr[0]}"
    clash_grouped_proxies+="  - ${attr[0]}\n"

    for i in "${!attr[@]}"; do
        if (( $i == 0 )); then
            clash_proxies+="- "
        else
            clash_proxies+="  "
        fi

        if [[ (( $i == 1 )) && ${attr[$i]} == 'https' ]]; then
            clash_proxies+="${column_names[$i]}: http\n"
            clash_proxies+="  tls: true\n"
        else
            clash_proxies+="${column_names[$i]}: ${attr[$i]}\n"
        fi
    done
done <<< "$surge_proxies"

read -r -d '' lan_ip_list <<'EOF'
127.0.0.0/8
192.168.0.0/16
10.0.0.0/8
172.16.0.0/12
100.64.0.0/10
EOF

china_ip_list=$(curl "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt")
china_ip_list=$(sed '/^$/d' <<< "${china_ip_list}")

surge_lan_ip_rules=$(sed -e 's/^/IP-CIDR,/g' -e 's/$/,DIRECT/g' <<< "${lan_ip_list}")
surge_china_ip_rules=$(sed -e 's/^/IP-CIDR,/g' -e 's/$/,DIRECT/g' <<< "${china_ip_list}")

surge_bypass_rules="${surge_lan_ip_rules}\n${surge_china_ip_rules}"

printf "\nSaved files:\n"

write_surge_conf() {
    rules="$1"
    version="$2"
    surge_conf="[Proxy]\n"
    surge_conf+="${surge_proxies}\n\n"
    surge_conf+="[Proxy Group]\n"
    surge_conf+="ManualGroup = select${surge_grouped_proxies}\n\n"
    surge_conf+="[Rule]\n"
    surge_conf+="${rules}\n"
    if [[ $version == "bypass" ]]; then
        surge_conf+="FINAL,ManualGroup\n"
    elif [[ $version == "gfwlist" ]]; then
        surge_conf+="FINAL,DIRECT\n"
    fi

    filename="surge_${version}.conf"
    echo -e "$surge_conf" > $filename
    printf "\t$(realpath $filename)\n"
}

write_surge_conf "$surge_bypass_rules" "bypass"

clash_bypass_rules=$(echo -e "$surge_bypass_rules" | sed 's/^/- /g')

write_clash_conf() {
    rules="$1"
    version="$2"
read -r -d '' clash_conf <<'EOF'
port: 7890
socks-port: 7891
redir-port: 0
allow-lan: false
mode: Rule
log-level: info
external-controller: 127.0.0.1:9090
secret: ''
Proxy:
EOF
    clash_conf+="\n${clash_proxies}"
    clash_conf+="Proxy Group:\n"
    clash_conf+="- name: ManualGroup\n"
    clash_conf+="  type: select\n"
    clash_conf+="  proxies:\n"
    clash_conf+="${clash_grouped_proxies}"
    clash_conf+="Rule:\n"
    clash_conf+="${rules}\n"
    if [[ $version == "bypass" ]]; then
        clash_conf+="- MATCH,ManualGroup\n"
    elif [[ $version == "gfwlist" ]]; then
        clash_conf+="- MATCH,DIRECT\n"
    fi

    filename="clash_${version}.yml"
    echo -e "$clash_conf" > $filename
    printf "\t$(realpath $filename)\n"
}

write_clash_conf "$clash_bypass_rules" "bypass"

#################################################################################

printf "\n"

gfwlist=$(curl "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt")
gfwlist=$(echo -e "$gfwlist" | base64 -d)

gfwlist=$(sed "/^\[AutoProxy/d" <<< "$gfwlist")
gfwlist=$(sed "/^$/d" <<< "$gfwlist")
gfwlist=$(sed "/^!/d" <<< "$gfwlist")
gfwlist=$(sed "/\*/d" <<< "$gfwlist")
gfwlist=$(sed "s/http[s]*:\/\///g" <<< "$gfwlist")
gfwlist=$(sed "s/||/|/g" <<< "$gfwlist")
gfwlist=$(sed "s/\/.*$//g" <<< "$gfwlist")
gfwlist=$(sed "s/^\.//g" <<< "$gfwlist")
gfwlist=$(sed "s/:.*$//g" <<< "$gfwlist")

direct=$(grep "@@" <<< "$gfwlist")
direct=$(sed "s/@@//g" <<< "$direct")
proxied=$(sed "/@@/d" <<< "$gfwlist")

gfwrules() {
    list="$1"
    policy="$2"
    rules=""
    ip_regex="([0-9]{1,3}[\.]){3}[0-9]{1,3}"
    ip_list=$(grep -E -o "${ip_regex}" <<< "$list")
    list=$(sed -E "/${ip_regex}/d" <<< "$list")

    domains_full=$(grep "|" <<< "$list")
    domains_full=$(sed "s/|//g" <<< "$domains_full")
    list=$(sed "/|/d" <<< "$list")

    domains_suffix=$(grep "\." <<< "$list")
    list=$(sed "/\./d" <<< "$list")

    domains_keyword=$(sed -e "/^$/d" -e "/[^A-Za-z0-9\-]/d" <<< "$list")

    if [[ ! -z $ip_list ]]; then
        rules+=$(sed -e 's/^/IP-CIDR,/g' -e "s/$/\/24,${policy}/g" <<< "$ip_list")
        rules+="\n"
    fi
    if [[ ! -z $domains_full ]]; then
        rules+=$(sed -e 's/^/DOMAIN,/g' -e "s/$/,${policy}/g" <<< "$domains_full")
        rules+="\n"
    fi
    if [[ ! -z $domains_suffix ]]; then
        rules+=$(sed -e 's/^/DOMAIN-SUFFIX,/g' -e "s/$/,${policy}/g" <<< "$domains_suffix")
        rules+="\n"
    fi
    if [[ ! -z $domains_keyword ]]; then
        rules+=$(sed -e 's/^/DOMAIN-KEYWORD,/g' -e "s/$/,${policy}/g" <<< "$domains_keyword")
        rules+="\n"
    fi

    echo -e "$rules"
}

printf "\nSaved files:\n"

surge_gfwlist_rules="${surge_lan_ip_rules}\n"
surge_gfwlist_rules+="$(gfwrules "$direct" "DIRECT")\n"
surge_gfwlist_rules+="$(gfwrules "$proxied" "ManualGroup")"
write_surge_conf "$surge_gfwlist_rules" "gfwlist"

clash_gfwlist_rules=$(echo -e "$surge_gfwlist_rules" | sed 's/^/- /g')
write_clash_conf "$clash_gfwlist_rules" "gfwlist"

