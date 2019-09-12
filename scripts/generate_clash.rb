#!/usr/bin/ruby

require 'etc'
require 'json'
require 'yaml'
require 'securerandom'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

clash = {
  "port" => 7890,
  "socks-port" => 7891,
  "redir-port" => 0,
  "allow-lan" => false,
  "mode" => "Rule",
  "log-level" => "info",
  "external-controller" => "127.0.0.1:9090",
  "secret" => "",
  "Proxy" => [],
  "Proxy Group" => [
    {
      "name" => "ProxyGroup",
      "type" => "select",
      "proxies" => [] 
    }
  ],
  "Rule" => []
}

PROJECT_ROOT = File.realpath(File.join(__dir__, '..'))

if ARGV.size > 0
  files = ARGV
else
  files = ["#{PROJECT_ROOT}/utils/ss_example.json"]
end
files.each do |file|
  ss = JSON.parse(File.read(file))
  proxy = {
    "type" => "ss",
    "name" => "#{ss['server']}:#{ss['server_port']}",
    "server" => ss["server"],
    "port" => ss["server_port"],
    "password" => ss["password"],
    "cipher" => ss["method"],
  }
  clash["Proxy"].push(proxy)
  clash["Proxy Group"][0]["proxies"].push(proxy["name"])
end

ip_list = File.read("#{PROJECT_ROOT}/utils/ip_lists/lan_ip_list.txt")
ip_list += File.read("#{PROJECT_ROOT}/utils/ip_lists/china_ip_list.txt")
ip_list.each_line do |line|
  clash["Rule"].push("IP-CIDR,#{line.strip},DIRECT")
end
clash["Rule"].push("MATCH,ProxyGroup")

if files == ["#{PROJECT_ROOT}/utils/ss_example.json"]
  filepath = "#{PROJECT_ROOT}/releases/clash.yml"
elsif !ENV['GFW_PATH'].nil?
  filepath = "#{PROJECT_ROOT}/releases/#{ENV['GFW_PATH']}/clash.yml"
else
  puts SecureRandom.urlsafe_base64(nil, false)
  exit 1
end
File.write(filepath, clash.to_yaml.gsub("---\n", ""))
puts "#{filepath} saved."
