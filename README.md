# china-ip-rules

Turn China IP list([17mon@github/china_ip_list](https://github.com/17mon/china_ip_list)) into Shadowsocks clients rules, make all china IP and LAN IP request go directly.

DNS over TCP:

First, install `unbound` package.

Second, edit `/etc/unbound/unbound.conf` with:

    tcp-upstream: yes
    forward-zone:
        name: "."
        forward-addr: 8.8.8.8
        forward-addr: 8.8.4.4
        forward-first: no

Third, restart `unbound` service
