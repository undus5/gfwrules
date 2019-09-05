#!/usr/bin/python3

import os
import yaml

script_path = os.path.dirname(os.path.realpath(__file__))
os.chdir(os.path.join(script_path, '..'))

def format_ip_rules(ip_list_name):
  f = open(f'utils/ip_lists/{ip_list_name}.txt')
  rules = []
  while True:
    line = f.readline()
    if len(line) == 0:
      break
    rules.append(f'IP-CIDR,{line.strip()},DIRECT')
  f.close()
  return rules

ip_rules = format_ip_rules('lan_ip_list')
ip_rules.extend(format_ip_rules('china_ip_list'))
ip_rules.append("MATCH,SS")

clash_config = {
  "port": 7890,
  "socks-port": 7891,
  "redir-port": 0,
  "allow-lan": False,
  "mode": "Rule",
  "log-level": "info",
  "external-controller": "0.0.0.0:9090",
  "secret": "",
  "Proxy": [
    {
      "type": "ss",
      "server": "__SERVER__",
      "port": "__SERVER_PORT__",
      "password": "__PASSWORD__",
      "cipher": "__ENCRYPTION__",
      "name": "SS"
    }
  ],
  "Proxy Group": [
    {
      "name": "Proxy",
      "type": "select",
      "proxies": ["SS"]
    }
  ],
  "Rule": ip_rules
}

filepath = 'releases/clash.yml'
f = open(filepath, 'w')
f.write(yaml.dump(clash_config))
f.close()

print(f'\'{filepath}\' saved.')
