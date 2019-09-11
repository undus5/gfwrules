#!/usr/bin/ruby

require 'etc'
require 'json'
require 'securerandom'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

PROJECT_ROOT = File.realpath(File.join(__dir__, '..'))

if ARGV.size > 0
  files = ARGV
else
  files = ["#{PROJECT_ROOT}/utils/ss_example.json"]
end
proxies = ""
proxy_group = ""
files.each do |file|
  ss = JSON.parse(File.read(file))
  proxy = "#{ss['server']}:#{ss['server_port']}"
  proxy_group += proxy
  proxy += "=#{ss['server']},#{ss['server_port']},#{ss['method']},#{ss['password']}"
  proxy += ",https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/utils/surge/SSEncrypt.module\n"
  proxies += proxy
end
proxies.rstrip!

ip_list = File.read("#{PROJECT_ROOT}/utils/ip_lists/lan_ip_list.txt")
ip_list += File.read("#{PROJECT_ROOT}/utils/ip_lists/china_ip_list.txt")
rules = ""
ip_list.each_line do |line|
  rules += "IP-CIDR,#{line.strip},DIRECT\n"
end
rules.rstrip!

filepath = "#{PROJECT_ROOT}/utils/surge/surge_template.conf"
template = File.read(filepath)
template = template.gsub!('__PROXIES__', proxies)
template = template.gsub!('__PROXY_GROUP__', proxy_group)
template = template.gsub!('__RULES__', rules)

if files == ["#{PROJECT_ROOT}/utils/ss_example.json"]
  filepath = "#{PROJECT_ROOT}/releases/surge.conf"
elsif !ENV['GFW_PATH'].nil?
  filepath = "#{PROJECT_ROOT}/releases/#{ENV['GFW_PATH']}/surge.conf"
else
  puts SecureRandom.urlsafe_base64(nil, false)
  exit 1
end
File.write(filepath, template)
puts "#{filepath} saved."
