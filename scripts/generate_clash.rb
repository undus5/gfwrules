# clash

require 'etc'
require 'yaml'
require 'securerandom'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

PROJECT_ROOT = File.realpath(File.join(__dir__, '..'))
ASSETS_PATH = File.join(PROJECT_ROOT, 'assets')
RELEASE_PATH = File.join(PROJECT_ROOT, 'dist')
if !Dir.exist?(RELEASE_PATH)
  Dir.mkdir(RELEASE_PATH)
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

ip_list = File.read("#{ASSETS_PATH}/lan_ip_list.txt")
ip_list += File.read("#{ASSETS_PATH}/china_ip_list.txt")
ip_list.each_line do |line|
  clash["Rule"].push("IP-CIDR,#{line.strip},DIRECT")
end
clash["Rule"].push("MATCH,ProxyGroup")

filepath = "#{PROJECT_ROOT}/servers.yml"
if !File.exist?(filepath)
  File.write(filepath, File.read("#{ASSETS_PATH}/server_template.yml"))
end
proxies = []
proxy_group = []
servers = YAML.load(File.read(filepath))
servers.each do |server|
  proxy = {
    "type" => "http",
    "tls" => true,
    "name" => server["alias"],
    "server" => server["server"],
    "port" => server["port"],
    "username" => server["username"],
    "password" => server["password"],
  }
  proxies.push(proxy)
  proxy_group.push(proxy["name"])
end

clash["Proxy"] = proxies
clash["Proxy Group"][0]["proxies"] = proxy_group
filepath = "#{RELEASE_PATH}/clash.yml"
File.write(filepath, clash.to_yaml.gsub("---\n", ""))
puts "#{filepath} saved."
