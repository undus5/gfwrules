# GFW Rules

Surge / Clash 分流规则配置文件生成工具。

有两个版本:

1. 绕过局域网与大陆IP

   规则由 ipip.net [china_ip_list](https://github.com/17mon/china_ip_list) 转换生成。

2. GFWList

安装:

    $ git clone https://github.com/dodowhat/gfwrules.git

使用说明:

    # 更新 china_ip_list.txt 以及 gfwlist.txt
    $ ./update_list.sh

    # 生成绕过局域网与大陆IP版本
    $ ./bypass.sh

    # 生成GFWList版本
    $ ./gfwlist.sh

示例下载 (把里面的服务器配置改成自己的就可以使用了，不定期更新):

* [surge_bypass.conf](https://raw.githubusercontent.com/dodowhat/gfwrules/master/surge_bypass.conf)

* [surge_gfwlist.conf](https://raw.githubusercontent.com/dodowhat/gfwrules/master/surge_gfwlist.conf)

* [clash_bypass.yml](https://raw.githubusercontent.com/dodowhat/gfwrules/master/clash_bypass.yml)

* [clash_gfwlist.yml](https://raw.githubusercontent.com/dodowhat/gfwrules/master/clash_gfwlist.yml)
