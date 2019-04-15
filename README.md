# china-ip-rules

Turn China IP list([17mon@github/china_ip_list](https://github.com/17mon/china_ip_list)) into Shadowsocks clients rules, make all china IP and LAN IP request go directly.

For shadowsocks-windows PAC file:

[https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/pac.txt](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/pac.txt)

For Surge 3 on iOS:

[https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/surge3.conf](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/surge3.conf)

## Script usage:

For config files:

    bundle
    ruby generate_config_files.rb "your-shadowsocks-config.json"

For iptables rules:

    bundle
    sudo ruby iptables.rb [init|up|down|update|purge]

## Config ipset & iptables auto restore and ss-redir auto start on system boot

For Ubuntu 18.04, Edit `/etc/rc.local` with following content, if the file is not exists, create it:

    #!/bin/sh

    if [ -f /etc/ipset.conf ]; then
        ipset restore -file /etc/ipset.conf
    fi

    if [ -f /etc/iptables.rules ]; then
        iptables-restore < /etc/iptables.rules
    fi

    ss-redir -c /etc/shadowsocks-libev/config.json -f /var/run/shadowsocks.pid

    exit 0

Then run `sudo chmod +x /etc/rc.local`
