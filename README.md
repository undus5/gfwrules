# GFW Rules

Surge / Clash 配置文件生成工具。

规则由 ipip.net [china_ip_list](https://github.com/17mon/china_ip_list) 转换生成。

大陆 IP 走直连，其余走代理。

安装:

    $ git clone https://github.com/dodowhat/gfwrules.git ~/.gfwrules
    $ echo 'export PATH="$PATH:~/.gfwrules/bin"' >> ~/.bashrc
    $ source ~/.bashrc

使用说明:

    gfwrules.sh [选项] [文件名]

    选项:
      -b [文件名]   生成配置文件，文件内容为服务器相关信息
                    忽略文件名则生成示例配置文件
      -h, --help    显示帮助信息

    文件内容示例:
    server1 = https, server1.example.com, 443, username1, password1
    server2 = https, server2.example.com, 443, username2, password2

示例下载(把里面的服务器配置改成自己的就可以使用了，不定期更新):

* [surge.conf](https://raw.githubusercontent.com/dodowhat/gfwrules/master/surge.conf)

* [clash.yml](https://raw.githubusercontent.com/dodowhat/gfwrules/master/clash.yml)


Manual:

    Usage: gfwrules.sh [OPTIONS] [FILE]

    Building config files for Surge and Clash with specific rules and servers.
    The rules is making the connection go directly when meeting China IPs
    and go through proxy when meeting the others.

    OPTIONS:
      -b [FILE]     build config files with your specific servers
                    omitting [FILE] will build with example servers
      -h, --help    display this help and exit

    [FILE] content example:
    server1 = https, server1.example.com, 443, username1, password1
    server2 = https, server2.example.com, 443, username2, password2

