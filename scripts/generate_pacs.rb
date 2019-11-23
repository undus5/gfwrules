#!/usr/bin/ruby

require 'etc'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

PROJECT_ROOT = File.realpath(File.join(__dir__, '..'))
ASSETS_PATH = File.join(PROJECT_ROOT, 'assets')
RELEASE_PATH = File.join(PROJECT_ROOT, 'dist')

def subnet_mask(subnet_prefix_size)
  binary_str_1 = "1" * subnet_prefix_size
  binary_str_0 = "0" * (32 - subnet_prefix_size)
  binary_str = binary_str_1 + binary_str_0

  mask_str = ""
  slice_length = 8
  4.times do |i|
    mask_str += binary_str.slice(i * slice_length, 8).to_i(2).to_s
    mask_str += "." if i < 3
  end
  mask_str
end

ip_list = File.read("#{ASSETS_PATH}/lan_ip_list.txt")
ip_list += File.read("#{ASSETS_PATH}/china_ip_list.txt")

ip_list_arr = []
ip_list.each_line do |line|
  ip_arr = line.split('/')
  ip_arr[1] = subnet_mask(ip_arr[1].to_i)
  ip_list_arr.push(ip_arr)
end

ip_list_content = ip_list_arr.to_s
ip_list_content.gsub!("[[", "[\n    [")
ip_list_content.gsub!("],", "],\n   ")
ip_list_content.gsub!("]]", "]\n]")

def generate_file(name, ip_list_content)
  filepath = "#{ASSETS_PATH}/#{name}_template.js"
  template = File.read(filepath)
  template.gsub!('__IP_LIST__', ip_list_content)
  filepath = "#{RELEASE_PATH}/#{name}.js"
  File.write(filepath, template)
  puts "#{filepath} saved."
end

generate_file('pac4sswin', ip_list_content)
generate_file('pac4switchyomega', ip_list_content)
