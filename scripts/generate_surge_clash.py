#!/usr/bin/python3

import os
import sys
import json

if os.geteuid() == 0:
  exit("Please use non-root user to execute.")

script_path = os.path.dirname(os.path.realpath(__file__))
project_root = os.path.realpath(os.path.join(script_path, '..'))

def format_rule(ip, config_type):
  if config_type == 'surge':
    rule = f'IP-CIDR,{ip},DIRECT\n'
  elif config_type == 'clash':
    rule = f'- IP-CIDR,{ip},DIRECT\n'
  return rule


def format_ip_rules(ip_list_name, config_type):
  f = open(f'{project_root}/utils/ip_lists/{ip_list_name}.txt')
  rules = ""
  while True:
    line = f.readline()
    if len(line) == 0:
      break
    rules += format_rule(line.strip(), config_type)
  f.close()
  return rules

def format_proxy(ss, config_type):
  if config_type == 'surge':
    proxy = f'{ss['server']}:{ss['server_port']}'
    proxy += f'={ss['server']},{ss['server_port']},{ss['method']},{ss['password']}'
    proxy += ',https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/utils/surge/SSEncrypt.module'
  elif config_type == 'clash':

def generate_file(config_type):
  ip_rules = format_ip_rules('lan_ip_list', config_type)
  ip_rules += format_ip_rules('china_ip_list', config_type)
  ip_rules = ip_rules.rstrip()

  extensions = {
      'surge': '.conf',
      'clash': '.yml'
  }
  filepath = f'{project_root}/utils/{config_type}/{config_type}_template{extentions[config_type]}'
  template = open(filepath).read()
  template = template.replace("__IP_RULES__", ip_rules)

  if len(sys.argv) > 1:
    ss_files = sys.argv[1:]
  else:
    ss_files = [f'{project_root}/utils/ss_example.json']

  proxy = ""
  for ss_file in ss_files:
    ss = json.loads(open(ss_file, 'r').read())

  filepath = f'{project_root}/releases/{config_type}{file_extention}'
  open(filepath, 'w').write(template)

  print(f'\'{filepath}\' saved.')

generate_file('surge')
generate_file('clash')
