# surge

require 'etc'
require 'yaml'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

# test
def build(target_directory, servers, template)
  proxies = ""
  proxy_group = ""
  # servers = YAML.load(File.read(server_config_filepath))
  servers.each do |server|
    proxy = server["name"]
    proxy_group += ", #{proxy}"
    proxy += " = #{server['type']}, #{server['server']}, #{server['port']}"
    proxy += ", #{server['username']}, #{server['password']}\n"
    proxies += proxy
  end
  proxies.rstrip!
  proxy_group = proxy_group.slice(1, proxy_group.size)

  content = template.gsub('__PROXIES__', proxies)
  content.gsub!('__PROXY_GROUP__', proxy_group)

  target_filepath = File.join(target_directory, "surge.conf")
  File.write(target_filepath, content)
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

ip_list = File.read("#{ASSETS_DIR}/lan_ip_list.txt")
ip_list += File.read("#{ASSETS_DIR}/china_ip_list.txt")
rules = ""
ip_list.each_line do |line|
  rules += "IP-CIDR,#{line.strip},DIRECT\n"
end
rules.rstrip!

template = File.read(File.join(ASSETS_DIR, "surge_template.conf"))
template.gsub!('__RULES__', rules)

# Build dist
servers = YAML.load(File.read(SERVER_EXAMPLE))
build(DIST_DIR, servers, template)

# Build test
servers = YAML.load(File.read(SERVER_TEST))
build(TEST_DIR, servers, template)
