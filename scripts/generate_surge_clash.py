#!/usr/bin/python3

import os

script_path = os.path.dirname(os.path.realpath(__file__))
os.chdir(os.path.join(script_path, '..'))

def format_ip_rules(ip_list_name, config_type):
  f = open(f'utils/ip_lists/{ip_list_name}.txt')
  rules = ""
  while True:
    line = f.readline()
    if len(line) == 0:
      break
    if config_type == 'surge':
      rule = f'IP-CIDR,{line.strip()},DIRECT\n'
    elif config_type == 'clash':
      rule = f'- IP-CIDR,{line.strip()},DIRECT\n'
    rules += rule
  f.close()
  return rules

def generate_file(config_type):
  ip_rules = format_ip_rules('lan_ip_list', config_type)
  ip_rules += format_ip_rules('china_ip_list', config_type)
  ip_rules = ip_rules.rstrip()

  if config_type == 'surge':
    file_extention = '.conf'
  elif config_type == 'clash':
    file_extention = '.yml'

  f = open(f'utils/{config_type}/{config_type}_template{file_extention}')
  template = f.read()
  f.close()

  filepath = f'releases/{config_type}{file_extention}'
  f = open(filepath, 'w')
  f.write(template.replace("__IP_RULES__", ip_rules))
  f.close()

  print(f'\'{filepath}\' saved.')

generate_file('surge')
generate_file('clash')
