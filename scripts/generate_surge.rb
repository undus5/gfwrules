#!/usr/bin/ruby

require 'etc'
require 'json'
require 'securerandom'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

PROJECT_ROOT = File.realpath(File.join(__dir__, '..'))

ip_list = File.read("#{PROJECT_ROOT}/utils/ip_lists/lan_ip_list.txt")
ip_list += File.read("#{PROJECT_ROOT}/utils/ip_lists/china_ip_list.txt")
rules = ""
ip_list.each_line do |line|
  rules += "IP-CIDR,#{line.strip},DIRECT\n"
end
rules.rstrip!

filepath = "#{PROJECT_ROOT}/utils/surge/surge_template.conf"
template = File.read(filepath)

def replaced_template(template, rules, files)
  proxies = ""
  proxy_group = ""
  files.each do |file|
    ss = JSON.parse(File.read(file))
    proxy = "#{ss['server']}:#{ss['server_port']}"
    proxy_group += ",#{proxy}"
    proxy += "=custom,#{ss['server']},#{ss['server_port']},#{ss['method']},#{ss['password']}"
    proxy += ",https://raw.githubusercontent.com/dodowhat/china-ip-rules/master/utils/surge/SSEncrypt.module\n"
    proxies += proxy
  end
  proxies.rstrip!
  proxy_group = proxy_group.slice(1, proxy_group.size)

  template.gsub!('__PROXIES__', proxies)
  template.gsub!('__PROXY_GROUP__', proxy_group)
  template.gsub!('__RULES__', rules)
end

files = ["#{PROJECT_ROOT}/utils/ss_example.json"]
filepath = "#{PROJECT_ROOT}/releases/surge.conf"
File.write(filepath, replaced_template(template, rules, files))
puts "#{filepath} saved."

if !ARGV.empty?
  if !ENV['GFW_PATH'].nil?
    filepath = "#{PROJECT_ROOT}/releases/#{ENV['GFW_PATH']}/surge.conf"
    File.write(filepath, replaced_template(template, rules, ARGV))
    puts "#{filepath} saved."
  else
    puts SecureRandom.urlsafe_base64(nil, false)
  end
end
