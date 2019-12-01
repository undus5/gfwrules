# clash

require 'etc'
require 'yaml'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

def build(target_directory, servers, template)
  clash = YAML.load(template)
  proxies = []
  proxy_group = []

  servers.each_with_index do |server, index|
    if server["type"] == "https"
      proxy = {
        "name" => server["name"] + "_local",
        "type" => "http",
        "server" => "127.0.0.1",
        "port" => 8444 + index,
      }
    else
      proxy = server
    end
    proxies.push(proxy)
    proxy_group.push(proxy["name"])
  end

  clash["Proxy"] = proxies
  clash["Proxy Group"].each_index do |index|
    clash["Proxy Group"][index]["proxies"] += proxy_group
  end
  target_filepath = File.join(target_directory, "config.yaml")
  File.write(target_filepath, clash.to_yaml.gsub("---\n", ""))
  puts "#{target_filepath} saved."
end

PROJECT_ROOT = File.realpath(File.join(__dir__))
ASSETS_DIR = File.join(PROJECT_ROOT, 'assets')
DIST_DIR = File.join(PROJECT_ROOT, 'dist')
TEST_DIR = File.join(PROJECT_ROOT, 'test')
Dir.mkdir(TEST_DIR) if !Dir.exist?(TEST_DIR)
SERVER_EXAMPLE = File.join(ASSETS_DIR, "server_example.yml")
SERVER_TEST = File.join(TEST_DIR, "servers.yml")
if !File.exist?(SERVER_TEST)
  File.write(SERVER_TEST, File.read(SERVER_EXAMPLE))
end

config = {
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
      "name" => "ManualGroup",
      "type" => "select",
      "proxies" => ["AutoGroup"] 
    },
    {
      "name" => "AutoGroup",
      "type" => "fallback",
      "proxies" => [],
      "url" => "http://www.google.com/generate_204",
      "interval" => 300
    }
  ],
  "Rule" => []
}

ip_list = File.read("#{ASSETS_DIR}/lan_ip_list.txt")
ip_list += File.read("#{ASSETS_DIR}/china_ip_list.txt")
ip_list.each_line do |line|
  config["Rule"].push("IP-CIDR,#{line.strip},DIRECT")
end
config["Rule"].push("MATCH,ManualGroup")

template = config.to_yaml

# Build dist
servers = YAML.load(File.read(SERVER_EXAMPLE))
build(DIST_DIR, servers, template)

# Build test
servers = YAML.load(File.read(SERVER_TEST))
build(TEST_DIR, servers, template)
