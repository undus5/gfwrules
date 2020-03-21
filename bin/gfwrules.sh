#!/bin/bash

print_help() {
    printf "Usage: gfwrules.sh [OPTIONS] [FILE]\n"
    printf "\nBuilding config files for Surge and Clash with specific rules and servers.\n"
    printf "The rules is making the connection go directly when meeting China IPs\n"
    printf "and go through proxy when meeting the others.\n"
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

ip_list=$(echo -e "${lan_ip_list}\n${china_ip_list}" | sed '/^$/d')

surge_rules=$(echo "$ip_list" | sed -e 's/^/IP-CIDR,/g' -e 's/$/,DIRECT/g')

surge_conf="[Proxy]\n"
surge_conf+="${surge_proxies}\n\n"
surge_conf+="[Proxy Group]\n"
surge_conf+="ManualGroup = select${surge_grouped_proxies}\n\n"
surge_conf+="[Rule]\n"
surge_conf+="${surge_rules}\n"
surge_conf+="FINAL,ManualGroup\n"

clash_rules=$(echo "$surge_rules" | sed 's/^/- /g')

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
clash_conf+="${clash_rules}\n"
clash_conf+="- MATCH,ManualGroup\n"

echo -e "$surge_conf" > surge.conf
echo -e "$clash_conf" > clash.yml

printf "\nSaved files:\n"
printf "\t$(realpath surge.conf)\n"
printf "\t$(realpath clash.yml)\n"

