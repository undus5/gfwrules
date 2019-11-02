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

ip_list = File.read("#{PROJECT_ROOT}/utils/ip_lists/lan_ip_list.txt")
ip_list += File.read("#{PROJECT_ROOT}/utils/ip_lists/china_ip_list.txt")
ip_list.each_line do |line|
  clash["Rule"].push("IP-CIDR,#{line.strip},DIRECT")
end
clash["Rule"].push("MATCH,ProxyGroup")

def proxies_and_group(files)
  proxies = []
  proxy_group = []
  files.each do |file|
    ss = JSON.parse(File.read(file))
    proxy = {
      "type" => "ss",
      # "name" => "#{ss['server']}:#{ss['server_port']}",
      "name" => File.basename(file, '.*'),
      "server" => ss["server"],
      "port" => ss["server_port"],
      "password" => ss["password"],
      "cipher" => ss["method"],
    }
    proxies.push(proxy)
    proxy_group.push(proxy["name"])
  end
  return proxies, proxy_group
end

files = ["#{PROJECT_ROOT}/utils/ss_example.json"]
proxies, proxy_group = proxies_and_group(files)
clash["Proxy"] = proxies
clash["Proxy Group"][0]["proxies"] = proxy_group
filepath = "#{PROJECT_ROOT}/releases/clash.yml"
File.write(filepath, clash.to_yaml.gsub("---\n", ""))
puts "#{filepath} saved."

if !ARGV.empty?
  if !ENV['GFW_PATH'].nil?
    proxies, proxy_group = proxies_and_group(ARGV)
    clash["Proxy"] = proxies
    clash["Proxy Group"][0]["proxies"] = proxy_group
    filepath = "#{PROJECT_ROOT}/releases/#{ENV['GFW_PATH']}/clash.yml"
    File.write(filepath, clash.to_yaml.gsub("---\n", ""))
    puts "#{filepath} saved."
  else
    puts SecureRandom.urlsafe_base64(nil, false)
  end
end
