# clash

require 'etc'
require 'yaml'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

PROJECT_ROOT = File.realpath(File.join(__dir__))
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
servers = YAML.load(File.read(filepath))

proxies = []
proxy_group = []
gost_local_start = "#!/bin/bash\n\n"
gost_local_stop = "#!/bin/bash\n\n"

servers.each_with_index do |server, index|
  container_name = "gost_local_#{server['alias']}"
  local_port = 8444 + index

  if !server['middleware']
    gost_local_start += "docker run -d -p #{local_port}:#{local_port} --name #{container_name} ginuerzh/gost"
    gost_local_start += " -L http://:#{local_port}"
    gost_local_start += " -F https://#{server['username']}:#{server['password']}@#{server['server']}:#{server['port']}\n\n"

    gost_local_stop += "docker container stop #{container_name}\n\n"
  end

  proxy = {
    "type" => "http",
    "name" => container_name,
    "server" => "127.0.0.1",
    "port" => local_port,
  }
  proxies.push(proxy)
  proxy_group.push(proxy["name"])
end

filepath = "#{RELEASE_PATH}/gost_local_start.sh"
File.write(filepath, gost_local_start)
puts "#{filepath} saved."

filepath = "#{RELEASE_PATH}/gost_local_stop.sh"
gost_local_stop += "docker container prune\n"
File.write(filepath, gost_local_stop)
puts "#{filepath} saved."

clash["Proxy"] = proxies
clash["Proxy Group"][0]["proxies"] = proxy_group
filepath = "#{RELEASE_PATH}/clash.yml"
File.write(filepath, clash.to_yaml.gsub("---\n", ""))
puts "#{filepath} saved."

clash_start = "#!/bin/bash\n\n"
clash_start += "docker run -d -p 7890:7890 --name clash"
clash_start += " -v #{filepath}:/root/.config/clash/config.yaml"
clash_start += " dreamacro/clash\n"
filepath = "#{RELEASE_PATH}/clash_start.sh"
File.write(filepath, clash_start)
puts "#{filepath} saved."
