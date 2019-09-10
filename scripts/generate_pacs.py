#!/usr/bin/python3

import os

if os.geteuid() == 0:
  exit("Please use non-root user to execute.")

script_path = os.path.dirname(os.path.realpath(__file__))
project_root = os.path.realpath(os.path.join(script_path, '..'))

def subnet_mask(prefix_size):
  binary_str_1 = "1" * prefix_size
  binary_str_0 = "0" * (32 - prefix_size)
  binary_str = binary_str_1 + binary_str_0

  slice_length = 8
  mask_str = ""
  start = 0
  for i in range(0, 4):
    start = i * slice_length
    end = start + slice_length
    mask_str += str(int(binary_str[start:end], 2))
    if i < 3:
      mask_str += "."

  return mask_str

def format_ip_list(name):
  ip_arr = []

  f = open(f'{project_root}/utils/ip_lists/{name}.txt')
  while True:
    line = f.readline()
    if len(line) == 0:
      break
    arr = line.split('/')
    arr[1] = subnet_mask(int(arr[1].strip()))
    ip_arr.append(arr)
  f.close()

  return ip_arr

ip_list_arr = format_ip_list('lan_ip_list')
ip_list_arr.extend(format_ip_list('china_ip_list'))

ip_list_content = str(ip_list_arr)
ip_list_content = ip_list_content.replace("[[", "[\n    [")
ip_list_content = ip_list_content.replace("],", "],\n   ")
ip_list_content = ip_list_content.replace("]]", "]\n]")

def generate_file(name):
  filepath = f'{project_root}/utils/pac/{name}_template.js'
  template = open(filepath).read()
  template = template.replace("__IP_LIST__", ip_list_content)

  filepath = f'{project_root}/releases/{name}.js'
  open(filepath, 'w').write(template)

  print(f'\'{filepath}\' saved.')

generate_file('pac4sswin')
generate_file('pac4switchyomega')
