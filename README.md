# china-ip-rules

Turn China IP list([17mon@github/china_ip_list](https://github.com/17mon/china_ip_list)) into Shadowsocks clients rules, make all china IP and LAN IP request go directly.

## Releases

PAC for shadowsocks-windows:

[pac4sswin.js](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/releases/pac4sswin.js)

PAC for SwitchyOmega:

[pac4switchyomega.js](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/releases/pac4switchyomega.js)

Surge / ShadowRocket / Surfboard:

[surge.conf](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/releases/surge.conf)

Clash for Windows:

[clash.yml](https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/releases/clash.yml)

## Script usage:

Generage config files:

    ./update_releases.sh

## Setup rules on Linux

Prerequisite:

Make sure your system has `ipset` and `shadowsocks-libev` installed.

Enable/Disable bypass rules:

    sudo ./iptables_rules.sh enable [your-ss-config.json]
    sudo ./iptables_rules.sh disable

DNS over TCP:

1. Install `unbound` package.

2. Edit `/etc/unbound/unbound.conf` with:

    tcp-upstream: yes
    forward-zone:
        name: "."
        forward-addr: 8.8.8.8
        forward-addr: 8.8.4.4
        forward-first: no

3. Restart unbound service
