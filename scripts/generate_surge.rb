# surge

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

ip_list = File.read("#{ASSETS_PATH}/lan_ip_list.txt")
ip_list += File.read("#{ASSETS_PATH}/china_ip_list.txt")
rules = ""
ip_list.each_line do |line|
  rules += "IP-CIDR,#{line.strip},DIRECT\n"
end
rules.rstrip!

filepath = "#{ASSETS_PATH}/surge_template.conf"
template = File.read(filepath)

filepath = "#{PROJECT_ROOT}/servers.yml"
if !File.exist?(filepath)
  File.write(filepath, File.read("#{ASSETS_PATH}/server_template.yml"))
end
proxies = ""
proxy_group = ""
servers = YAML.load(File.read(filepath))
servers.each do |server|
  proxy = server["alias"]
  proxy_group += ", #{proxy}"
  proxy += " = https, #{server['server']}, #{server['port']}"
  proxy += ", #{server['username']}, #{server['password']}\n"
  proxies += proxy
end
proxies.rstrip!
proxy_group = proxy_group.slice(1, proxy_group.size)

content = template.gsub('__PROXIES__', proxies)
content.gsub!('__PROXY_GROUP__', proxy_group)
content.gsub!('__RULES__', rules)

filepath = "#{RELEASE_PATH}/surge.conf"
File.write(filepath, content)
puts "#{filepath} saved."
