# china-ip-rules

Turn China IP list([17mon@github/china_ip_list](https://github.com/17mon/china_ip_list)) into Shadowsocks clients rules, make all china IP and LAN IP request go directly.

## Releases

PAC for shadowsocks-windows:

[pac4shadowsocks_windows.js](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/releases/pac4shadowsocks_windows.js)

PAC for SwitchyOmega:

[pac4switchyomega.js](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/releases/pac4switchyomega.js)

Surge 3 on iOS:

[surge3.conf](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/releases/surge3.conf)

Clash for Windows:

[clash.yml](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/releases/clash.yml)

## Script usage:

For config files:

    bundle
    ruby generate_config_files.rb "your-shadowsocks-config.json"

For iptables rules:

    bundle
    sudo ruby iptables.rb [init|up|down|refresh|purge]

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
