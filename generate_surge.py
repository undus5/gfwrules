#!/usr/bin/python3

import os

script_path = os.path.dirname(os.path.realpath(__file__))
os.chdir(script_path)

def format_ip_rules(ip_list_name):
  f = open(f'utils/ip_lists/{ip_list_name}.txt')
  rules = ""
  while True:
    line = f.readline()
    if len(line) == 0:
      break
    rules += f'IP-CIDR,{line.strip()},DIRECT\n'
  f.close()
  return rules

ip_rules = format_ip_rules('lan_ip_list')
ip_rules += format_ip_rules('china_ip_list')
ip_rules = ip_rules.rstrip()

f = open('utils/surge/surge_template.conf')
template = f.read()
f.close()

filepath = 'releases/surge.conf'
f = open(filepath, 'w')
f.write(template.replace("__IPRULES__", ip_rules))
f.close()

print(f'\'{filepath}\' saved.')
