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
